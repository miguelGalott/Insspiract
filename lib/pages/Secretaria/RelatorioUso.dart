import 'package:flutter/material.dart';


class DadosSemana {
  final String label;
  final double valor;

  DadosSemana(this.label, this.valor);
}

class GraficoBarrasWidget extends StatelessWidget {
  final List<DadosSemana> dados = [
    DadosSemana('Segunda', 12),
    DadosSemana('Terça', 18),
    DadosSemana('Quarta', 14),
    DadosSemana('Quinta', 22),
    DadosSemana('Sexta', 19),
  ];

  @override
  Widget build(BuildContext context) {

    double maiorValor = dados.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
    double alturaMaximaGrafico = 120.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: dados.map((item) {

          double alturaBarra = (item.valor / maiorValor) * alturaMaximaGrafico;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 32,
                height: alturaBarra,
                decoration: BoxDecoration(
                  color: const Color(0xFF1565C0),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),

              Text(
                item.label,
                style: const TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}