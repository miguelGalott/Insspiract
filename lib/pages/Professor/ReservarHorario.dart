import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/AuthService.dart';
import 'package:primeiro_app/pages/Professor/FilaEspera.dart';

class ReservarHorario extends StatefulWidget {
  final String meuId;

  const ReservarHorario({super.key, required this.meuId});

  @override
  State<ReservarHorario> createState() => _ReservarHorarioState();
}

class _Slot {
  final String hora;
  final String status;
  final String info;
  final int? reservaId;
  _Slot({required this.hora, required this.status, required this.info, this.reservaId});
}

class _ReservarHorarioState extends State<ReservarHorario> {
  static const List<String> _horas = ['08:00', '09:00', '10:00', '11:00', '14:00', '15:00', '16:00'];
  static const List<String> _nomesDias = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];

  late final List<DateTime> _dias;
  int _diaSelecionado = 0;
  late Future<List<_Slot>> _futureSlots;

  _Slot? _slotEscolhido;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _dias = _proximosDiasUteis(5);
    _carregar();
  }

  List<DateTime> _proximosDiasUteis(int quantidade) {
    final dias = <DateTime>[];
    var d = DateTime.now();
    while (dias.length < quantidade) {
      if (d.weekday <= DateTime.friday) {
        dias.add(DateTime(d.year, d.month, d.day));
      }
      d = d.add(const Duration(days: 1));
    }
    return dias;
  }

  String _formatarData(DateTime d) {
    final mes = d.month.toString().padLeft(2, '0');
    final dia = d.day.toString().padLeft(2, '0');
    return '${d.year}-$mes-$dia';
  }

  bool _mesmoDia(DateTime a, DateTime b) => a.year == b.year && a.month == b.month && a.day == b.day;


  void _carregar() {
    _slotEscolhido = null;
    _futureSlots = _buscarSlots();
  }

  Future<List<_Slot>> _buscarSlots() async {
    final dia = _dias[_diaSelecionado];
    final meuId = int.parse(widget.meuId);

    final linhas = await AuthService.listarHorariosDoDia(
      data: _formatarData(dia),
      professorId: meuId,
    );

    final porHora = {for (final l in linhas) l['PERIODO'].toString(): l};
    final agora = DateTime.now();

    return _horas.map((hora) {
      final l = porHora[hora];
      final jaPassou = _mesmoDia(dia, agora) && int.parse(hora.substring(0, 2)) <= agora.hour;
      final nome = l?['PROFESSOR_NOME'] as String?;

      if (jaPassou) {
        return _Slot(hora: hora, status: 'passado', info: nome ?? 'Encerrado');
      }
      if (l == null) {
        return _Slot(hora: hora, status: 'livre', info: 'Disponível');
      }

      final reservaId = l['ID'] as int;
      final naFila = (l['NA_FILA'] as int?) ?? 0;

      if ((l['PROFESSOR_ID'] as int) == meuId) {
        final confirmada = l['ESTADO'] == 'CONFIRMADA';
        return _Slot(
          hora: hora,
          status: 'minha',
          info: confirmada ? 'Sua reserva confirmada' : 'Sua reserva — aguardando confirmação',
          reservaId: reservaId,
        );
      }
      if (((l['EU_NA_FILA'] as int?) ?? 0) > 0) {
        return _Slot(hora: hora, status: 'na_fila', info: '$nome · você está na fila', reservaId: reservaId);
      }
      return _Slot(
        hora: hora,
        status: 'ocupado',
        info: naFila > 0 ? '$nome · $naFila na fila' : '$nome',
        reservaId: reservaId,
      );
    }).toList();
  }


  void _avisar(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  Future<void> _solicitarReserva(_Slot slot) async {
    setState(() => _enviando = true);

    final ok = await AuthService.solicitarReserva(
      professorId: int.parse(widget.meuId),
      data: _formatarData(_dias[_diaSelecionado]),
      periodo: slot.hora,
    );

    if (!mounted) return;
    setState(() {
      _enviando = false;
      _carregar();
    });
    _avisar(ok
        ? 'Solicitação enviada! Aguardando as confirmações da secretaria.'
        : 'Não foi possível reservar — o horário pode ter acabado de ser ocupado.');
  }

  Future<void> _entrarNaFila(_Slot slot) async {
    setState(() => _enviando = true);

    final ok = await AuthService.entrarNaFila(
      reservaId: slot.reservaId!,
      professorId: int.parse(widget.meuId),
    );

    if (!mounted) return;
    setState(() => _enviando = false);

    if (!ok) {
      _avisar('Não foi possível entrar na fila agora.');
      return;
    }

    // Já leva o professor para ver a posição dele na fila desse horário.
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FilaEspera(reservaId: slot.reservaId!, meuId: widget.meuId),
      ),
    );
    if (!mounted) return;
    setState(_carregar);
  }

  // ---------- interface ----------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Reservar horário'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Escolha um horário livre',
              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: corTintaSuave),
            ),
            const SizedBox(height: 12),
            _tabsDeDia(),
            const SizedBox(height: 12),
            FutureBuilder<List<_Slot>>(
              future: _futureSlots,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: Center(child: CircularProgressIndicator(color: corAzul)),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 30),
                    child: Column(
                      children: [
                        const Text('Não foi possível carregar os horários.', style: TextStyle(color: corTintaSuave)),
                        TextButton(onPressed: () => setState(_carregar), child: const Text('Tentar de novo')),
                      ],
                    ),
                  );
                }
                final slots = snapshot.data ?? [];
                return Column(
                  children: slots
                      .map((s) => Padding(padding: const EdgeInsets.only(bottom: 8), child: _linhaSlot(s)))
                      .toList(),
                );
              },
            ),
            if (_slotEscolhido != null) ...[
              const SizedBox(height: 6),
              _painelAcao(_slotEscolhido!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tabsDeDia() {
    return Row(
      children: List.generate(_dias.length, (i) {
        final selecionado = i == _diaSelecionado;
        final dia = _dias[i];
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < _dias.length - 1 ? 6 : 0),
            child: OutlinedButton(
              onPressed: () => setState(() {
                _diaSelecionado = i;
                _carregar();
              }),
              style: OutlinedButton.styleFrom(
                backgroundColor: selecionado ? corAzul : Colors.white,
                foregroundColor: selecionado ? Colors.white : corTintaSuave,
                side: BorderSide(color: selecionado ? corAzul : corLinha, width: 1.4),
                padding: const EdgeInsets.symmetric(vertical: 7),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_nomesDias[dia.weekday - 1], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  Text(dia.day.toString().padLeft(2, '0'), style: const TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _linhaSlot(_Slot slot) {
    final escolhido = _slotEscolhido?.hora == slot.hora;

    Widget chip;
    switch (slot.status) {
      case 'livre':
        chip = chipInsspiract('Livre', cor: corVerde, fundo: const Color(0xFFE4F7EC));
        break;
      case 'minha':
        chip = chipInsspiract('Sua', cor: corLaranja, fundo: const Color(0xFFFFF1DF));
        break;
      case 'na_fila':
        chip = chipInsspiract('Na fila', cor: corAvisoTexto, fundo: corAvisoFundo);
        break;
      case 'passado':
        chip = chipInsspiract('Encerrado', cor: corTintaSuave, fundo: const Color(0xFFEEF2F6));
        break;
      default:
        chip = chipInsspiract('Ocupado', cor: corAzul, fundo: const Color(0xFFE9F1FB));
    }

    VoidCallback? aoTocar;
    if (slot.status == 'livre' || slot.status == 'ocupado') {
      aoTocar = () => setState(() => _slotEscolhido = slot);
    } else if (slot.status == 'na_fila') {
      aoTocar = () async {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => FilaEspera(reservaId: slot.reservaId!, meuId: widget.meuId)),
        );
        if (!mounted) return;
        setState(_carregar);
      };
    }

    return Opacity(
      opacity: slot.status == 'passado' ? .55 : 1,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        child: InkWell(
          borderRadius: BorderRadius.circular(13),
          onTap: aoTocar,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(13),
              border: Border.all(color: escolhido ? corLaranja : corLinha, width: 1.4),
              color: escolhido ? const Color(0xFFFFF8EF) : Colors.white,
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 62,
                  child: Text(slot.hora, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                ),
                Expanded(child: Text(slot.info, style: const TextStyle(fontSize: 12, color: corTintaSuave))),
                chip,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _painelAcao(_Slot slot) {
    final livre = slot.status == 'livre';
    final dia = _dias[_diaSelecionado];
    final titulo = livre
        ? 'Solicitar reserva das ${slot.hora} (${_nomesDias[dia.weekday - 1]}, ${dia.day.toString().padLeft(2, '0')})'
        : 'Horário ocupado — ${slot.hora}';
    final explicacao = livre
        ? 'A reserva só é efetivada depois de 3 confirmações da secretaria.'
        : 'Entre na fila de espera: se essa reserva for cancelada, você é o próximo da vez.';

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8EF),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: corLaranjaClaro),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: corTinta)),
          const SizedBox(height: 8),
          Text(explicacao, style: const TextStyle(fontSize: 11.5, color: corTintaSuave)),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              onPressed: _enviando ? null : () => livre ? _solicitarReserva(slot) : _entrarNaFila(slot),
              style: ElevatedButton.styleFrom(
                backgroundColor: corLaranja,
                disabledBackgroundColor: corLaranjaClaro,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: _enviando
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
              )
                  : Text(
                livre ? 'Enviar solicitação' : 'Entrar na fila',
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}