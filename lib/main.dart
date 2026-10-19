import 'package:flutter/material.dart';
import 'package:primeiro_app/pages/Login.dart';
import 'package:primeiro_app/servicos/Tema.dart';

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


void main() {
  runApp(const InsspiractApp());
}

class InsspiractApp extends StatelessWidget {
  const InsspiractApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Insspiract',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: corPapel,
        colorScheme: ColorScheme.fromSeed(
          seedColor: corAzul,
          primary: corAzul,
          secondary: corLaranja,
        ),
      ),
      home: const Login(),
    );
  }
}