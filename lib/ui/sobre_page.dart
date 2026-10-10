import 'package:flutter/material.dart';

import 'componentes.dart';
import 'efeitos.dart';
import 'fundo_liquido.dart';
import 'rolagem_suave.dart';
import 'tema.dart';

/// Página "Sobre" da marca: manchete, texto, foto grande e assinatura.
class SobrePage extends StatelessWidget {
  const SobrePage({super.key, this.foto});

  /// Foto grande do meio da página; sem ela, aparece o espaço "Foto em breve".
  final String? foto;

  static const _estilo = TextStyle(fontSize: 17, height: 1.65);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Sobre')),
        body: FundoLiquido(
          child: ListaSuave(
            padding: const EdgeInsets.fromLTRB(24, 48, 24, 96),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AoRolar(
                        deslocamento: const Offset(-64, 0),
                        child: Text('Uma exploração de corte e identidade.',
                            style: Theme.of(context).textTheme.displaySmall),
                      ),
                      const SizedBox(height: 48),
                      const AoRolar(
                        child: Text(
                          'A RV Label nasceu da vontade de fazer moda com identidade: '
                          'roupa que veste história, não tendência. Cada peça da '
                          'coleção Essence é pensada com carinho, com cortes '
                          'assimétricos, um ombro só e decotes que respiram.',
                          style: _estilo,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const AoRolar(
                        child: Text(
                          'Nosso ritmo é lento de propósito. Produzimos em pequenos '
                          'lotes, e as peças são feitas pra durar no guarda-roupa e '
                          'no visual — nada de excesso, só o que vale a pena vestir.',
                          style: _estilo,
                        ),
                      ),
                      const SizedBox(height: 56),
                      AoRolar(
                        child: AspectRatio(
                          aspectRatio: 4 / 5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(raioPadrao),
                            child: ParallaxFoto(
                                intensidade: 40,
                                escala: 1.2,
                                child: fotoOuPlaceholder(foto)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 56),
                      const AoRolar(
                        child: Text(
                          'Cada compra é combinada direto com você, pelo WhatsApp, sem '
                          'intermediário e sem pressa. Você escolhe a peça, a cor e o '
                          'tamanho, e a gente cuida do resto.',
                          style: _estilo,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const AoRolar(
                        child: Text(
                          'Quando você veste RV Label, leva junto a intenção de quem '
                          'cuidou de cada detalhe.',
                          style: _estilo,
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text('Moda por RV Label',
                          style: TextStyle(color: corTextoSuave)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}
