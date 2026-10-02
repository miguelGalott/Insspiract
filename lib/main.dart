import 'package:flutter/material.dart';
import 'package:primeiro_app/pages/Login.dart';
import 'package:primeiro_app/servicos/Tema.dart';

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