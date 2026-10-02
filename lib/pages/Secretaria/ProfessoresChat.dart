import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/pages/Secretaria/Chat.dart';

class ProfessoresChat extends StatelessWidget {
  final String perfil;

  const ProfessoresChat({super.key, required this.perfil});


  static const List<String> _professores = [
    'Prof. Ana Beatriz',
    'Prof. Diego Alves',
    'Prof. Carlos Menezes',
    'Prof. Bruna Lima',
  ];

  @override
  Widget build(BuildContext context) {
    final ehProfessor = perfil == 'professor';

    return Scaffold(
      backgroundColor: corPapel,
      appBar: appBarInsspiract(
        context,
        'Conversas',
        subtitulo: ehProfessor ? 'Fale com a secretaria ou negocie com colegas' : 'Converse com os professores',
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (ehProfessor) ...[
              _tituloSecao('Fale com a secretaria'),
              _cartaoContato(
                context,
                nome: 'Secretaria',
                subtitulo: 'Reclamações e pedidos de item',
                corAvatar: corVerde,
                icone: Icons.shield_outlined,
              ),
              const SizedBox(height: 18),
              _tituloSecao('Negociar horário com colegas'),
            ] else
              _tituloSecao('Professores'),

            ..._professores.map(
                  (nome) => _cartaoContato(context, nome: nome, subtitulo: 'Toque para conversar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _tituloSecao(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 2),
      child: Text(
        texto,
        style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: corTintaSuave, letterSpacing: .2),
      ),
    );
  }

  Widget _cartaoContato(
      BuildContext context, {
        required String nome,
        required String subtitulo,
        Color? corAvatar,
        IconData? icone,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: CartaoInsspiract(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Chat(nome: nome)),
          );
        },
        child: Row(
          children: [
            icone != null
                ? CircleAvatar(
              radius: 20,
              backgroundColor: corAvatar ?? corAzul,
              child: Icon(icone, color: Colors.white, size: 19),
            )
                : avatarIniciais(nome),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(nome, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: corTinta)),
                  Text(subtitulo, style: const TextStyle(fontSize: 11.5, color: corTintaSuave)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: corTintaSuave, size: 20),
          ],
        ),
      ),
    );
  }
}