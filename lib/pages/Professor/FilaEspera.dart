import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';

class FilaEspera extends StatelessWidget {
  const FilaEspera({super.key});


  static const String _horarioDisputado = 'Quinta, 10:00 – 11:00';
  static const List<Map<String, Object>> _fila = [
    {'nome': 'Prof. Bruna Lima', 'souEu': false},
    {'nome': 'Você', 'souEu': true},
    {'nome': 'Prof. Diego Alves', 'souEu': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, 'Fila de espera'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(_horarioDisputado, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: corTintaSuave)),
            const SizedBox(height: 12),
            ...List.generate(_fila.length, (i) {
              final item = _fila[i];
              final souEu = item['souEu'] as bool;
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
                          child: Text('${i + 1}º', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['nome'] as String, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                              const SizedBox(height: 2),
                              Text(
                                i == 0
                                    ? 'Notificado(a) assim que o horário abrir'
                                    : (souEu
                                    ? 'Você será chamado(a) automaticamente se a posição acima cancelar (RF10)'
                                    : 'Aguardando na fila'),
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
          ],
        ),
      ),
    );
  }
}