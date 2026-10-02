import 'package:flutter/material.dart';

const Color corAzul = Color(0xFF004C94);
const Color corAzulClaro = Color(0xFF2C7BC7);
const Color corLaranja = Color(0xFFF7941D);
const Color corLaranjaClaro = Color(0xFFFDC180);
const Color corVerde = Color(0xFF1C9A55);
const Color corVermelho = Color(0xFFD8484A);
const Color corPapel = Color(0xFFF5F9FC);
const Color corTinta = Color(0xFF0E2338);
const Color corTintaSuave = Color(0xFF5B7188);
const Color corLinha = Color(0xFFE3EAF1);
const Color corAvisoFundo = Color(0xFFFFF1DE);
const Color corAvisoTexto = Color(0xFF8A5306);

PreferredSizeWidget appBarInsspiract(
    BuildContext context,
    String titulo, {
      String? subtitulo,
      List<Widget>? acoes,
      bool comVoltar = true,
    }) {
  return PreferredSize(
    preferredSize: Size.fromHeight(subtitulo == null ? 63 : 76),
    child: AppBar(
      backgroundColor: corAzul,
      elevation: 0,
      centerTitle: false,
      leading: comVoltar
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
        onPressed: () => Navigator.pop(context),
      )
          : null,
      automaticallyImplyLeading: comVoltar,
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            titulo,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
          ),
          if (subtitulo != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                subtitulo,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
        ],
      ),
      actions: acoes,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(height: 3, color: corLaranja),
      ),
    ),
  );
}

Widget avatarIniciais(String nome, {double tamanho = 40, Color? cor}) {
  final partes = nome.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  final iniciais = partes.isEmpty
      ? '?'
      : (partes.length == 1 ? partes[0].substring(0, 1) : partes[0][0] + partes[1][0]).toUpperCase();

  return CircleAvatar(
    radius: tamanho / 2,
    backgroundColor: cor ?? corAzul,
    child: Text(
      iniciais,
      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: tamanho * 0.34),
    ),
  );
}

Widget chipInsspiract(String texto, {required Color cor, required Color fundo}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(color: fundo, borderRadius: BorderRadius.circular(999)),
    child: Text(texto, style: TextStyle(color: cor, fontSize: 11, fontWeight: FontWeight.bold)),
  );
}


class CartaoInsspiract extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  const CartaoInsspiract({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final conteudo = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: corLinha, width: 1.4),
      ),
      child: child,
    );

    if (onTap == null) return conteudo;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: conteudo,
      ),
    );
  }
}

class CampoInsspiract extends StatelessWidget {
  final String rotulo;
  final TextEditingController controller;
  final String dica;
  final bool oculto;
  final int linhas;

  const CampoInsspiract({
    super.key,
    required this.rotulo,
    required this.controller,
    required this.dica,
    this.oculto = false,
    this.linhas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: const TextStyle(
              fontSize: 12, fontWeight: FontWeight.w600, color: corTintaSuave)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            obscureText: oculto,
            maxLines: oculto ? 1 : linhas,
            style: const TextStyle(color: corTinta, fontSize: 13.5),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: dica,
              hintStyle: const TextStyle(color: Color(0xFFAFC0D0)),
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 13),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: corLinha, width: 1.4)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: corLinha, width: 1.4)),
              focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                      color: corAzulClaro, width: 1.6)),
            ),
          ),
        ],
      ),
    );
  }
}
Widget avisoPendente(String texto, {IconData icone = Icons.verified_user_outlined}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: corAvisoFundo,
      borderRadius: BorderRadius.circular(13),
      border: Border.all(color: corLaranjaClaro),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icone, color: corAvisoTexto, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Text(texto, style: const TextStyle(color: corAvisoTexto, fontSize: 12, height: 1.4)),
        ),
      ],
    ),
  );
}