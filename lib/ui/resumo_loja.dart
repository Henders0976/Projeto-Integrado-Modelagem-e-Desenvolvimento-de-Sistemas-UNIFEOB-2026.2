import 'package:flutter/material.dart';

import '../core/resumo.dart';
import '../models/models.dart';
import 'efeitos.dart';
import 'tema.dart';

const _numerosAlinhados = [FontFeature.tabularFigures()];

/// Duas colunas no desktop (título à esquerda, conteúdo à direita) e uma só no celular.
class _DuasColunas extends StatelessWidget {
  const _DuasColunas({required this.titulo, required this.conteudo});

  final Widget titulo;
  final Widget conteudo;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, caixa) {
        if (caixa.maxWidth < 820) {
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            titulo,
            const SizedBox(height: 32),
            conteudo,
          ]);
        }
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(flex: 4, child: titulo),
          const SizedBox(width: 64),
          Expanded(flex: 7, child: conteudo),
        ]);
      });
}

/// Índice da coleção por categoria: quantas peças tem e quanto custam, e cada linha leva à vitrine já filtrada.
/// Tudo vem do catálogo ([ResumoLoja]), então acompanha o que está à venda. A linha que se desenha no hover é a
/// mesma "linha de tinta" do cabeçalho; as outras linhas se apagam um pouco, como na vitrine.
class IndiceCategorias extends StatefulWidget {
  const IndiceCategorias({super.key, required this.resumo, required this.aoEscolher});

  final ResumoLoja resumo;
  final void Function(Categoria) aoEscolher;

  @override
  State<IndiceCategorias> createState() => _IndiceCategoriasState();
}

class _IndiceCategoriasState extends State<IndiceCategorias> {
  Categoria? _sobre;

  @override
  Widget build(BuildContext context) {
    final r = widget.resumo;
    final faixa = faixaDePreco(r.menor, r.maior);
    final preco = faixa == null ? '' : (r.menor == r.maior ? ', por $faixa' : ', de $faixa');
    final titulo = AoRolar(
      deslocamento: const Offset(-48, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Tudo o que a Essence tem hoje',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.1)),
        const SizedBox(height: 16),
        Text(
            '${contar(r.total, 'peça', 'peças')} em ${contar(r.categorias.length, 'categoria', 'categorias')}'
            '$preco. Escolha por onde começar.',
            style: const TextStyle(color: corTextoSuave, height: 1.6, fontSize: 16)),
      ]),
    );
    final linhas = Column(children: [
      const Divider(height: 1, color: corLinha),
      for (final (i, c) in r.categorias.indexed)
        AoRolar(
          deslocamento: const Offset(0, 32),
          escalonar: (i * 0.06).clamp(0.0, 0.3),
          child: _LinhaCategoria(
            resumo: c,
            apagada: _sobre != null && _sobre != c.categoria,
            aoPassar: (dentro) => setState(() => _sobre = dentro ? c.categoria : null),
            aoTocar: () => widget.aoEscolher(c.categoria),
          ),
        ),
    ]);
    return _DuasColunas(titulo: titulo, conteudo: linhas);
  }
}

class _LinhaCategoria extends StatefulWidget {
  const _LinhaCategoria({
    required this.resumo,
    required this.apagada,
    required this.aoPassar,
    required this.aoTocar,
  });

  final ResumoCategoria resumo;
  final bool apagada;
  final ValueChanged<bool> aoPassar;
  final VoidCallback aoTocar;

  @override
  State<_LinhaCategoria> createState() => _LinhaCategoriaState();
}

class _LinhaCategoriaState extends State<_LinhaCategoria> {
  bool _dentro = false;
  bool _foco = false;

  bool get _ativa => _dentro || _foco;

  void _passar(bool dentro) {
    setState(() => _dentro = dentro);
    widget.aoPassar(dentro);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.resumo;
    final reduzir = MediaQuery.disableAnimationsOf(context);
    final duracao = reduzir ? Duration.zero : const Duration(milliseconds: 500);
    final faixa = faixaDePreco(c.menor, c.maior);
    return Semantics(
      button: true,
      label: '${c.categoria.rotulo}: ${contar(c.quantidade, 'peça', 'peças')}'
          '${faixa == null ? '' : ', $faixa'}. Ver na loja',
      excludeSemantics: true,
      child: FocusableActionDetector(
        onShowHoverHighlight: _passar,
        onShowFocusHighlight: (f) => setState(() => _foco = f),
        mouseCursor: SystemMouseCursors.click,
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) {
            widget.aoTocar();
            return null;
          }),
        },
        child: GestureDetector(
          onTap: widget.aoTocar,
          behavior: HitTestBehavior.opaque,
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: widget.apagada && !_ativa ? 0.5 : 1,
            child: Stack(children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: LayoutBuilder(builder: (context, caixa) {
                  const detalhe = TextStyle(
                      color: corTextoSuave, fontSize: 14, fontFeatures: _numerosAlinhados);
                  final rotulo = AnimatedPadding(
                    duration: duracao,
                    curve: Curves.easeOutCubic,
                    padding: EdgeInsets.only(left: _ativa ? 6 : 0),
                    child: Text(c.categoria.rotulo,
                        style: const TextStyle(fontFamily: fonteTitulo, fontSize: 32, height: 1)),
                  );
                  final quantidade = Text(contar(c.quantidade, 'peça', 'peças'), style: detalhe);
                  final preco = Text(faixa ?? 'Preço a definir', style: detalhe);
                  final seta = AnimatedSlide(
                    duration: reduzir ? Duration.zero : const Duration(milliseconds: 300),
                    offset: Offset(_ativa ? 0.25 : 0, 0),
                    child: const Icon(Icons.arrow_forward, size: 20),
                  );
                  // No celular o rótulo e a seta ficam na primeira linha e a quantidade e o preço embaixo.
                  if (caixa.maxWidth < 520) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [Expanded(child: rotulo), seta]),
                      const SizedBox(height: 8),
                      Wrap(spacing: 20, children: [quantidade, preco]),
                    ]);
                  }
                  return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(child: rotulo),
                    const SizedBox(width: 16),
                    quantidade,
                    const SizedBox(width: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minWidth: 110),
                      child: Align(alignment: Alignment.centerRight, child: preco),
                    ),
                    const SizedBox(width: 16),
                    seta,
                  ]);
                }),
              ),
              // Linha de tinta: nasce no canto esquerdo e corre até o fim.
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Stack(children: [
                  const SizedBox(height: 1, width: double.infinity, child: ColoredBox(color: corLinha)),
                  TweenAnimationBuilder<double>(
                    tween: Tween(end: _ativa ? 1 : 0),
                    duration: duracao,
                    curve: const Cubic(0.22, 1, 0.36, 1),
                    builder: (_, v, __) => Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: v,
                        child: const SizedBox(height: 1, child: ColoredBox(color: corTexto)),
                      ),
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
}

/// "Antes de escolher": o que dá para saber sobre as peças sem abrir nenhuma (tamanhos, cores, preços) e como
/// falar com a marca. Tamanhos, cores e preços saem do catálogo; o atendimento repete o que a marca já diz no
/// Sobre e no rodapé. Nada aqui promete prazo, troca ou material: o catálogo não traz isso.
class GuiaDaLoja extends StatelessWidget {
  const GuiaDaLoja({super.key, required this.resumo, required this.aoFalar});

  final ResumoLoja resumo;
  final VoidCallback aoFalar;

  @override
  Widget build(BuildContext context) {
    final r = resumo;
    final linhas = <(String, Widget)>[];
    const corpo = TextStyle(fontSize: 17, height: 1.6);

    if (r.tamanhos.isNotEmpty) {
      linhas.add((
        'Tamanhos',
        Text(
            '${emFrase(r.tamanhos)} nas roupas.'
            '${r.acessorios > 0 ? ' Os acessórios têm tamanho único.' : ''}'
            ' O tamanho se escolhe na página de cada peça.',
            style: corpo)
      ));
    }
    if (r.cores.isNotEmpty) {
      linhas.add((
        'Cores',
        Text('${emFrase(r.cores)}. Na página de cada peça aparecem as cores em que ela existe.',
            style: corpo)
      ));
    }
    final faixa = faixaDePreco(r.menor, r.maior);
    if (faixa != null || r.aCombinar > 0) {
      final intervalo = faixa == null ? '' : (r.menor == r.maior ? '$faixa.' : 'De $faixa, conforme a peça.');
      final combinar = r.aCombinar > 0
          ? ' ${contar(r.aCombinar, 'peça está', 'peças estão')} com preço a definir.'
          : '';
      linhas.add(('Preços', Text('$intervalo$combinar'.trim(), style: corpo)));
    }
    linhas.add((
      'Atendimento',
      Wrap(crossAxisAlignment: WrapCrossAlignment.end, children: [
        const Text('Direto pelo WhatsApp, sem intermediário: cada compra é combinada com você. ',
            style: corpo),
        InkWell(
          onTap: aoFalar,
          child: const Text('Falar com a marca',
              style: TextStyle(
                  fontSize: 17,
                  height: 1.6,
                  decoration: TextDecoration.underline,
                  decorationColor: corLinha)),
        ),
      ])
    ));

    final titulo = AoRolar(
      deslocamento: const Offset(-48, 0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Antes de escolher',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(height: 1.1)),
        const SizedBox(height: 16),
        const Text('O que dá para saber sobre as peças antes de abrir uma delas.',
            style: TextStyle(color: corTextoSuave, height: 1.6, fontSize: 16)),
      ]),
    );
    final lista = AoRolar(
      child: Column(children: [
        const Divider(height: 1, color: corLinha),
        for (final (termo, conteudo) in linhas) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: LayoutBuilder(builder: (context, caixa) {
              final rotulo = Text(termo, style: const TextStyle(color: corTextoSuave, fontSize: 16));
              if (caixa.maxWidth < 520) {
                return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  rotulo,
                  const SizedBox(height: 6),
                  conteudo,
                ]);
              }
              return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(width: 136, child: rotulo),
                const SizedBox(width: 24),
                Expanded(child: conteudo),
              ]);
            }),
          ),
          const Divider(height: 1, color: corLinha),
        ],
      ]),
    );
    return _DuasColunas(titulo: titulo, conteudo: lista);
  }
}
