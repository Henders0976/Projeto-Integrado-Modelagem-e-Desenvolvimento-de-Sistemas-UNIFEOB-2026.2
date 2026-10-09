import 'package:flutter/material.dart';

import '../models/models.dart';
import 'tema.dart';

/// Opção de escolha (categoria, cor, tamanho): cheia quando selecionada,
/// só contorno nas outras, com transição suave. Alvo de toque de pelo menos 44 px.
class PilulaEscolha extends StatelessWidget {
  const PilulaEscolha({
    super.key,
    required this.rotulo,
    required this.selecionada,
    required this.aoTocar,
  });

  final String rotulo;
  final bool selecionada;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) {
    final duracao = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    return Semantics(
      button: true,
      selected: selecionada,
      child: AnimatedContainer(
        duration: duracao,
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selecionada ? corTexto : Colors.transparent,
          borderRadius: BorderRadius.circular(2),
          border: Border.all(color: selecionada ? corTexto : corLinha),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: aoTocar,
            borderRadius: BorderRadius.circular(2),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  widthFactor: 1,
                  child: AnimatedDefaultTextStyle(
                    duration: duracao,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: selecionada ? corPreto : corTexto,
                    ),
                    child: Text(rotulo),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Bolinha de cor: recorte da própria foto da peça com a cor aplicada,
/// então mostra exatamente o que a cliente vai ver. Anel quando selecionada.
class AmostraCor extends StatelessWidget {
  const AmostraCor({
    super.key,
    required this.foto,
    required this.variante,
    required this.selecionada,
    required this.aoTocar,
    this.tamanho = 44,
  });

  final String? foto;
  final VarianteCor variante;
  final bool selecionada;
  final VoidCallback aoTocar;
  final double tamanho;

  @override
  Widget build(BuildContext context) {
    final duracao = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    Widget miolo = foto == null
        ? const ColoredBox(color: Color(0x33FFFFFF))
        : Image.asset(foto!,
            fit: BoxFit.cover,
            alignment: const Alignment(0, -0.1),
            errorBuilder: (_, __, ___) => const ColoredBox(color: Color(0x33FFFFFF)));
    if (foto != null) miolo = variante.aplicar(miolo);
    return Semantics(
      button: true,
      selected: selecionada,
      label: 'Cor ${variante.nome}',
      child: Tooltip(
        message: variante.nome,
        child: GestureDetector(
          onTap: aoTocar,
          child: MouseRegion(
            cursor: SystemMouseCursors.click,
            child: AnimatedContainer(
              duration: duracao,
              curve: Curves.easeOutCubic,
              width: tamanho + 10,
              height: tamanho + 10,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: selecionada ? corTexto : Colors.transparent, width: 2),
              ),
              child: ClipOval(child: miolo),
            ),
          ),
        ),
      ),
    );
  }
}

/// Seletor de quantidade: menos, número, mais, dentro de um contorno só.
class SeletorQuantidade extends StatelessWidget {
  const SeletorQuantidade({
    super.key,
    required this.quantidade,
    required this.aoMudar,
    this.minimo = 1,
  });

  final int quantidade;
  final ValueChanged<int> aoMudar;
  final int minimo;

  @override
  Widget build(BuildContext context) => DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: corLinha),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            tooltip: 'Diminuir',
            icon: const Icon(Icons.remove, size: 18),
            onPressed:
                quantidade > minimo ? () => aoMudar(quantidade - 1) : null,
          ),
          SizedBox(
            width: 28,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              transitionBuilder: (filho, a) => FadeTransition(
                opacity: a,
                child: ScaleTransition(scale: Tween(begin: 0.7, end: 1.0).animate(a), child: filho),
              ),
              child: Text('$quantidade',
                  key: ValueKey(quantidade),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontFeatures: [FontFeature.tabularFigures()])),
            ),
          ),
          IconButton(
            tooltip: 'Aumentar',
            icon: const Icon(Icons.add, size: 18),
            onPressed: () => aoMudar(quantidade + 1),
          ),
        ]),
      );
}

/// Mostra a foto (asset), já recolorida pela [variante], ou um espaço
/// reservado ("Foto em breve") enquanto não há foto. Com [heroTag] a foto
/// "voa" do cartão para a tela da peça.
Widget fotoOuPlaceholder(String? caminho,
    {VarianteCor? variante, String? heroTag}) {
  const vazio = Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.checkroom, size: 44, color: corTextoSuave),
      SizedBox(height: 6),
      Text('Foto em breve', style: TextStyle(color: corTextoSuave, fontSize: 12)),
    ],
  );
  Widget conteudo = caminho == null
      ? vazio
      : Image.asset(caminho,
          fit: BoxFit.cover,
          alignment: const Alignment(0, -0.5), // rosto fica no enquadramento
          errorBuilder: (_, __, ___) => vazio);
  if (caminho != null && variante != null) conteudo = variante.aplicar(conteudo);
  final quadro = Container(
    width: double.infinity,
    decoration: BoxDecoration(
      color: const Color(0x1AFFFFFF),
      borderRadius: BorderRadius.circular(raioPadrao),
    ),
    clipBehavior: Clip.antiAlias,
    child: conteudo,
  );
  return heroTag == null ? quadro : Hero(tag: heroTag, child: quadro);
}
