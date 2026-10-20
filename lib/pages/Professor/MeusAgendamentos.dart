import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/AuthService.dart';

class MeusAgendamentos extends StatefulWidget {
  final String meuId;

  const MeusAgendamentos({super.key, required this.meuId});

  @override
  State<MeusAgendamentos> createState() => _MeusAgendamentosState();
}

class _MeusAgendamentosState extends State<MeusAgendamentos> {
  late Future<List<Map<String, dynamic>>> _futureAgendamentos;

  @override
  void initState() {
    super.initState();
    _carregarAgendamentos();
  }

  void _carregarAgendamentos() {
    setState(() {
      _futureAgendamentos = AuthService.listarAgendamentos(int.parse(widget.meuId));
    });
  }

  void _cancelar(int reservaId, String diaHora) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar reserva?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTinta)),
        content: Text('Isso vai liberar o horário de $diaHora para a fila de espera.', style: const TextStyle(fontSize: 13, color: corTintaSuave)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar', style: TextStyle(color: corTintaSuave)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final sucesso = await AuthService.cancelarReserva(reservaId);
              if (!mounted) return;
              if (sucesso) {
                _carregarAgendamentos();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Não foi possível cancelar agora.')),
                );
              }
            },
            child: const Text('Cancelar reserva', style: TextStyle(color: corVermelho, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Meus agendamentos'),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureAgendamentos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: corAzul));
            }

            final agendamentos = snapshot.data ?? [];

            if (agendamentos.isEmpty) {
              return const Center(child: Text('Você ainda não tem reservas.', style: TextStyle(color: corTintaSuave)));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: agendamentos.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _cartao(agendamentos[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cartao(Map<String, dynamic> item) {
    final int reservaId = item['ID'] as int;
    final String salaNome = item['SALA_NOME'] as String;
    final String diaHora = '${item['AGENDAMENTO']} — ${item['PERIODO']}';
    final String estado = item['ESTADO'] as String;
    final int confirmacoes = item['CONFIRMACOES'] as int;
    final bool cancelada = estado == 'CANCELADA';

    return Opacity(
      opacity: cancelada ? .55 : 1,
      child: CartaoInsspiract(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(salaNome, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                      Text(diaHora, style: const TextStyle(fontSize: 12, color: corTintaSuave)),
                    ],
                  ),
                ),
                _estadoChip(estado, confirmacoes),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cancelada ? 'Horário liberado para a fila de espera' : '$confirmacoes/3 confirmações da secretaria',
              style: const TextStyle(fontSize: 12, color: corTintaSuave),
            ),
            if (!cancelada) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelar(reservaId, diaHora),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: corVermelho,
                    side: const BorderSide(color: corVermelho),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                  ),
                  icon: const Icon(Icons.close, size: 16),
                  label: const Text('Cancelar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _estadoChip(String estado, int confirmacoes) {
    switch (estado) {
      case 'CONFIRMADA':
        return chipInsspiract('Confirmada', cor: corVerde, fundo: const Color(0xFFE4F7EC));
      case 'CANCELADA':
        return chipInsspiract('Cancelada', cor: corVermelho, fundo: const Color(0xFFFCE9E9));
      case 'EM_FILA':
        return chipInsspiract('Em fila', cor: corAvisoTexto, fundo: corAvisoFundo);
      default:
        return chipInsspiract('Aguardando $confirmacoes/3', cor: corAvisoTexto, fundo: corAvisoFundo);
    }
  }
}