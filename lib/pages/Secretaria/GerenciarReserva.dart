import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';

class GerenciarReservas extends StatefulWidget {
  const GerenciarReservas({super.key});

  @override
  State<GerenciarReservas> createState() => _GerenciarReservasState();
}

class _Reserva {
  final String professor;
  final String diaHora;
  int confirmacoes;
  String estado;

  _Reserva({
    required this.professor,
    required this.diaHora,
    required this.confirmacoes,
    required this.estado,
  });
}

class _GerenciarReservasState extends State<GerenciarReservas> {

  final List<_Reserva> _reservas = [
    _Reserva(professor: 'Prof. Ana Beatriz', diaHora: 'Terça, 10:00 – 11:00', confirmacoes: 3, estado: 'confirmada'),
    _Reserva(professor: 'Prof. Diego Alves', diaHora: 'Quinta, 14:00 – 15:00', confirmacoes: 1, estado: 'pendente'),
    _Reserva(professor: 'Prof. Carlos Menezes', diaHora: 'Sexta, 08:00 – 09:00', confirmacoes: 2, estado: 'pendente'),
  ];

  void _confirmar(_Reserva reserva) {
    setState(() {
      if (reserva.confirmacoes < 3) reserva.confirmacoes++;
      if (reserva.confirmacoes >= 3) reserva.estado = 'confirmada';
    });
  }

  void _desmarcar(_Reserva reserva) {
    setState(() => reserva.estado = 'cancelada');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Gerenciar reservas'),
      body: SafeArea(
        child: _reservas.isEmpty
            ? const Center(
          child: Text('Nenhuma reserva no momento.', style: TextStyle(color: corTintaSuave)),
        )
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _reservas.length,
          itemBuilder: (context, index) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _cartaoReserva(_reservas[index]),
          ),
        ),
      ),
    );
  }

  Widget _cartaoReserva(_Reserva reserva) {
    final cancelada = reserva.estado == 'cancelada';

    return Opacity(
      opacity: cancelada ? .55 : 1,
      child: CartaoInsspiract(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reserva.professor, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                      const SizedBox(height: 2),
                      Text(reserva.diaHora, style: const TextStyle(fontSize: 12, color: corTintaSuave)),
                    ],
                  ),
                ),
                _estadoChip(reserva),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(3, (i) {
                final ativo = i < reserva.confirmacoes;
                return Expanded(
                  child: Container(
                    margin: EdgeInsets.only(right: i < 2 ? 6 : 0),
                    height: 6,
                    decoration: BoxDecoration(
                      color: ativo ? corLaranja : corLinha,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                );
              }),
            ),
            if (!cancelada) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (reserva.confirmacoes < 3)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmar(reserva),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: corVerde,
                          side: const BorderSide(color: corVerde),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirmar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  if (reserva.confirmacoes < 3) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _desmarcar(reserva),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: corVermelho,
                        side: const BorderSide(color: corVermelho),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                      ),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Desmarcar', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _estadoChip(_Reserva reserva) {
    switch (reserva.estado) {
      case 'confirmada':
        return chipInsspiract('${reserva.confirmacoes}/3', cor: corVerde, fundo: const Color(0xFFE4F7EC));
      case 'cancelada':
        return chipInsspiract('Desmarcada', cor: corVermelho, fundo: const Color(0xFFFCE9E9));
      default:
        return chipInsspiract('${reserva.confirmacoes}/3', cor: corAvisoTexto, fundo: corAvisoFundo);
    }
  }
}