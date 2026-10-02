import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';

class MeusAgendamentos extends StatefulWidget {
  const MeusAgendamentos({super.key});

  @override
  State<MeusAgendamentos> createState() => _MeusAgendamentosState();
}

class _Agendamento {
  final String diaHora;
  int confirmacoes;
  String estado;

  _Agendamento({required this.diaHora, required this.confirmacoes, required this.estado});
}

class _MeusAgendamentosState extends State<MeusAgendamentos> {
  final List<_Agendamento> _agendamentos = [
    _Agendamento(diaHora: 'Terça, 10:00 – 11:00', confirmacoes: 3, estado: 'confirmada'),
    _Agendamento(diaHora: 'Quinta, 14:00 – 15:00', confirmacoes: 2, estado: 'pendente'),
    _Agendamento(diaHora: 'Sexta, 08:00 – 09:00', confirmacoes: 3, estado: 'confirmada'),
  ];

  void _cancelar(_Agendamento a) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancelar reserva?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: corTinta)),
        content: Text('Isso vai liberar o horário de ${a.diaHora} para a fila de espera.', style: const TextStyle(fontSize: 13, color: corTintaSuave)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Voltar', style: TextStyle(color: corTintaSuave)),
          ),
          TextButton(
            onPressed: () {
              setState(() => a.estado = 'cancelada');
              Navigator.pop(context);
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
        child: _agendamentos.isEmpty
            ? const Center(child: Text('Você ainda não tem reservas.', style: TextStyle(color: corTintaSuave)))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _agendamentos.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _cartao(_agendamentos[index]),
          ),
        ),
      ),
    );
  }

  Widget _cartao(_Agendamento a) {
    final cancelada = a.estado == 'cancelada';

    return Opacity(
      opacity: cancelada ? .55 : 1,
      child: CartaoInsspiract(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(a.diaHora, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                ),
                cancelada
                    ? chipInsspiract('Cancelada', cor: corVermelho, fundo: const Color(0xFFFCE9E9))
                    : (a.estado == 'confirmada'
                    ? chipInsspiract('Confirmada', cor: corVerde, fundo: const Color(0xFFE4F7EC))
                    : chipInsspiract('Aguardando ${a.confirmacoes}/3', cor: corAvisoTexto, fundo: corAvisoFundo)),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              cancelada ? 'Horário liberado para a fila de espera' : '${a.confirmacoes}/3 confirmações da secretaria',
              style: const TextStyle(fontSize: 12, color: corTintaSuave),
            ),
            if (!cancelada) ...[
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _cancelar(a),
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
}