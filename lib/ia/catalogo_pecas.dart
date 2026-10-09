import 'package:flutter/material.dart';
import 'package:genui/genui.dart';
import 'package:json_schema_builder/json_schema_builder.dart';

import '../models/models.dart';
import '../services/catalogo_repository.dart';
import '../services/sacola.dart';
import 'instrucoes.dart';

/// Esquema (contrato JSON) que o agente deve seguir para pedir o componente.
final _esquemaPecasSugeridas = S.object(
  properties: {
    'component': S.string(enumValues: [componentePecasSugeridas]),
    'titulo': S.string(description: 'Título curto da sugestão'),
    'ids': S.list(
      description: 'IDs de produtos do catálogo da RV Label a exibir',
      items: S.string(),
    ),
  },
  required: ['ids'],
);

/// Cria o item de catálogo GenUI. Os widgets e os dados são privados a este
/// arquivo; o app só enxerga o [CatalogItem] devolvido.
CatalogItem criarItemPecasSugeridas({
  required CatalogoRepository catalogo,
  required Sacola sacola,
}) =>
    CatalogItem(
      name: componentePecasSugeridas,
      dataSchema: _esquemaPecasSugeridas,
      widgetBuilder: (itemContext) {
        final dados = _PecasSugeridasData.fromJson(
            itemContext.data as Map<String, Object?>);
        final produtos = [
          for (final id in dados.ids)
            if (catalogo.buscarPorId(id) case final p?) p
        ];
        return _PecasSugeridas(
          titulo: dados.titulo,
          produtos: produtos,
          aoAdicionar: (p) => sacola.adicionar(p,
              cor: p.cores.first.nome, tamanho: p.tamanhos.first),
        );
      },
    );

class _PecasSugeridasData {
  _PecasSugeridasData({required this.titulo, required this.ids});
  final String titulo;
  final List<String> ids;

  factory _PecasSugeridasData.fromJson(Map<String, Object?> json) =>
      _PecasSugeridasData(
        titulo: (json['titulo'] as String?) ?? 'Sugestões pra você',
        ids: [...(json['ids'] as List<Object?>? ?? const [])].cast<String>(),
      );
}

class _PecasSugeridas extends StatelessWidget {
  const _PecasSugeridas({
    required this.titulo,
    required this.produtos,
    required this.aoAdicionar,
  });

  final String titulo;
  final List<Produto> produtos;
  final void Function(Produto) aoAdicionar;

  @override
  Widget build(BuildContext context) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child:
                  Text(titulo, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final p in produtos)
              ListTile(
                title: Text(p.nome),
                subtitle: Text('${p.resumo} · ${p.precoFormatado}'),
                trailing: TextButton(
                  onPressed: () {
                    aoAdicionar(p);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Produto adicionado')));
                  },
                  child: const Text('Adicionar'),
                ),
              ),
          ],
        ),
      );
}
