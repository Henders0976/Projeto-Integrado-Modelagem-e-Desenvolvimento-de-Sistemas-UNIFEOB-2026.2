import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/sacola.dart';
import 'componentes.dart';
import 'efeitos.dart';
import 'fundo_liquido.dart';
import 'rolagem_suave.dart';
import 'tema.dart';

class PecaPage extends StatefulWidget {
  const PecaPage({
    super.key,
    required this.peca,
    required this.sacola,
    this.parecidas = const [],
    this.cartao,
  });
  final Produto peca;
  final Sacola sacola;

  /// "Você também pode gostar": até 3 peças, desenhadas com [cartao] (o mesmo cartão da vitrine).
  final List<Produto> parecidas;
  final Widget Function(Produto)? cartao;

  @override
  State<PecaPage> createState() => _PecaPageState();
}

class _PecaPageState extends State<PecaPage> {
  final _rolagem = ControladorSuave();

  @override
  void dispose() {
    _rolagem.dispose();
    super.dispose();
  }

  late VarianteCor _cor = widget.peca.cores.first;
  late String _tamanho = widget.peca.tamanhos.first;
  int _quantidade = 1;
  bool _verCostas = false;
  bool _adicionada = false;

  void _adicionar() {
    final p = widget.peca;
    widget.sacola
        .adicionar(p, cor: _cor.nome, tamanho: _tamanho, quantidade: _quantidade);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('${p.nome} entrou na sacola.')));
    setState(() => _adicionada = true);
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) setState(() => _adicionada = false);
    });
  }

  /// Foto em tela cheia: pinça (celular) ou roda do mouse para dar zoom, arrastar para mover.
  void _ampliar(String foto) => showDialog<void>(
        context: context,
        builder: (contexto) => Dialog.fullscreen(
          backgroundColor: RvColors.bg,
          child: Stack(children: [
            Positioned.fill(
              child: InteractiveViewer(
                maxScale: 4,
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: fotoOuPlaceholder(foto, variante: _cor),
                  ),
                ),
              ),
            ),
            Positioned(
              top: RvSpace.lg,
              right: RvSpace.lg,
              child: SafeArea(
                child: IconButton.filledTonal(
                  tooltip: 'Fechar',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(contexto),
                ),
              ),
            ),
          ]),
        ),
      );

  /// "Você também pode gostar": até 3 peças, primeiro as da mesma categoria.
  Widget _parecidas(BuildContext context, double largura) => Padding(
        padding: const EdgeInsets.only(top: 64, bottom: 8),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Você também pode gostar',
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 28),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: largura >= 560 ? 3 : 2,
            childAspectRatio: 0.54,
            crossAxisSpacing: 16,
            mainAxisSpacing: 32,
            children: [
              for (final (i, p) in widget.parecidas.indexed)
                AoRolar(
                  key: ValueKey(p.id),
                  escalonar: i * 0.1,
                  child: widget.cartao!(p),
                ),
            ],
          ),
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final p = widget.peca;
    final tema = Theme.of(context).textTheme;
    // fotoCostas só existe em Peca (subclasse); Acessorio não tem.
    final costas = p is Peca ? p.fotoCostas : null;
    final foto = _verCostas ? costas : p.fotos.firstOrNull;

    final fotoWidget = Column(children: [
      AspectRatio(
        aspectRatio: 3 / 4,
        child: Semantics(
          button: foto != null,
          label: foto != null ? 'Ampliar foto' : null,
          child: MouseRegion(
            cursor: foto != null ? SystemMouseCursors.zoomIn : MouseCursor.defer,
            child: GestureDetector(
              onTap: foto == null ? null : () => _ampliar(foto),
              child: Stack(fit: StackFit.expand, children: [
                AnimatedSwitcher(
                  duration: RvMotion.de(context, RvMotion.base),
                  child: KeyedSubtree(
                    key: ValueKey(_verCostas),
                    child: fotoOuPlaceholder(foto,
                        variante: _cor, heroTag: _verCostas ? null : 'foto-${p.id}'),
                  ),
                ),
                if (foto != null)
                  const Positioned(
                    right: RvSpace.md,
                    bottom: RvSpace.md,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                          color: Color(0xB30B0B0C), shape: BoxShape.circle), // RvColors.bg @ 70%
                      child: Padding(
                        padding: EdgeInsets.all(RvSpace.sm),
                        child: Icon(Icons.zoom_in, size: 20, color: RvColors.textPrimary),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
        ),
      ),
      if (costas != null) ...[
        const SizedBox(height: RvSpace.md),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          for (final (i, (rotulo, f)) in [('Frente', p.fotos.firstOrNull), ('Costas', costas)].indexed)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: RvSpace.xs),
              child: _Miniatura(
                rotulo: rotulo,
                foto: f,
                variante: _cor,
                selecionada: _verCostas == (i == 1),
                aoTocar: () => setState(() => _verCostas = i == 1),
              ),
            ),
        ]),
      ],
    ]);

    final detalhes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.nome, style: tema.headlineMedium),
        const SizedBox(height: 8),
        Text(p.precoFormatado, style: RvText.price.copyWith(fontSize: 22)),
        const SizedBox(height: 16),
        Text(p.descricao,
            style: const TextStyle(color: corTextoSuave, height: 1.5)),
        const SizedBox(height: 28),
        Text('Cor: ${_cor.nome}', style: tema.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 12, runSpacing: 12, children: [
          for (final c in p.cores)
            AmostraCor(
                foto: p.fotos.firstOrNull,
                variante: c,
                selecionada: c == _cor,
                aoTocar: () => setState(() => _cor = c)),
        ]),
        const SizedBox(height: 24),
        Text('Tamanho', style: tema.titleSmall),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          for (final t in p.tamanhos)
            PilulaEscolha(
                rotulo: t,
                selecionada: t == _tamanho,
                aoTocar: () => setState(() => _tamanho = t)),
        ]),
        const SizedBox(height: 24),
        Text('Quantidade', style: tema.titleSmall),
        const SizedBox(height: 8),
        SeletorQuantidade(
            quantidade: _quantidade,
            aoMudar: (v) => setState(() => _quantidade = v)),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: Text(p.nome)),
      body: FundoLiquido(
        child: LayoutBuilder(
          builder: (context, c) {
            final largo = c.maxWidth >= 820;
            return SingleChildScrollView(
              controller: _rolagem,
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(children: [
                    if (largo)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(flex: 5, child: fotoWidget),
                          const SizedBox(width: 48),
                          Expanded(
                              flex: 6,
                              child: Revelar(
                                  atraso: const Duration(milliseconds: 120),
                                  child: detalhes)),
                        ],
                      )
                    else ...[
                      fotoWidget,
                      const SizedBox(height: 24),
                      Revelar(child: detalhes),
                    ],
                    if (widget.parecidas.isNotEmpty && widget.cartao != null)
                      _parecidas(context, c.maxWidth),
                  ]),
                ),
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: corPainel,
          border: Border(top: BorderSide(color: corLinha, width: 0.5)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
            child: Center(
              heightFactor: 1,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1000),
                child: Row(children: [
                  Text(p.precoFormatado, style: RvText.price),
                  const SizedBox(width: 20),
                  Expanded(
                    child: FilledButton(
                      onPressed: _adicionar,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        child: Text(
                            _adicionada ? 'Adicionada ✓' : 'Adicionar à sacola',
                            key: ValueKey(_adicionada)),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Miniatura da galeria (frente/costas): borda vermelha na foto que está aberta.
class _Miniatura extends StatelessWidget {
  const _Miniatura({
    required this.rotulo,
    required this.foto,
    required this.variante,
    required this.selecionada,
    required this.aoTocar,
  });

  final String rotulo;
  final String? foto;
  final VarianteCor variante;
  final bool selecionada;
  final VoidCallback aoTocar;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selecionada,
        label: 'Foto: $rotulo',
        excludeSemantics: true,
        child: Tooltip(
          message: rotulo,
          child: InkWell(
            onTap: aoTocar,
            borderRadius: BorderRadius.circular(RvRadius.sm),
            child: AnimatedContainer(
              duration: RvMotion.de(context, RvMotion.fast),
              width: 64,
              height: 80,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(RvRadius.sm),
                border: Border.all(
                    color: selecionada ? RvColors.brand : RvColors.border,
                    width: selecionada ? 2 : 1),
              ),
              child: fotoOuPlaceholder(foto, variante: variante),
            ),
          ),
        ),
      );
}
