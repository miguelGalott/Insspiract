import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/AuthService.dart';
import 'package:primeiro_app/servicos/preferencias_app.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:primeiro_app/servicos/sessao.dart';
import 'package:primeiro_app/pages/Professor/paginaProfessor.dart';
import 'package:primeiro_app/pages/Secretaria/principalSecretaria.dart';
import 'criar.dart';
import 'esqueci_senha_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const Color corAzul = Color(0xFF004C94);
const Color corAzulClaro = Color(0xFF2C7BC7);
const Color corLaranja = Color(0xFFF7941D);
const Color corVerde = Color(0xFF37D67A);


class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController controllerUsu = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();
  bool _isObscure = true;
  bool _carregando = false;

  @override
  void dispose() {
    controllerUsu.dispose();
    controllerSenha.dispose();
    super.dispose();
  }

  void _irParaHome(BuildContext context, String tipo, String id) {
    final Widget? destino = switch (tipo) {
      'PROFESSOR' => PaginaProfessor(meuId: id),
      'SECRETARIA' => PrincipalSecretaria(meuId: id),
      _ => null,
    };

    if (destino == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Tipo de usuário desconhecido: $tipo')),
      );
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => destino),
    );
  }

  Future<void> autenticarServidor(
      BuildContext context,
      String email,
      String senha,
      ) async {
    final String baseUrl = await PreferenciasApp.obterApiUrl();
    final Uri url = Uri.parse('$baseUrl/api/login');

    try {
      var resposta = await http.post(
        url,
        body: {
          'email': email,
          'senha': senha,
        },
      );

      if (resposta.statusCode == 200) {
        final dados = jsonDecode(resposta.body);
        int idLogado = dados['id'];
        String tipo = dados['tipo'];
        String? token = dados['token'];

        await Sessao.salvarUsuarioLogado(idLogado);
        if (token != null) {
          await Sessao.salvarToken(token);
        }

        if (!context.mounted) return;
        _irParaHome(context, tipo, idLogado.toString());
      } else if (resposta.statusCode == 400 || resposta.statusCode == 404) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email ou senha incorretos.')),
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro inesperado no servidor.')),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível conectar ao servidor. Verifique a URL nas Configurações.')),
      );
    }
  }

  void autenticar() async {
    String usuarioDig = controllerUsu.text.trim();
    String senhaDig = controllerSenha.text.trim();

    if (usuarioDig.isEmpty || senhaDig.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha email e senha!')),
      );
      return;
    }

    setState(() => _carregando = true);

    final modo = await PreferenciasApp.obterModoDados();

    if (modo == ModoDados.remoto) {
      await autenticarServidor(context, usuarioDig, senhaDig);
      if (mounted) setState(() => _carregando = false);
      return;
    }

    final resultado = await AuthService.validarLogin(usuarioDig, senhaDig);

    if (!mounted) return;
    setState(() => _carregando = false);

    if (resultado != null) {
      final int id = resultado['id'] as int;
      final String tipo = resultado['tipo'] as String;

      await Sessao.salvarUsuarioLogado(id);

      if (!mounted) return;
      _irParaHome(context, tipo, id.toString());
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email ou senha incorretos.')),
      );
    }
  }

  void _loginAindaNaoImplementado() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Esse tipo de login ainda não foi implementado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Insspiract',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: corAzul),
              ),
              const SizedBox(height: 6),
              const Text(
                'Entrar na sua conta',
                style: TextStyle(fontSize: 13, color: corTintaSuave),
              ),
              const SizedBox(height: 28),

              CampoInsspiract(
                rotulo: 'E-mail institucional',
                controller: controllerUsu,
                dica: 'nome@senac.br',
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Senha', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: corTintaSuave)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: controllerSenha,
                      obscureText: _isObscure,
                      style: const TextStyle(color: corTinta, fontSize: 13.5),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        hintText: '••••••••',
                        hintStyle: const TextStyle(color: Color(0xFFAFC0D0)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: corLinha, width: 1.4)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: corLinha, width: 1.4)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: corAzulClaro, width: 1.6)),
                        suffixIcon: IconButton(
                          icon: Icon(_isObscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: corTintaSuave, size: 20),
                          onPressed: () => setState(() => _isObscure = !_isObscure),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              GestureDetector(
                onTap: () => mostrarDialogoEsqueciSenha(context, controllerUsu.text.trim()),
                child: const Text(
                  "Esqueceu a senha?",
                  style: TextStyle(color: corAzul, fontWeight: FontWeight.w600, fontSize: 12.5),
                ),
              ),

              const SizedBox(height: 22),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corLaranja,
                    disabledBackgroundColor: corLaranjaClaro,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _carregando ? null : autenticar,
                  child: _carregando
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Text(
                    'Entrar',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              Row(
                children: const [
                  Expanded(child: Divider(color: corLinha)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text('ou', style: TextStyle(color: corTintaSuave, fontSize: 12)),
                  ),
                  Expanded(child: Divider(color: corLinha)),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: corLinha, width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _loginAindaNaoImplementado,
                  child: const Text(
                    'Entrar com o Google',
                    style: TextStyle(color: corTinta, fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 36),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    side: const BorderSide(color: corAzul, width: 1.4),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Cadastro()),
                    );
                  },
                  child: const Text(
                    'Criar nova conta',
                    style: TextStyle(color: corAzul, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}