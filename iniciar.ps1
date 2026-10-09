<#
  Inicia o app RV Label e deixa o assistente de IA pronto.
  Uso:
    .\iniciar.ps1                 # fluxo completo, pergunta em qual dispositivo rodar
    .\iniciar.ps1 -SemIA          # roda o app sem configurar o Firebase
    .\iniciar.ps1 -ReconfigurarIA # força um novo flutterfire configure
    .\iniciar.ps1 -Dispositivo chrome   # pula a pergunta (chrome, windows ou id do Android)
#>
param(
    [switch]$SemIA,
    [switch]$ReconfigurarIA,
    [string]$Dispositivo = ""
)

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

function Passo($texto) { Write-Host "`n==> $texto" -ForegroundColor Red }
function Falhou($texto) { Write-Host "Erro: $texto" -ForegroundColor Yellow; exit 1 }
function Existe($cmd) { return [bool](Get-Command $cmd -ErrorAction SilentlyContinue) }

# Lista os dispositivos que o Flutter enxerga e deixa escolher (Enter = o primeiro).
function EscolherDispositivo {
    # O ForEach-Object desembrulha a lista: no PowerShell 5 o ConvertFrom-Json devolve o array como 1 objeto só.
    $lista = @(flutter devices --machine 2>$null | Out-String | ConvertFrom-Json | ForEach-Object { $_ })
    if ($lista.Count -eq 0) { Falhou "Nenhum dispositivo encontrado. Ligue o emulador/celular ou rode 'flutter doctor'." }
    if ($lista.Count -eq 1) { Write-Host "Dispositivo: $($lista[0].name)"; return $lista[0].id }
    Write-Host "Dispositivos encontrados:"
    for ($i = 0; $i -lt $lista.Count; $i++) {
        Write-Host ("  [{0}] {1}  ({2}, {3})" -f ($i + 1), $lista[$i].name, $lista[$i].targetPlatform, $lista[$i].id)
    }
    $r = Read-Host "Escolha o número (Enter = 1)"
    $n = 1
    if ($r -and [int]::TryParse($r, [ref]$n) -and $n -ge 1 -and $n -le $lista.Count) { return $lista[$n - 1].id }
    return $lista[0].id
}

# 1. Ferramentas básicas
Passo "Conferindo ferramentas"
if (-not (Existe "flutter")) { Falhou "Flutter não encontrado. Instale em https://docs.flutter.dev/get-started/install" }
if (-not (Existe "dart"))    { Falhou "Dart não encontrado. Ele vem junto com o Flutter, confira o PATH." }
if (-not (Test-Path "lib\main.dart")) { Falhou "lib\main.dart não encontrado em $PSScriptRoot. Coloque o iniciar.* na raiz do projeto (junto do pubspec.yaml)." }

# 2. Plataformas (só cria se ainda não existirem)
if (-not (Test-Path "android") -or -not (Test-Path "ios") -or -not (Test-Path "web") -or -not (Test-Path "windows")) {
    Passo "Criando as plataformas android, ios, web e windows"
    # O nome da pasta pode ser inválido para pacote Dart (ex.: "Downloads"), então fixamos o nome.
    $nome = "rv_label"
    if (Test-Path "pubspec.yaml") {
        $m = Select-String -Path "pubspec.yaml" -Pattern '^name:\s*(\S+)' | Select-Object -First 1
        if ($m) { $nome = $m.Matches[0].Groups[1].Value }
    }
    flutter create . --project-name $nome --platforms=android,ios,web,windows
    if ($LASTEXITCODE -ne 0) { Falhou "flutter create falhou." }
}

# 3. Dependências
Passo "Baixando dependências"
flutter pub get
if ($LASTEXITCODE -ne 0) { Falhou "flutter pub get falhou." }

# 4. Assistente de IA (Firebase AI Logic + App Check)
$tokenArquivo = ".appcheck-token"
$token = ""
if (-not $SemIA) {
    $opcoes = "lib\firebase_options.dart"
    $temWindows = (Test-Path $opcoes) -and (Select-String -Path $opcoes -Pattern 'static const FirebaseOptions windows' -Quiet)

    if ($ReconfigurarIA -or -not $temWindows) {
        if (-not (Existe "firebase")) {
            if (Existe "npm") {
                Passo "Instalando o Firebase CLI"
                npm install -g firebase-tools
            } else {
                Falhou "Firebase CLI ausente e o npm não foi encontrado. Instale o Node.js e rode de novo."
            }
        }

        Passo "Login no Firebase"
        $logado = (firebase login:list 2>&1) -notmatch "No authorized accounts"
        if (-not $logado) { firebase login }

        Passo "Instalando o FlutterFire CLI"
        dart pub global activate flutterfire_cli
        $env:PATH += ";$env:LOCALAPPDATA\Pub\Cache\bin;$env:APPDATA\Pub\Cache\bin"

        Passo "Configurando o projeto Firebase"
        flutterfire configure --platforms=android,ios,web,windows
        if ($LASTEXITCODE -ne 0) { Falhou "flutterfire configure falhou." }

        Write-Host "`nÚltimo passo manual (só na primeira vez):" -ForegroundColor Yellow
        Write-Host "ative o Firebase AI Logic no console: https://console.firebase.google.com/ > seu projeto > AI Logic"
        Read-Host "Aperte Enter quando tiver ativado"
    } else {
        Write-Host "Firebase já configurado ($opcoes). Pulando."
    }

    # Token de debug do App Check: gerado uma vez e guardado fora do Git.
    $novoToken = $false
    if (-not (Test-Path $tokenArquivo)) {
        [guid]::NewGuid().ToString() | Set-Content -Path $tokenArquivo -Encoding ascii
        $novoToken = $true
    }
    $token = (Get-Content $tokenArquivo -Raw).Trim()
    if ($novoToken) {
        Write-Host "`nToken de debug do App Check criado. Cadastre-o uma vez no console:" -ForegroundColor Yellow
        Write-Host "App Check > Apps > (cada app: android, ios, web, windows) > ... > Gerenciar tokens de debug > Adicionar"
        Write-Host "Token: $token"
        Read-Host "Aperte Enter quando tiver cadastrado"
    }
}

# 5. Rodar
Passo "Escolhendo o dispositivo"
if (-not $Dispositivo) { $Dispositivo = EscolherDispositivo }
Passo "Iniciando o app em $Dispositivo"
$argsRun = @("run", "-d", $Dispositivo)
if ($token) { $argsRun += "--dart-define=APP_CHECK_DEBUG_TOKEN=$token" }
flutter @argsRun
