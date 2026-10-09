import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/sacola.dart';
import 'componentes.dart';
import 'efeitos.dart';
import 'fundo_liquido.dart';
import 'tema.dart';

class PecaPage extends StatefulWidget {
  const PecaPage({super.key, required this.peca, required this.sacola});
  final Produto peca;
  final Sacola sacola;

  @override
  State<PecaPage> createState() => _PecaPageState();
}

class _PecaPageState extends State<PecaPage> {
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

  @override
  Widget build(BuildContext context) {
    final p = widget.peca;
    final tema = Theme.of(context).textTheme;
    const numeros = [FontFeature.tabularFigures()];
    // fotoCostas só existe em Peca (subclasse); Acessorio não tem.
    final costas = p is Peca ? p.fotoCostas : null;
    final foto = _verCostas ? costas : p.fotos.firstOrNull;

    final fotoWidget = Column(children: [
      AspectRatio(
        aspectRatio: 3 / 4,
        child: AnimatedSwitcher(
          duration: MediaQuery.disableAnimationsOf(context)
              ? Duration.zero
              : const Duration(milliseconds: 250),
          child: KeyedSubtree(
            key: ValueKey(_verCostas),
            child: fotoOuPlaceholder(foto,
                variante: _cor, heroTag: _verCostas ? null : 'foto-${p.id}'),
          ),
        ),
      ),
      if (costas != null) ...[
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          PilulaEscolha(
              rotulo: 'Frente',
              selecionada: !_verCostas,
              aoTocar: () => setState(() => _verCostas = false)),
          const SizedBox(width: 8),
          PilulaEscolha(
              rotulo: 'Costas',
              selecionada: _verCostas,
              aoTocar: () => setState(() => _verCostas = true)),
        ]),
      ],
    ]);

    final detalhes = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(p.nome, style: tema.headlineMedium),
        const SizedBox(height: 8),
        Text(p.precoFormatado,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w600, fontFeatures: numeros)),
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
              padding: const EdgeInsets.all(20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: largo
                      ? Row(
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
                      : Column(children: [
                          fotoWidget,
                          const SizedBox(height: 24),
                          Revelar(child: detalhes),
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
                  Text(p.precoFormatado,
                      style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          fontFeatures: numeros)),
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
