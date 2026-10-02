import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';


class Chat extends StatefulWidget {
  final String nome;

  const Chat({super.key, required this.nome});

  @override
  State<Chat> createState() => _ChatState();
}

class _Mensagem {
  final String texto;
  final bool souEu;
  final String horario;

  _Mensagem({required this.texto, required this.souEu, required this.horario});
}

class _ChatState extends State<Chat> {
  final TextEditingController _controllerMensagem = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Conversa de exemplo — sem backend ainda, é só a tela. Ainda não temos
  // envio de foto também, então o campo de anexo fica de fora por enquanto.
  final List<_Mensagem> _mensagens = [
    _Mensagem(texto: 'Oi! Posso ficar com o horário de quinta às 10h?', souEu: false, horario: '09:12'),
    _Mensagem(texto: 'Posso sim, te aviso quando a secretaria confirmar.', souEu: true, horario: '09:14'),
  ];

  @override
  void dispose() {
    _controllerMensagem.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _enviarMensagem() {
    final texto = _controllerMensagem.text.trim();
    if (texto.isEmpty) return;

    setState(() {
      _mensagens.add(_Mensagem(texto: texto, souEu: true, horario: 'agora'));
      _controllerMensagem.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(context, widget.nome),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _mensagens.isEmpty
                  ? const Center(
                child: Text('Nenhuma mensagem ainda.', style: TextStyle(color: corTintaSuave)),
              )
                  : ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _mensagens.length,
                itemBuilder: (context, index) => _bolha(_mensagens[index]),
              ),
            ),
            _campoDeEnvio(),
          ],
        ),
      ),
    );
  }

  Widget _bolha(_Mensagem msg) {
    return Align(
      alignment: msg.souEu ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: msg.souEu ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(bottom: 3),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            constraints: const BoxConstraints(maxWidth: 260),
            decoration: BoxDecoration(
              color: msg.souEu ? corAzul : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(14),
                topRight: const Radius.circular(14),
                bottomLeft: Radius.circular(msg.souEu ? 14 : 4),
                bottomRight: Radius.circular(msg.souEu ? 4 : 14),
              ),
              border: msg.souEu ? null : Border.all(color: corLinha, width: 1.4),
            ),
            child: Text(
              msg.texto,
              style: TextStyle(fontSize: 13.5, color: msg.souEu ? Colors.white : corTinta, height: 1.4),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 10, left: 4, right: 4),
            child: Text(msg.horario, style: const TextStyle(fontSize: 10.5, color: corTintaSuave)),
          ),
        ],
      ),
    );
  }

  Widget _campoDeEnvio() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: corLinha, width: 1.4),
        ),
        child: Row(
          children: [
            const SizedBox(width: 6),
            Expanded(
              child: TextField(
                controller: _controllerMensagem,
                style: const TextStyle(color: corTinta, fontSize: 13.5),
                decoration: const InputDecoration(
                  hintText: 'Escrever mensagem...',
                  hintStyle: TextStyle(color: Color(0xFFAFC0D0)),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                ),
                onSubmitted: (_) => _enviarMensagem(),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send_rounded, color: corLaranja),
              onPressed: _enviarMensagem,
            ),
          ],
        ),
      ),
    );
  }
}