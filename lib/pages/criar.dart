import 'package:flutter/material.dart';
import 'package:primeiro_app/servicos/AuthService.dart';
import 'package:primeiro_app/servicos/preferencias_app.dart';
import 'package:primeiro_app/servicos/Tema.dart';
import 'package:http/http.dart' as http;

class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  // Campos comuns
  final TextEditingController controllerUsername = TextEditingController();
  final TextEditingController controllerNome = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();

  final TextEditingController controllerDiploma = TextEditingController();
  final TextEditingController controllerAreaEnsino = TextEditingController();
  final TextEditingController controllerSalaHabitual = TextEditingController();

  final TextEditingController controllerMatricula = TextEditingController();

  String _tipoSelecionado = 'PROFESSOR';
  bool _isObscure = true;
  bool _carregando = false;

  @override
  void dispose() {
    controllerUsername.dispose();
    controllerNome.dispose();
    controllerEmail.dispose();
    controllerSenha.dispose();
    controllerDiploma.dispose();
    controllerAreaEnsino.dispose();
    controllerSalaHabitual.dispose();
    controllerMatricula.dispose();
    super.dispose();
  }

  void cadastrar() async {
    final username = controllerUsername.text.trim();
    final nome = controllerNome.text.trim();
    final email = controllerEmail.text.trim();
    final senha = controllerSenha.text.trim();

    if (username.isEmpty || nome.isEmpty || email.isEmpty || senha.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios!')),
      );
      return;
    }

    if (_tipoSelecionado == 'PROFESSOR') {
      if (controllerDiploma.text.trim().isEmpty || controllerAreaEnsino.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha diploma e área de ensino!')),
        );
        return;
      }
    } else {
      if (controllerMatricula.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Preencha a matrícula funcional!')),
        );
        return;
      }
    }

    setState(() => _carregando = true);

    final dados = <String, String>{
      'tipo': _tipoSelecionado,
      'username': username,
      'nome': nome,
      'email': email,
      'senha': senha,
      if (_tipoSelecionado == 'PROFESSOR') ...{
        'diploma': controllerDiploma.text.trim(),
        'areaEnsino': controllerAreaEnsino.text.trim(),
        'salaHabitual': controllerSalaHabitual.text.trim(),
      } else ...{
        'matriculaFuncional': controllerMatricula.text.trim(),
      },
    };

    final modo = await PreferenciasApp.obterModoDados();

    if (modo == ModoDados.remoto) {
      await _cadastrarNoServidor(dados);
      if (mounted) setState(() => _carregando = false);
      return;
    }
    bool cadastradoValido = await AuthService.cadastrarUsuario(dados);

    if (!mounted) return;
    setState(() => _carregando = false);

    if (cadastradoValido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Solicitação enviada! Aguarde a aprovação da secretaria.')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível cadastrar (usuário ou email já existe?).')),
      );
    }
  }

  Future<void> _cadastrarNoServidor(Map<String, String> dados) async {
    final String baseUrl = await PreferenciasApp.obterApiUrl();
    final Uri url = Uri.parse('$baseUrl/api/cadastro');

    try {
      var resposta = await http.post(url, body: dados);

      if (!mounted) return;

      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Solicitação enviada! Aguarde a aprovação da secretaria.')),
        );
        Navigator.pop(context);
      } else if (resposta.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resposta.body}')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro não detectado (${resposta.statusCode}).')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível conectar ao servidor. Verifique a URL nas Configurações.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: corPapel,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(63),
        child: AppBar(
          backgroundColor: corAzul,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 18),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Criar conta',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 17),
          ),
          centerTitle: false,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(3),
            child: Container(height: 3, color: corLaranja),
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Você quer se cadastrar como',
                style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: corTintaSuave, letterSpacing: .2),
              ),
              const SizedBox(height: 10),
              _seletorDeTipo(),
              const SizedBox(height: 20),

              CampoInsspiract(
                rotulo: 'Nome de usuário',
                controller: controllerUsername,
                dica: 'nome_de_usuario',
              ),
              CampoInsspiract(
                rotulo: 'Nome completo',
                controller: controllerNome,
                dica: 'Seu nome',
              ),
              CampoInsspiract(
                rotulo: 'E-mail',
                controller: controllerEmail,
                dica: 'seuemail@exemplo.com',
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
                        hintText: 'Sua senha',
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

              if (_tipoSelecionado == 'PROFESSOR') ...[
                CampoInsspiract(
                  rotulo: 'Diploma',
                  controller: controllerDiploma,
                  dica: 'Ex.: Licenciatura em Computação',
                ),
                CampoInsspiract(
                  rotulo: 'Área de ensino',
                  controller: controllerAreaEnsino,
                  dica: 'Ex.: Desenvolvimento de Sistemas',
                ),
                CampoInsspiract(
                  rotulo: 'Sala habitual (opcional)',
                  controller: controllerSalaHabitual,
                  dica: 'Ex.: Sala 12',
                ),
              ],

              if (_tipoSelecionado == 'SECRETARIA')
                CampoInsspiract(
                  rotulo: 'Matrícula funcional',
                  controller: controllerMatricula,
                  dica: 'Nº de matrícula',
                ),

              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _carregando ? null : cadastrar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: corLaranja,
                    disabledBackgroundColor: corLaranjaClaro,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _carregando
                      ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                  )
                      : const Text(
                    'Cadastrar',
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _seletorDeTipo() {
    return Row(
      children: [
        Expanded(child: _botaoTipo('PROFESSOR', 'Professor')),
        const SizedBox(width: 10),
        Expanded(child: _botaoTipo('SECRETARIA', 'Secretaria')),
      ],
    );
  }

  Widget _botaoTipo(String valor, String rotulo) {
    final selecionado = _tipoSelecionado == valor;
    return OutlinedButton(
      onPressed: () => setState(() => _tipoSelecionado = valor),
      style: OutlinedButton.styleFrom(
        backgroundColor: selecionado ? corAzul : Colors.white,
        foregroundColor: selecionado ? Colors.white : corTintaSuave,
        side: BorderSide(color: selecionado ? corAzul : corLinha, width: 1.4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(rotulo, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold)),
    );
  }
}