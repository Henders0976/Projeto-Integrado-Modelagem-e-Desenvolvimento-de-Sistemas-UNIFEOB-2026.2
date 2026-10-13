import 'package:flutter/material.dart';

import 'fundo_liquido.dart';
import 'rolagem_suave.dart';

/// Política de privacidade (LGPD) e termos de uso, em linguagem direta.
class PrivacidadePage extends StatelessWidget {
  const PrivacidadePage({super.key});

  static const _blocos = <(String, String)>[
    ('Quem é o responsável',
        'A RV Label (CNPJ 68.647.856/0001-97) decide como os seus dados são usados '
            'e responde por eles. Para qualquer assunto sobre seus dados, escreva para '
            'suporte.rvlabel@gmail.com.'),
    ('Que dados coletamos',
        'Nome e telefone para atender seu pedido. O CPF é opcional e só pedimos '
            'se você quiser nota fiscal. Não pedimos senha nem dados de cartão.'),
    ('Para que usamos',
        'Somente para registrar, separar e entregar o seu pedido e falar com você '
            'sobre ele pelo WhatsApp. Não vendemos nem compartilhamos seus dados.'),
    ('Por quanto tempo guardamos',
        'Enquanto o pedido existir ou a lei exigir (por exemplo, obrigações fiscais). '
            'Depois disso, apagamos ou tornamos os dados anônimos.'),
    ('Seus direitos (LGPD)',
        'Você pode pedir acesso, correção ou exclusão dos seus dados, e retirar o '
            'consentimento quando quiser. Escreva para suporte.rvlabel@gmail.com ou '
            'chame a RV Label no WhatsApp.'),
    ('Como consultar seu pedido',
        'Em "Meus pedidos" você vê o andamento informando o número do pedido e o '
            'telefone usado na compra.'),
    ('Termos de uso',
        'As peças são produzidas em pequenos lotes e as informações do app '
            '(preço, cor, tamanho) valem até o fechamento do pedido pelo WhatsApp. '
            'Trocas e devoluções seguem o Código de Defesa do Consumidor e são '
            'combinadas direto com a marca.'),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Privacidade e termos')),
        body: FundoLiquido(
          child: ListaSuave(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 640),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final (titulo, texto) in _blocos) ...[
                        Text(titulo, style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 6),
                        Text(texto, style: const TextStyle(fontSize: 16, height: 1.5)),
                        const SizedBox(height: 22),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
