import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/AuthService.dart';

class GerenciarReservas extends StatefulWidget {
  final String meuId; // secretaria logada

  const GerenciarReservas({super.key, required this.meuId});

  @override
  State<GerenciarReservas> createState() => _GerenciarReservasState();
}

class _GerenciarReservasState extends State<GerenciarReservas> {
  late Future<List<Map<String, dynamic>>> _futureReservas;
  final Set<int> _processando = {};

  @override
  void initState() {
    super.initState();
    _carregarReservas();
  }

  void _carregarReservas() {
    setState(() {
      _futureReservas = AuthService.listarReservasParaGerenciar();
    });
  }

  Future<void> _confirmar(int reservaId) async {
    setState(() => _processando.add(reservaId));

    final sucesso = await AuthService.confirmarReserva(
      reservaId: reservaId,
      secretariaId: int.parse(widget.meuId),
    );

    if (!mounted) return;
    setState(() => _processando.remove(reservaId));

    if (sucesso) {
      _carregarReservas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você já confirmou essa reserva antes.')),
      );
    }
  }

  Future<void> _desmarcar(int reservaId) async {
    setState(() => _processando.add(reservaId));

    final sucesso = await AuthService.cancelarReserva(reservaId);

    if (!mounted) return;
    setState(() => _processando.remove(reservaId));

    if (sucesso) {
      _carregarReservas();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível desmarcar agora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Gerenciar reservas'),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureReservas,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: corAzul));
            }

            final reservas = snapshot.data ?? [];

            if (reservas.isEmpty) {
              return const Center(
                child: Text('Nenhuma reserva no momento.', style: TextStyle(color: corTintaSuave)),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: reservas.length,
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _cartaoReserva(reservas[index]),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _cartaoReserva(Map<String, dynamic> r) {
    final int id = r['ID'] as int;
    final String professor = r['PROFESSOR_NOME'] as String;
    final String agendamento = r['AGENDAMENTO'].toString();
    final String periodo = r['PERIODO'].toString();
    final String estado = r['ESTADO'] as String;

    final int confirmacoes = (r['CONFIRMACOES'] as int?) ?? 0;
    final bool cancelada = estado == 'CANCELADA';
    final bool processando = _processando.contains(id);

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
                      Text(professor, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                      const SizedBox(height: 2),
                      Text('$agendamento · $periodo', style: const TextStyle(fontSize: 12, color: corTintaSuave)),
                    ],
                  ),
                ),
                _estadoChip(estado, confirmacoes),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(3, (i) {
                final ativo = i < confirmacoes;
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
                  if (confirmacoes < 3)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: processando ? null : () => _confirmar(id),
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
                  if (confirmacoes < 3) const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: processando ? null : () => _desmarcar(id),
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

  Widget _estadoChip(String estado, int confirmacoes) {
    switch (estado) {
      case 'CONFIRMADA':
        return chipInsspiract('$confirmacoes/3', cor: corVerde, fundo: const Color(0xFFE4F7EC));
      case 'CANCELADA':
        return chipInsspiract('Desmarcada', cor: corVermelho, fundo: const Color(0xFFFCE9E9));
      default:
        return chipInsspiract('$confirmacoes/3', cor: corAvisoTexto, fundo: corAvisoFundo);
    }
  }
}