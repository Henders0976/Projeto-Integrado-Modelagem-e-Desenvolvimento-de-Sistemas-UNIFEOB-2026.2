import 'package:flutter/material.dart';

import '../models/categoria.dart';
import '../services/api.dart';
import '../services/api_admin.dart';
import '../services/catalogo_repository.dart';
import 'fundo_liquido.dart';
import 'rolagem_suave.dart';

/// Cadastro de produto novo (só chega aqui quem entrou como administrador).
/// As fotos são escolhidas entre as que já estão em assets/fotos/.
class AdminProdutoPage extends StatefulWidget {
  const AdminProdutoPage({super.key, required this.catalogo});
  final CatalogoRepository catalogo;

  @override
  State<AdminProdutoPage> createState() => _AdminProdutoPageState();
}

class _CorForm {
  final nome = TextEditingController();
  final tom = TextEditingController();
  String? frente;
  String? costas;
  void dispose() {
    nome.dispose();
    tom.dispose();
  }
}

class _AdminProdutoPageState extends State<AdminProdutoPage> {
  final _form = GlobalKey<FormState>();
  final _codigo = TextEditingController();
  final _nome = TextEditingController();
  final _descricao = TextEditingController();
  final _preco = TextEditingController();
  final _material = TextEditingController();
  Categoria _categoria = Categoria.blusas;
  final _cores = [_CorForm()];
  bool _salvando = false;

  // Inclui as fotos das peças desativadas: o catálogo todo está desativado até a administradora ativar.
  late final List<String> _fotos = widget.catalogo.fotos();

  @override
  void dispose() {
    for (final c in [_codigo, _nome, _descricao, _preco, _material]) {
      c.dispose();
    }
    for (final c in _cores) {
      c.dispose();
    }
    super.dispose();
  }

  static final _hex = RegExp(r'^#[0-9A-Fa-f]{6}$');

  Future<void> _salvar() async {
    if (!_form.currentState!.validate()) return;
    final msg = ScaffoldMessenger.of(context);
    setState(() => _salvando = true);
    try {
      await ApiAdmin.criarProduto({
        'codigo': _codigo.text.trim(),
        'nome': _nome.text.trim(),
        'categoria': _categoria.name,
        'descricao': _descricao.text.trim(),
        if (_preco.text.trim().isNotEmpty)
          'preco': double.parse(_preco.text.trim().replaceAll(',', '.')),
        if (_material.text.trim().isNotEmpty) 'material': _material.text.trim(),
        'cores': [
          for (final c in _cores)
            {
              'nome': c.nome.text.trim(),
              'fotoFrente': c.frente,
              if (c.costas != null) 'fotoCostas': c.costas,
              if (c.tom.text.trim().isNotEmpty) 'tom': c.tom.text.trim(),
            }
        ],
      });
      if (!mounted) return;
      msg.showSnackBar(const SnackBar(
          content: Text('Produto cadastrado. Ele aparece na loja quando o app for reaberto.')));
      Navigator.pop(context, true);
    } catch (e) {
      msg.showSnackBar(
          SnackBar(content: Text(e is ApiErro ? e.mensagem : 'Sem conexão.')));
      if (mounted) setState(() => _salvando = false);
    }
  }

  DropdownButtonFormField<String> _seletorFoto(
          String rotulo, String? valor, void Function(String?) aoMudar,
          {bool obrigatoria = true}) =>
      DropdownButtonFormField<String>(
        initialValue: valor,
        isExpanded: true,
        decoration: InputDecoration(labelText: rotulo),
        items: [
          if (!obrigatoria)
            const DropdownMenuItem(value: null, child: Text('Nenhuma')),
          for (final f in _fotos)
            DropdownMenuItem(value: f, child: Text(f.split('/').last)),
        ],
        validator: (v) => obrigatoria && v == null ? 'Escolha a foto' : null,
        onChanged: aoMudar,
      );

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Novo produto')),
        body: FundoLiquido(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Form(
                key: _form,
                child: ListaSuave(padding: const EdgeInsets.all(20), children: [
                  TextFormField(
                    controller: _codigo,
                    decoration: const InputDecoration(labelText: 'Código (ex.: essence-020)'),
                    validator: (v) => RegExp(r'^[a-z0-9-]{3,40}$').hasMatch((v ?? '').trim())
                        ? null
                        : 'Use letras minúsculas, números e hífen',
                  ),
                  TextFormField(
                    controller: _nome,
                    decoration: const InputDecoration(labelText: 'Nome'),
                    validator: (v) => (v ?? '').trim().isEmpty ? 'Informe o nome' : null,
                  ),
                  DropdownButtonFormField<Categoria>(
                    initialValue: _categoria,
                    decoration: const InputDecoration(labelText: 'Categoria'),
                    items: [
                      for (final c in Categoria.values)
                        DropdownMenuItem(value: c, child: Text(c.rotulo)),
                    ],
                    onChanged: (v) => setState(() => _categoria = v ?? _categoria),
                  ),
                  TextFormField(
                    controller: _descricao,
                    maxLines: 3,
                    decoration: const InputDecoration(labelText: 'Descrição'),
                  ),
                  TextFormField(
                    controller: _preco,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration:
                        const InputDecoration(labelText: 'Preço em R\$ (vazio = a combinar)'),
                    validator: (v) {
                      final t = (v ?? '').trim().replaceAll(',', '.');
                      if (t.isEmpty) return null;
                      final n = double.tryParse(t);
                      return n == null || n < 0 ? 'Preço inválido' : null;
                    },
                  ),
                  TextFormField(
                    controller: _material,
                    decoration: const InputDecoration(labelText: 'Material (opcional)'),
                  ),
                  const SizedBox(height: 24),
                  Text('Cores', style: Theme.of(context).textTheme.titleMedium),
                  for (var i = 0; i < _cores.length; i++) ...[
                    const Divider(height: 32),
                    TextFormField(
                      controller: _cores[i].nome,
                      decoration: InputDecoration(labelText: 'Nome da cor ${i + 1}'),
                      validator: (v) => (v ?? '').trim().isEmpty ? 'Informe a cor' : null,
                    ),
                    _seletorFoto('Foto da frente', _cores[i].frente,
                        (v) => setState(() => _cores[i].frente = v)),
                    _seletorFoto('Foto das costas', _cores[i].costas,
                        (v) => setState(() => _cores[i].costas = v),
                        obrigatoria: false),
                    TextFormField(
                      controller: _cores[i].tom,
                      decoration: const InputDecoration(
                          labelText: 'Tom para recolorir a foto (opcional, ex.: #8B1A2B)'),
                      validator: (v) {
                        final t = (v ?? '').trim();
                        return t.isEmpty || _hex.hasMatch(t) ? null : 'Use o formato #RRGGBB';
                      },
                    ),
                    if (_cores.length > 1)
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () => setState(() => _cores.removeAt(i).dispose()),
                          child: const Text('Remover esta cor'),
                        ),
                      ),
                  ],
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => setState(() => _cores.add(_CorForm())),
                      icon: const Icon(Icons.add),
                      label: const Text('Adicionar cor'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: _salvando ? null : _salvar,
                    child: Text(_salvando ? 'Salvando…' : 'Cadastrar produto'),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
}
