import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:primeiro_app/servicos/AuthService.dart';

class Chat extends StatefulWidget {
  final String nome;
  final int idUsuarioDestino;
  final int meuId;
  final String? foto;

  const Chat({
    super.key,
    required this.nome,
    required this.idUsuarioDestino,
    required this.meuId,
    this.foto,
  });

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _mensagemController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _futureMensagens;
  final ImagePicker _picker = ImagePicker();
  String? _fotoSelecionada; // guarda o caminho da foto escolhida, antes de enviar

  @override
  void initState() {
    super.initState();
    _abrirChat();
  }

  void _abrirChat() async {
    await AuthService.marcarComoVisto(widget.meuId, widget.idUsuarioDestino);
    _carregarMensagens();
  }

  void _carregarMensagens() {
    setState(() {
      _futureMensagens = AuthService.buscarMensagens(
        widget.meuId,
        widget.idUsuarioDestino,
      );
    });
  }

  @override
  void dispose() {
    _mensagemController.dispose();
    super.dispose();
  }

  Future<void> _selecionarFotoDaGaleria() async {
    final XFile? imagemSelecionada = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagemSelecionada != null) {
      setState(() {
        _fotoSelecionada = imagemSelecionada.path;
      });
    }
  }

  void _enviarMensagem() async {
    String conteudo = _mensagemController.text.trim();


    if (conteudo.isEmpty && _fotoSelecionada == null) return;

    bool sucesso = await AuthService.cadastrarMensagem(
      conteudo,
      widget.meuId,
      widget.idUsuarioDestino,
      foto: _fotoSelecionada,
    );

    if (sucesso) {
      _mensagemController.clear();
      setState(() {
        _fotoSelecionada = null;
      });
      _carregarMensagens();
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao enviar mensagem.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        title: Row(
          children: [
            if (widget.foto != null && widget.foto!.isNotEmpty)
              CircleAvatar(
                radius: 16,
                backgroundImage: widget.foto!.startsWith('http')
                    ? NetworkImage(widget.foto!)
                    : AssetImage(widget.foto!) as ImageProvider,
              ),
            if (widget.foto != null && widget.foto!.isNotEmpty)
              const SizedBox(width: 10),
            Text(
              widget.nome,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _futureMensagens,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text(
                      "Nenhuma mensagem ainda... Poxa :(",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final mensagens = snapshot.data!;

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: mensagens.length,
                  itemBuilder: (context, index) {
                    final msg = mensagens[index];
                    bool souEu = msg['DE'] == widget.meuId;
                    final String horario = (msg['HORARIO'] ?? '').toString();
                    final String estado = (msg['ESTADO'] ?? 'ENVIADO MAS NÃO VISTO').toString();
                    final String? fotoMsg = msg['FOTO'] as String?;
                    final String conteudoMsg = (msg['CONTEUDO'] ?? '').toString();

                    return Align(
                      alignment:
                      souEu ? Alignment.centerRight : Alignment.centerLeft,
                      child: Column(
                        crossAxisAlignment: souEu
                            ? CrossAxisAlignment.end
                            : CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 2),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            constraints: const BoxConstraints(maxWidth: 240),
                            decoration: BoxDecoration(
                              color: souEu ? Colors.blue[600] : Colors.grey[800],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (fotoMsg != null && fotoMsg.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: fotoMsg.startsWith('http')
                                        ? Image.network(
                                      fotoMsg,
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                      const Icon(Icons.broken_image,
                                          color: Colors.white54),
                                    )
                                        : Image.file(
                                      File(fotoMsg),
                                      fit: BoxFit.cover,
                                      errorBuilder: (c, e, s) =>
                                      const Icon(Icons.broken_image,
                                          color: Colors.white54),
                                    ),
                                  ),
                                if (fotoMsg != null &&
                                    fotoMsg.isNotEmpty &&
                                    conteudoMsg.isNotEmpty)
                                  const SizedBox(height: 6),
                                if (conteudoMsg.isNotEmpty)
                                  Text(
                                    conteudoMsg,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10,
                              left: 4,
                              right: 4,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (horario.isNotEmpty)
                                  Text(
                                    _formatarHorario(horario),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.white38,
                                    ),
                                  ),

                                if (souEu) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    estado == 'VISTO'
                                        ? Icons.done_all
                                        : Icons.done,
                                    size: 14,
                                    color: estado == 'VISTO'
                                        ? Colors.blue[300]
                                        : Colors.white38,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
          // Prévia da foto escolhida, antes de mandar
          if (_fotoSelecionada != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(_fotoSelecionada!),
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white54),
                    onPressed: () {
                      setState(() {
                        _fotoSelecionada = null;
                      });
                    },
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white12,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.image, color: Colors.blue),
                    onPressed: _selecionarFotoDaGaleria,
                  ),
                  Expanded(
                    child: TextField(
                      controller: _mensagemController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: "Digite sua mensagem...",
                        hintStyle: TextStyle(color: Colors.white38),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _enviarMensagem,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatarHorario(String horarioBanco) {
    try {
      final partes = horarioBanco.split(' ');
      if (partes.length < 2) return horarioBanco;
      return partes[1].substring(0, 5);
    } catch (e) {
      return horarioBanco;
    }
  }
}