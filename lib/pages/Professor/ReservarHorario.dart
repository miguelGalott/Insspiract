import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';

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

  GraficoBarrasWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double maiorValor = dados.map((e) => e.valor).reduce((a, b) => a > b ? a : b);
    double alturaMaximaGrafico = 120.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: corLinha),
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
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [corAzulClaro, corAzul],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.label.substring(0, 3),
                style: const TextStyle(
                  color: corTintaSuave,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

/// A página em si (RF13) — o gráfico acima já existia, só faltava a tela
/// (AppBar + números-resumo) pra poder navegar até ele.
class RelatorioUso extends StatelessWidget {
  const RelatorioUso({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Relatório de uso'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                _statBox('42', 'Reservas'),
                const SizedBox(width: 8),
                _statBox('7', 'Cancelamentos'),
                const SizedBox(width: 8),
                _statBox('5', 'Reclamações'),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Reservas por semana', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: corTintaSuave)),
            const SizedBox(height: 10),
            GraficoBarrasWidget(),
            const SizedBox(height: 8),
            const Text(
              'Dados ilustrativos para fins de demonstração (RF13)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11, color: corTintaSuave),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statBox(String numero, String rotulo) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: corLinha, width: 1.4),
        ),
        child: Column(
          children: [
            Text(numero, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: corAzul)),
            const SizedBox(height: 2),
            Text(rotulo, style: const TextStyle(fontSize: 10.5, color: corTintaSuave)),
          ],
        ),
      ),
    );
  }
}