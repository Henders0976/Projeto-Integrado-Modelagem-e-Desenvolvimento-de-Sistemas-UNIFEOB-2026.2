import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';

import '../ia/assistente_page.dart';
import '../models/models.dart';
import '../services/catalogo_repository.dart';
import '../services/sacola.dart';
import '../services/whatsapp_service.dart';
import 'admin_page.dart';
import 'componentes.dart';
import 'efeitos.dart';
import 'fundo_liquido.dart';
import 'meus_pedidos_page.dart';
import 'peca_page.dart';
import 'privacidade_page.dart';
import 'sacola_page.dart';
import 'tema.dart';

/// Largura máxima do conteúdo (web e desktop); no celular ocupa a tela toda.
const _larguraMax = 1100.0;
const _numerosAlinhados = [FontFeature.tabularFigures()];
const _alturaBarra = kToolbarHeight + 8;

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    required this.catalogo,
    required this.sacola,
    required this.whatsapp,
    this.iaDisponivel = false,
  });

  final CatalogoRepository catalogo;
  final Sacola sacola;
  final WhatsAppService whatsapp;
  final bool iaDisponivel;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Categoria? _filtro; // null = "Todos"
  final _chaveColecao = GlobalKey();
  final _chaveComo = GlobalKey();
  final _rolagem = ScrollController();
  final _y = ValueNotifier<double>(0); // posição da rolagem, para os efeitos

  @override
  void initState() {
    super.initState();
    _rolagem.addListener(() => _y.value = _rolagem.offset);
  }

  @override
  void dispose() {
    _rolagem.dispose();
    _y.dispose();
    super.dispose();
  }

  void _abrirPeca(Produto peca) => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PecaPage(peca: peca, sacola: widget.sacola),
        ),
      );

  void _irPara(GlobalKey chave) {
    final alvo = chave.currentContext;
    if (alvo == null) return;
    final reduzir = MediaQuery.disableAnimationsOf(context);
    Scrollable.ensureVisible(alvo,
        alignment: 0.05,
        duration: reduzir ? Duration.zero : const Duration(milliseconds: 750),
        curve: Curves.easeInOutCubic);
  }

  void _irParaTopo() {
    final reduzir = MediaQuery.disableAnimationsOf(context);
    _rolagem.animateTo(0,
        duration: reduzir ? Duration.zero : const Duration(milliseconds: 800),
        curve: Curves.easeInOutCubic);
  }

  /// Peça da campanha no topo: a blusa de um ombro com laço; se ela sair do
  /// catálogo, vale a primeira peça que tiver foto.
  Produto? get _destaque =>
      widget.catalogo.buscarPorId('essence-005') ??
      widget.catalogo.todas().where((p) => p.fotos.isNotEmpty).firstOrNull;

  void _abrirIa() => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => widget.iaDisponivel
              ? AssistentePage(catalogo: widget.catalogo, sacola: widget.sacola)
              : const _IaIndisponivel(),
        ),
      );

  /// Acesso à área administrativa: toque longo no logo. Não aparece para clientes.
  void _abrirAdmin() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => AdminPage(catalogo: widget.catalogo)),
      );

  @override
  Widget build(BuildContext context) {
    final pecas = widget.catalogo.porCategoria(_filtro);
    final largura = MediaQuery.sizeOf(context).width;
    final lateral = ((largura - _larguraMax) / 2).clamp(0.0, double.infinity) + 24;
    final reduzir = MediaQuery.disableAnimationsOf(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(_alturaBarra),
        child: _barra(context),
      ),
      floatingActionButton: ValueListenableBuilder<double>(
        valueListenable: _y,
        builder: (_, y, __) => AnimatedScale(
          scale: y > 700 ? 1 : 0,
          duration: reduzir ? Duration.zero : const Duration(milliseconds: 250),
          curve: Curves.easeOutBack,
          child: FloatingActionButton.small(
            tooltip: 'Voltar ao topo',
            backgroundColor: corTexto,
            foregroundColor: corPreto,
            shape: const CircleBorder(),
            onPressed: _irParaTopo,
            child: const Icon(Icons.arrow_upward),
          ),
        ),
      ),
      body: FundoLiquido(
        child: CustomScrollView(
          controller: _rolagem,
          slivers: [
            SliverToBoxAdapter(child: _hero(context)),
            const SliverToBoxAdapter(
              child: FaixaRolante(textos: [
                'Coleção Essence',
                'Peças únicas',
                'Pequenos lotes',
                'Feito com carinho',
              ]),
            ),
            SliverToBoxAdapter(child: _tituloColecao(context, pecas.length)),
            SliverToBoxAdapter(child: _filtros(lateral)),
            if (pecas.isEmpty)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('Ainda não temos peças nessa categoria.',
                      textAlign: TextAlign.center),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(lateral, 8, lateral, 8),
                sliver: SliverGrid.builder(
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 270,
                    childAspectRatio: 0.54,
                    crossAxisSpacing: 18,
                    mainAxisSpacing: 32,
                  ),
                  itemCount: pecas.length,
                  itemBuilder: (_, i) => Revelar(
                    // A chave inclui o filtro: ao trocar de categoria os cartões entram de novo.
                    key: ValueKey('${_filtro?.name}-${pecas[i].id}'),
                    atraso: Duration(milliseconds: (i % 4) * 90),
                    child: _CartaoPeca(
                      peca: pecas[i],
                      aoTocar: () => _abrirPeca(pecas[i]),
                    ),
                  ),
                ),
              ),
            SliverToBoxAdapter(child: _sobre(context)),
            SliverToBoxAdapter(child: _comoComprar(context)),
            SliverToBoxAdapter(child: _rodape(context)),
          ],
        ),
      ),
    );
  }

  // ---------- barra do topo: transparente sobre o hero, vidro fosco ao rolar ----------

  Widget _barra(BuildContext context) => ValueListenableBuilder<double>(
        valueListenable: _y,
        builder: (_, y, __) {
          final t = (y / 140).clamp(0.0, 1.0);
          final max = _rolagem.hasClients ? _rolagem.position.maxScrollExtent : 0.0;
          final progresso = max > 0 ? (y / max).clamp(0.0, 1.0) : 0.0;
          return ClipRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18 * t, sigmaY: 18 * t),
              child: Container(
                decoration: BoxDecoration(
                  color: corPreto.withValues(alpha: 0.6 * t),
                  border: Border(
                      bottom: BorderSide(color: corLinha.withValues(alpha: 0.5 * t))),
                ),
                child: Stack(children: [
                  SafeArea(
                    bottom: false,
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: _larguraMax + 48),
                        child: SizedBox(
                          height: _alturaBarra,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(children: [
                              GestureDetector(
                                onLongPress: _abrirAdmin,
                                behavior: HitTestBehavior.opaque,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 10),
                                  child: Text('RV·LABEL',
                                      style: TextStyle(
                                          fontFamily: fonteTitulo,
                                          fontSize: 28 - 6 * t,
                                          letterSpacing: 4)),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                tooltip: 'Assistente RV (IA)',
                                icon: const Icon(Icons.auto_awesome),
                                onPressed: _abrirIa,
                              ),
                              IconButton(
                                tooltip: 'Meus pedidos',
                                icon: const Icon(Icons.receipt_long_outlined),
                                onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const MeusPedidosPage())),
                              ),
                              ListenableBuilder(
                                listenable: widget.sacola,
                                builder: (_, __) => PulsoAoMudar(
                                  valor: widget.sacola.quantidadeTotal,
                                  child: Badge(
                                    isLabelVisible: !widget.sacola.vazia,
                                    label: Text('${widget.sacola.quantidadeTotal}'),
                                    child: IconButton(
                                      tooltip: 'Sacola',
                                      icon: const Icon(Icons.shopping_bag_outlined),
                                      onPressed: () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SacolaPage(
                                              sacola: widget.sacola,
                                              whatsapp: widget.whatsapp),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Barra fina de progresso da página.
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: t,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: FractionallySizedBox(
                          widthFactor: progresso,
                          child: const SizedBox(
                              height: 2, child: ColoredBox(color: corTexto)),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          );
        },
      );

  // ---------- hero ----------

  Widget _hero(BuildContext context) {
    final destaque = _destaque;
    final altura = MediaQuery.sizeOf(context).height;
    final topo = MediaQuery.paddingOf(context).top + _alturaBarra;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _larguraMax),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, topo + 24, 24, 56),
          child: LayoutBuilder(builder: (context, caixa) {
            final largo = caixa.maxWidth >= 820;
            final tema = Theme.of(context).textTheme;
            final texto = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Revelar(
                  child: Text('COLEÇÃO',
                      style: TextStyle(
                          color: corTextoSuave, fontSize: 13, letterSpacing: 5)),
                ),
                const SizedBox(height: 14),
                Revelar(
                  atraso: const Duration(milliseconds: 120),
                  child: Text('RV·LABEL Essence',
                      style: (largo ? tema.displayLarge : tema.displayMedium)
                          ?.copyWith(
                              fontFamily: fonteTitulo,
                              fontSize: largo ? 76 : 50,
                              height: 1.02,
                              letterSpacing: -1.5)),
                ),
                const SizedBox(height: 24),
                Revelar(
                  atraso: const Duration(milliseconds: 260),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: const Text(
                      'Cortes assimétricos, um ombro só, decotes que respiram. A '
                      'essência da marca em peças feitas em lote pequeno, '
                      'pensadas pra durar no guarda-roupa e no visual.',
                      style: TextStyle(fontSize: 17, height: 1.55),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                const Revelar(
                  atraso: Duration(milliseconds: 340),
                  child: Text('Peças únicas, feitas pra você.',
                      style: TextStyle(color: corTextoSuave, fontSize: 15)),
                ),
                const SizedBox(height: 32),
                Revelar(
                  atraso: const Duration(milliseconds: 420),
                  child: Wrap(spacing: 12, runSpacing: 12, children: [
                    FilledButton(
                        onPressed: () => _irPara(_chaveColecao),
                        child: const Text('Ver peças disponíveis')),
                    OutlinedButton(
                        onPressed: () => _irPara(_chaveComo),
                        child: const Text('Como comprar')),
                  ]),
                ),
              ],
            );
            // Ao rolar, o texto sobe e some devagar e a foto desce mais devagar (parallax).
            final textoComEfeito = ValueListenableBuilder<double>(
              valueListenable: _y,
              child: texto,
              builder: (_, y, filho) => Opacity(
                opacity: (1 - y / 560).clamp(0.0, 1.0),
                child: Transform.translate(offset: Offset(0, -y * 0.16), child: filho),
              ),
            );
            if (destaque == null) return textoComEfeito;
            final foto = ValueListenableBuilder<double>(
              valueListenable: _y,
              child: Revelar(
                atraso: const Duration(milliseconds: 300),
                deslocamento: 56,
                child: _FotoDestaque(
                    peca: destaque, aoTocar: () => _abrirPeca(destaque)),
              ),
              builder: (_, y, filho) =>
                  Transform.translate(offset: Offset(0, y * 0.1), child: filho),
            );
            if (!largo) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                textoComEfeito,
                const SizedBox(height: 40),
                foto,
              ]);
            }
            return ConstrainedBox(
              constraints: BoxConstraints(minHeight: altura * 0.62),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(flex: 5, child: textoComEfeito),
                  const SizedBox(width: 56),
                  Expanded(flex: 4, child: foto),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------- coleção ----------

  Widget _tituloColecao(BuildContext context, int quantidade) => Center(
        key: _chaveColecao,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _larguraMax),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 72, 24, 0),
            child: Revelar(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('A coleção Essence',
                            style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 10),
                        const Text(
                            'Toque numa peça pra abrir em detalhe, virar a foto e '
                            'escolher a cor. Filtre por categoria logo abaixo.',
                            style: TextStyle(color: corTextoSuave, fontSize: 16)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Text('$quantidade ${quantidade == 1 ? 'peça' : 'peças'}',
                        key: ValueKey(quantidade),
                        style: const TextStyle(
                            color: corTextoSuave, fontFeatures: _numerosAlinhados)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  Widget _filtros(double lateral) => Padding(
        padding: const EdgeInsets.only(top: 24, bottom: 16),
        child: SizedBox(
          height: 48,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: lateral),
            children: [
              _chip('Todos', null),
              for (final c in Categoria.values) _chip(c.rotulo, c),
            ],
          ),
        ),
      );

  Widget _chip(String rotulo, Categoria? valor) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: PilulaEscolha(
          rotulo: rotulo,
          selecionada: _filtro == valor,
          aoTocar: () => setState(() => _filtro = valor),
        ),
      );

  // ---------- seções de texto (copy do site original) ----------

  Widget _sobre(BuildContext context) {
    final tema = Theme.of(context).textTheme;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _larguraMax),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 112, 24, 0),
          child: LayoutBuilder(builder: (context, caixa) {
            final largo = caixa.maxWidth >= 820;
            final titulo = Revelar(
              child: Text('Roupa que veste história, não tendência.',
                  style: tema.headlineMedium?.copyWith(
                      fontSize: largo ? 46 : 32, height: 1.1, letterSpacing: -0.8)),
            );
            final corpo = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Revelar(
                  atraso: Duration(milliseconds: 150),
                  child: Text(
                    'A RV Label nasceu da vontade de fazer moda com identidade — '
                    'peças pensadas com carinho, produzidas em pequenos lotes e '
                    'feitas pra durar. Cada compra é combinada direto com você, '
                    'sem intermediário, sem pressa.',
                    style: TextStyle(fontSize: 17, height: 1.6),
                  ),
                ),
                const SizedBox(height: 28),
                for (final (i, p) in const [
                  (Icons.layers_outlined, 'Pequenos lotes', 'Produzidas com carinho, sem pressa.'),
                  (Icons.diamond_outlined, 'Peças únicas', 'Cortes assimétricos, com identidade.'),
                  (Icons.chat_bubble_outline, 'Atendimento direto', 'Cada compra combinada com você, sem intermediário.'),
                ].indexed)
                  Revelar(
                    atraso: Duration(milliseconds: 250 + i * 110),
                    child: _Pilar(icone: p.$1, titulo: p.$2, texto: p.$3),
                  ),
              ],
            );
            if (!largo) {
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                titulo,
                const SizedBox(height: 28),
                corpo,
              ]);
            }
            return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 5, child: titulo),
              const SizedBox(width: 64),
              Expanded(flex: 4, child: corpo),
            ]);
          }),
        ),
      ),
    );
  }

  Widget _comoComprar(BuildContext context) => Center(
        key: _chaveComo,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: _larguraMax),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 112, 24, 0),
            child: LayoutBuilder(builder: (context, caixa) {
              final largo = caixa.maxWidth >= 760;
              const passos = [
                (Icons.checkroom_outlined, 'Escolha a peça, a cor e o tamanho.'),
                (Icons.shopping_bag_outlined, 'Adicione à sacola.'),
                (Icons.chat_outlined,
                    'Feche o pedido pelo WhatsApp e combine tudo direto com a marca.'),
              ];
              final cartoes = [
                for (final (i, p) in passos.indexed)
                  Revelar(
                    atraso: Duration(milliseconds: 120 + i * 130),
                    child: _CartaoPasso(numero: '${i + 1}', icone: p.$1, texto: p.$2),
                  ),
              ];
              return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Revelar(
                  child: Text('Como comprar',
                      style: Theme.of(context).textTheme.headlineMedium),
                ),
                const SizedBox(height: 28),
                if (largo)
                  IntrinsicHeight(
                    child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      for (final (i, c) in cartoes.indexed) ...[
                        if (i > 0) const SizedBox(width: 16),
                        Expanded(child: c),
                      ],
                    ]),
                  )
                else
                  for (final (i, c) in cartoes.indexed) ...[
                    if (i > 0) const SizedBox(height: 12),
                    c,
                  ],
              ]);
            }),
          ),
        ),
      );

  Widget _rodape(BuildContext context) {
    Widget link(String texto, VoidCallback aoTocar) => Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                minimumSize: const Size(0, 36),
                foregroundColor: corTextoSuave),
            onPressed: aoTocar,
            child: Text(texto),
          ),
        );
    Widget coluna(String titulo, List<Widget> itens) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(titulo.toUpperCase(),
                style: const TextStyle(letterSpacing: 3, fontSize: 12, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            ...itens,
          ],
        );
    const marca = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('RV·LABEL',
            style: TextStyle(fontFamily: fonteTitulo, fontSize: 28, letterSpacing: 4)),
        SizedBox(height: 12),
        Text(
            'Peças únicas para o seu estilo. Produção em pequenos lotes, '
            'atendimento direto pelo WhatsApp, sem letra miúda.',
            style: TextStyle(color: corTextoSuave, height: 1.55)),
      ],
    );
    final loja = coluna('Loja', [
      link('Coleção Essence', () => _irPara(_chaveColecao)),
      link('Como comprar', () => _irPara(_chaveComo)),
    ]);
    final ajuda = coluna('Ajuda', [
      link('Meus pedidos', () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const MeusPedidosPage()))),
      link('Privacidade e termos', () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const PrivacidadePage()))),
      link('Falar no WhatsApp',
          () => widget.whatsapp.enviar('Olá, RV Label! Gostaria de tirar uma dúvida.')),
    ]);
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _larguraMax),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 112, 24, 40),
          child: LayoutBuilder(builder: (context, caixa) {
            final largo = caixa.maxWidth >= 760;
            return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Divider(),
              const SizedBox(height: 40),
              if (largo)
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Expanded(flex: 4, child: marca),
                  const SizedBox(width: 48),
                  Expanded(flex: 2, child: loja),
                  Expanded(flex: 2, child: ajuda),
                ])
              else ...[
                marca,
                const SizedBox(height: 32),
                loja,
                const SizedBox(height: 24),
                ajuda,
              ],
              const SizedBox(height: 40),
              const Text('© 2026 RV Label · Feito com carinho, peça por peça',
                  style: TextStyle(color: corTextoSuave, fontSize: 13)),
            ]);
          }),
        ),
      ),
    );
  }
}

/// Item da lista "por que a RV Label" na seção Sobre.
class _Pilar extends StatelessWidget {
  const _Pilar({required this.icone, required this.titulo, required this.texto});
  final IconData icone;
  final String titulo;
  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 18),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: corLinha),
            ),
            child: Icon(icone, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(titulo, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(texto, style: const TextStyle(color: corTextoSuave, height: 1.4)),
            ]),
          ),
        ]),
      );
}

/// Passo do "Como comprar": número grande, ícone e texto, num cartão que sobe no hover.
class _CartaoPasso extends StatefulWidget {
  const _CartaoPasso({required this.numero, required this.icone, required this.texto});
  final String numero;
  final IconData icone;
  final String texto;

  @override
  State<_CartaoPasso> createState() => _CartaoPassoState();
}

class _CartaoPassoState extends State<_CartaoPasso> {
  bool _sobre = false;

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.disableAnimationsOf(context);
    return MouseRegion(
      onEnter: (_) => setState(() => _sobre = true),
      onExit: (_) => setState(() => _sobre = false),
      child: AnimatedContainer(
        duration: reduzir ? Duration.zero : const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        transform: Matrix4.translationValues(0, _sobre ? -6 : 0, 0),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Color(_sobre ? 0x26FFFFFF : 0x14FFFFFF),
          borderRadius: BorderRadius.circular(raioPadrao),
          border: Border.all(color: _sobre ? corTexto : corLinha),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text(widget.numero,
                style: const TextStyle(fontFamily: fonteTitulo, fontSize: 56, height: 1)),
            Icon(widget.icone, color: corTextoSuave),
          ]),
          const SizedBox(height: 18),
          Text(widget.texto, style: const TextStyle(fontSize: 16, height: 1.5)),
        ]),
      ),
    );
  }
}

/// Foto grande da campanha, com moldura deslocada, nome e preço sobre um degradê escuro.
class _FotoDestaque extends StatelessWidget {
  const _FotoDestaque({required this.peca, required this.aoTocar});
  final Produto peca;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: '${peca.nome}, ${peca.precoFormatado}. Abrir peça',
        child: ExcludeSemantics(
          child: Padding(
            padding: const EdgeInsets.only(right: 16, bottom: 16),
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: Stack(clipBehavior: Clip.none, children: [
                // moldura fina deslocada atrás da foto
                Positioned.fill(
                  left: 16,
                  top: 16,
                  right: -16,
                  bottom: -16,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(raioPadrao),
                      border: Border.all(color: corLinha),
                    ),
                  ),
                ),
                Positioned.fill(
                  child: Stack(fit: StackFit.expand, children: [
                    fotoOuPlaceholder(peca.fotos.firstOrNull,
                        variante: peca.cores.first),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(raioPadrao),
                        gradient: const LinearGradient(
                          begin: Alignment(0, 0.1),
                          end: Alignment.bottomCenter,
                          colors: [Color(0x000B0B0B), Color(0xD90B0B0B)],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(peca.nome,
                              style: const TextStyle(
                                  fontFamily: fonteTitulo, fontSize: 24, height: 1.1)),
                          const SizedBox(height: 4),
                          Text(peca.precoFormatado,
                              style: const TextStyle(
                                  color: corTextoSuave,
                                  fontFeatures: _numerosAlinhados)),
                        ],
                      ),
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: aoTocar,
                        borderRadius: BorderRadius.circular(raioPadrao),
                        focusColor: Colors.white12,
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );
}

/// Cartão da vitrine: a foto dá zoom no hover, aparece "Ver peça" e as cores
/// disponíveis aparecem como bolinhas (recortes da própria foto).
class _CartaoPeca extends StatefulWidget {
  const _CartaoPeca({required this.peca, required this.aoTocar});
  final Produto peca;
  final VoidCallback aoTocar;

  @override
  State<_CartaoPeca> createState() => _CartaoPecaState();
}

class _CartaoPecaState extends State<_CartaoPeca> {
  bool _sobre = false; // mouse em cima (web e desktop)

  @override
  Widget build(BuildContext context) {
    final p = widget.peca;
    final reduzir = MediaQuery.disableAnimationsOf(context);
    final dur = reduzir ? Duration.zero : const Duration(milliseconds: 260);
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _sobre = true),
      onExit: (_) => setState(() => _sobre = false),
      child: Semantics(
        button: true,
        label: '${p.nome}, ${p.precoFormatado}'
            '${p.cores.length > 1 ? ', ${p.cores.length} cores' : ''}',
        child: ExcludeSemantics(
          child: InkWell(
            onTap: widget.aoTocar,
            borderRadius: BorderRadius.circular(raioPadrao),
            hoverColor: Colors.transparent,
            focusColor: Colors.white12,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: AnimatedContainer(
                    duration: dur,
                    curve: Curves.easeOutCubic,
                    transform: Matrix4.translationValues(0, _sobre ? -6 : 0, 0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(raioPadrao),
                      boxShadow: [
                        BoxShadow(
                          color: Color(_sobre ? 0x73000000 : 0x29000000),
                          blurRadius: _sobre ? 30 : 14,
                          offset: Offset(0, _sobre ? 16 : 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(raioPadrao),
                      child: Stack(fit: StackFit.expand, children: [
                        AnimatedScale(
                          scale: _sobre ? 1.07 : 1,
                          duration: reduzir ? Duration.zero : const Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic,
                          child: fotoOuPlaceholder(p.fotos.firstOrNull,
                              variante: p.cores.first, heroTag: 'foto-${p.id}'),
                        ),
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: AnimatedSlide(
                            duration: dur,
                            curve: Curves.easeOutCubic,
                            offset: Offset(0, _sobre ? 0 : 1),
                            child: AnimatedOpacity(
                              duration: dur,
                              opacity: _sobre ? 1 : 0,
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [Color(0x000B0B0B), Color(0xCC0B0B0B)],
                                  ),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text('VER PEÇA',
                                        style: TextStyle(
                                            fontSize: 12,
                                            letterSpacing: 3,
                                            fontWeight: FontWeight.w600)),
                                    SizedBox(width: 8),
                                    Icon(Icons.arrow_forward, size: 14),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ]),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(p.nome,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: fonteTitulo, fontSize: 19, height: 1.15)),
                const SizedBox(height: 4),
                Text(p.precoFormatado,
                    style: const TextStyle(
                        color: corTextoSuave,
                        fontSize: 14,
                        fontFeatures: _numerosAlinhados)),
                if (p.cores.length > 1) ...[
                  const SizedBox(height: 8),
                  Wrap(spacing: 0, children: [
                    for (final c in p.cores.take(5))
                      AmostraCor(
                        foto: p.fotos.firstOrNull,
                        variante: c,
                        selecionada: false,
                        tamanho: 12,
                        aoTocar: widget.aoTocar,
                      ),
                    if (p.cores.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(left: 4, top: 3),
                        child: Text('+${p.cores.length - 5}',
                            style: const TextStyle(color: corTextoSuave, fontSize: 12)),
                      ),
                  ]),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Tela mostrada se o Firebase ainda não foi configurado (`flutterfire configure`).
class _IaIndisponivel extends StatelessWidget {
  const _IaIndisponivel();

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Assistente RV')),
        body: const Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('O assistente de IA precisa do Firebase configurado.\n'
                'Rode "flutterfire configure" na pasta do projeto e reabra o app.'),
          ),
        ),
      );
}
