import 'package:flutter/material.dart';

import '../models/models.dart';
import 'componentes.dart';
import 'efeitos.dart';
import 'fundo_liquido.dart';
import 'rolagem_suave.dart';
import 'tema.dart';

const _larguraMax = 1100.0;

/// Uma coleção da vitrine: agrupa categorias do catálogo e traz o texto da página.
class Colecao {
  const Colecao({
    required this.chamada,
    required this.titulo,
    required this.frase,
    required this.textos,
    required this.fecho,
    required this.fechoTexto,
    required this.categorias,
  });

  final String chamada;
  final String titulo;
  final String frase;
  final List<String> textos;
  final String fecho;
  final String fechoTexto;
  final List<Categoria> categorias;

  bool contem(Produto p) => categorias.contains(p.categoria);
}

const colecoes = [
  Colecao(
    chamada: 'Explore',
    titulo: 'Parte de cima',
    frase: 'Um ombro só, um laço, um recorte.',
    textos: [
      'Blusas, tops e bodys da coleção Essence: cortes assimétricos e decotes '
          'que respiram, pensados pra valorizar sem esforço.',
      'Cada peça é produzida em pequeno lote. Escolha a cor e o tamanho, '
          'adicione à sacola e feche tudo direto com a marca.',
    ],
    fecho: 'Monte o seu look',
    fechoTexto: 'Combine com shorts e vestidos da coleção — as cores conversam entre si.',
    categorias: [Categoria.blusas, Categoria.tops, Categoria.bodys],
  ),
  Colecao(
    chamada: 'Complete o look',
    titulo: 'Vestidos e mais',
    frase: 'Pra quando a peça é o look inteiro.',
    textos: [
      'Vestidos, shorts e acessórios da Essence. Costas nuas, fendas e '
          'alfaiataria: identidade em cada detalhe.',
      'Mistura à vontade entre as coleções. Tudo é feito em lote pequeno, '
          'então vale garantir a sua enquanto há tamanho.',
    ],
    fecho: 'Dúvida de tamanho?',
    fechoTexto: 'Chame a RV Label no WhatsApp e a gente ajuda a escolher.',
    categorias: [Categoria.vestidos, Categoria.shorts, Categoria.acessorios],
  ),
];

/// Primeira foto disponível entre as peças, ou null se nenhuma tiver foto.
String? primeiraFoto(Iterable<Produto> pecas) =>
    pecas.where((p) => p.fotos.isNotEmpty).firstOrNull?.fotos.first;

/// Tela de uma coleção: foto grande com título, texto, grade de peças e um fecho.
/// O [cartao] vem da vitrine, para a peça abrir igual em todo lugar.
class ColecaoPage extends StatelessWidget {
  const ColecaoPage({
    super.key,
    required this.colecao,
    required this.pecas,
    required this.cartao,
  });

  final Colecao colecao;
  final List<Produto> pecas;
  final Widget Function(Produto) cartao;

  @override
  Widget build(BuildContext context) {
    final tela = MediaQuery.sizeOf(context);
    final lateral = ((tela.width - _larguraMax) / 2).clamp(0.0, double.infinity) + 24;
    final tema = Theme.of(context).textTheme;
    Widget centro(Widget filho) => Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760), child: filho),
        );
    return Scaffold(
      appBar: AppBar(title: Text(colecao.titulo)),
      body: FundoLiquido(
        child: ListaSuave(children: [
          SizedBox(
            height: (tela.height * 0.5).clamp(280.0, 520.0),
            child: Stack(fit: StackFit.expand, children: [
              ParallaxFoto(
                  intensidade: 70,
                  escala: 1.3,
                  child: fotoOuPlaceholder(primeiraFoto(pecas))),
              const ColoredBox(color: Color(0x73000000)),
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(colecao.chamada.toUpperCase(),
                        style: const TextStyle(fontSize: 13, letterSpacing: 5)),
                    const SizedBox(height: 14),
                    Text(colecao.titulo,
                        textAlign: TextAlign.center, style: tema.displaySmall),
                  ]),
                ),
              ),
            ]),
          ),
          centro(Padding(
            padding: const EdgeInsets.fromLTRB(24, 64, 24, 0),
            child: AoRolar(
              child: Column(children: [
                Text(colecao.frase,
                    textAlign: TextAlign.center, style: tema.headlineMedium),
                const SizedBox(height: 24),
                for (final t in colecao.textos) ...[
                  Text(t,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 17, height: 1.6)),
                  const SizedBox(height: 16),
                ],
              ]),
            ),
          )),
          if (pecas.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('Ainda não temos peças nessa coleção.',
                  textAlign: TextAlign.center),
            )
          else
            Padding(
              padding: EdgeInsets.fromLTRB(lateral, 40, lateral, 0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 270,
                  childAspectRatio: 0.54,
                  crossAxisSpacing: 18,
                  mainAxisSpacing: 32,
                ),
                itemCount: pecas.length,
                itemBuilder: (_, i) => AoRolar(
                  escalonar: (i % 4) * 0.1,
                  child: cartao(pecas[i]),
                ),
              ),
            ),
          centro(Padding(
            padding: const EdgeInsets.fromLTRB(24, 96, 24, 72),
            child: AoRolar(
              child: Column(children: [
                const Divider(),
                const SizedBox(height: 40),
                Text(colecao.fecho, style: tema.headlineSmall),
                const SizedBox(height: 12),
                Text(colecao.fechoTexto,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: corTextoSuave, fontSize: 16, height: 1.5)),
              ]),
            ),
          )),
        ]),
      ),
    );
  }
}

/// Cartão da coleção na vitrine: foto grande que dá zoom no hover, com a
/// chamada no alto e o título embaixo.
class CartaoColecao extends StatefulWidget {
  const CartaoColecao({
    super.key,
    required this.colecao,
    required this.foto,
    required this.aoTocar,
  });

  final Colecao colecao;
  final String? foto;
  final VoidCallback aoTocar;

  @override
  State<CartaoColecao> createState() => _CartaoColecaoState();
}

class _CartaoColecaoState extends State<CartaoColecao> {
  bool _sobre = false;

  @override
  Widget build(BuildContext context) {
    final reduzir = MediaQuery.disableAnimationsOf(context);
    final c = widget.colecao;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _sobre = true),
      onExit: (_) => setState(() => _sobre = false),
      child: Semantics(
        button: true,
        label: 'Coleção ${c.titulo}',
        child: ExcludeSemantics(
          child: AspectRatio(
            aspectRatio: 4 / 5,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(raioPadrao),
              child: Stack(fit: StackFit.expand, children: [
                AnimatedScale(
                  scale: _sobre ? 1.04 : 1,
                  duration:
                      reduzir ? Duration.zero : const Duration(milliseconds: 700),
                  curve: Curves.easeOutCubic,
                  child: ParallaxFoto(child: fotoOuPlaceholder(widget.foto)),
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Color(0x66000000), Color(0x1A000000), Color(0xB30B0B0B)],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.chamada.toUpperCase(),
                          style: const TextStyle(fontSize: 13, letterSpacing: 4)),
                      Text(c.titulo,
                          style: const TextStyle(
                              fontFamily: fonteTitulo, fontSize: 32, height: 1.1)),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(onTap: widget.aoTocar, focusColor: Colors.white12),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
