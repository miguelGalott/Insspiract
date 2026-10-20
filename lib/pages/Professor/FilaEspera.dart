import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/AuthService.dart';

class FilaEspera extends StatefulWidget {
  final int reservaId;
  final String meuId;

  const FilaEspera({super.key, required this.reservaId, required this.meuId});

  @override
  State<FilaEspera> createState() => _FilaEsperaState();
}

class _FilaEsperaState extends State<FilaEspera> {
  late Future<List<Map<String, dynamic>>> _futureFila;
  bool _entrando = false;

  @override
  void initState() {
    super.initState();
    _carregarFila();
  }

  void _carregarFila() {
    setState(() {
      _futureFila = AuthService.listarFila(widget.reservaId);
    });
  }

  Future<void> _entrarNaFila() async {
    setState(() => _entrando = true);

    final sucesso = await AuthService.entrarNaFila(
      reservaId: widget.reservaId,
      professorId: int.parse(widget.meuId),
    );

    if (!mounted) return;
    setState(() => _entrando = false);

    if (sucesso) {
      _carregarFila();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível entrar na fila agora.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Fila de espera'),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _futureFila,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: corAzul));
            }

            final fila = snapshot.data ?? [];
            final jaEstouNaFila = fila.any((item) => item['PROFESSOR_ID'].toString() == widget.meuId);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (fila.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Ninguém na fila ainda.', style: TextStyle(color: corTintaSuave))),
                  )
                else
                  ...List.generate(fila.length, (i) {
                    final item = fila[i];
                    final souEu = item['PROFESSOR_ID'].toString() == widget.meuId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: CartaoInsspiract(
                        padding: const EdgeInsets.all(0),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: souEu
                              ? BoxDecoration(
                            color: const Color(0xFFFFF8EF),
                            borderRadius: BorderRadius.circular(15),
                            border: Border.all(color: corLaranja, width: 1.4),
                          )
                              : null,
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: souEu ? corLaranja : corAzul,
                                child: Text('${item['POSICAO']}º', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(souEu ? 'Você' : item['NOME'] as String, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                                    const SizedBox(height: 2),
                                    Text(
                                      item['POSICAO'] == 1
                                          ? 'Notificado(a) assim que o horário abrir'
                                          : (souEu ? 'Você será chamado(a) automaticamente (RF10)' : 'Aguardando na fila'),
                                      style: const TextStyle(fontSize: 11.5, color: corTintaSuave),
                                    ),
                                  ],
                                ),
                              ),
                              if (souEu) chipInsspiract('Em fila', cor: corAvisoTexto, fundo: corAvisoFundo),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                if (!jaEstouNaFila) ...[
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _entrando ? null : _entrarNaFila,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: corLaranja,
                        disabledBackgroundColor: corLaranjaClaro,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
                      ),
                      child: _entrando
                          ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4))
                          : const Text('Entrar na fila', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}