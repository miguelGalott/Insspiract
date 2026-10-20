import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/AuthService.dart';

class RelatorioUso extends StatefulWidget {
  const RelatorioUso({super.key});

  @override
  State<RelatorioUso> createState() => _RelatorioUsoState();
}

class _RelatorioUsoState extends State<RelatorioUso> {
  late Future<List<Map<String, dynamic>>> _futureRelatorio;

  @override
  void initState() {
    super.initState();
    _futureRelatorio = AuthService.relatorioDeUso();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Relatório de uso'),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureRelatorio,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: corAzul));
            }

            final dados = snapshot.data ?? [];

            if (dados.isEmpty) {
              return const Center(
                child: Text('Ainda não há dados suficientes.', style: TextStyle(color: corTintaSuave)),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _legenda(),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CartaoInsspiract(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: BarChart(_construirGrafico(dados)),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _legenda() {
    return Wrap(
      spacing: 14,
      runSpacing: 6,
      children: [
        _itemLegenda('Reservas', corAzul),
        _itemLegenda('Canceladas', corVermelho),
        _itemLegenda('Reclamações', corLaranja),
      ],
    );
  }

  Widget _itemLegenda(String texto, Color cor) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: cor, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(texto, style: const TextStyle(fontSize: 12, color: corTintaSuave)),
      ],
    );
  }


  BarChartData _construirGrafico(List<Map<String, dynamic>> dados) {
    final grupos = <BarChartGroupData>[];


    for (int i = 0; i < dados.length; i++) {
      final linha = dados[i];
      final total = (linha['TOTAL'] as int).toDouble();
      final canceladas = (linha['CANCELADAS'] as int).toDouble();
      final reclamacoes = ((linha['RECLAMACOES'] as int?) ?? 0).toDouble();

      grupos.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(toY: total, color: corAzul, width: 7, borderRadius: BorderRadius.circular(3)),
            BarChartRodData(toY: canceladas, color: corVermelho, width: 7, borderRadius: BorderRadius.circular(3)),
            BarChartRodData(toY: reclamacoes, color: corLaranja, width: 7, borderRadius: BorderRadius.circular(3)),
          ],
        ),
      );
    }

    return BarChartData(
      alignment: BarChartAlignment.spaceAround,
      gridData: const FlGridData(show: true, drawVerticalLine: false),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (value, meta) {
              final i = value.toInt();
              if (i < 0 || i >= dados.length) return const SizedBox.shrink();
              final mes = dados[i]['MES'] as String; // ANO/MES/DIA  não sei se vai aparecer o dia
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(mes.substring(5), style: const TextStyle(fontSize: 10, color: corTintaSuave)),
              );
            },
          ),
        ),
      ),
      barGroups: grupos,
    );
  }
}