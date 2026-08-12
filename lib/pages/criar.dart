import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sqflite/sqflite.dart';
import 'package:primeiro_app/bancoDados/conect.dart';
import 'package:primeiro_app/servicos/AuthService.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class Cadastro extends StatefulWidget {
  const Cadastro({super.key});

  @override
  State<Cadastro> createState() => _CadastroState();
}

class _CadastroState extends State<Cadastro> {
  final TextEditingController controllerUsu = TextEditingController();
  final TextEditingController controllerSenha = TextEditingController();
  final TextEditingController controllerEmail = TextEditingController();
  final TextEditingController controllerFoto = TextEditingController();

  String? _caminhoFoto;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    controllerUsu.dispose();
    controllerSenha.dispose();
    controllerEmail.dispose();
    controllerFoto.dispose();
    super.dispose();
  }

  Future<void> _selecionarFotoDaGaleria() async {
    final XFile? imagemSelecionada = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (imagemSelecionada != null) {
      setState(() {
        _caminhoFoto = imagemSelecionada.path;
        controllerFoto.text = imagemSelecionada.path;
      });
    }
  }

  static Future<bool> cadastrarUsuario(
      String usu,
      String senha,
      String email,
      String foto,
      ) async {
    try {
      Database db = await ConexaoSqflite.obterConexao();

      int idGerado = await db.rawInsert(
        'INSERT INTO USUARIOS (NOME, SENHA, EMAIL, FOTO) VALUES (?, ?, ?, ?)',
        [usu, senha, email, foto],
      );

      print("Usuário cadastrado com sucesso! ID: $idGerado");
      return idGerado > 0;
    } catch (e) {
      print("Erro ao cadastrar no SQLite: $e");
      return false;
    }
  }

  void cadastrar() async {
    String usuarioDig = controllerUsu.text.trim();
    String senhaDig = controllerSenha.text.trim();
    String emailDig = controllerEmail.text.trim();
    String fotoParaSalvar = controllerFoto.text.trim();

    if (usuarioDig.isEmpty || senhaDig.isEmpty || emailDig.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios!')),
      );
      return;
    }

    bool cadastradoValido = await AuthService.cadastrarUsuario(
      usuarioDig,
      senhaDig,
      emailDig,
      fotoParaSalvar,
    );

    if (cadastradoValido) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
      );


      Navigator.pop(context);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Algo deu errado ao cadastrar, desculpe.'),
        ),
      );
    }
  }

  void cadastrarNoProfessor() async {
    String usuarioDig = controllerUsu.text.trim();
    String senhaDig = controllerSenha.text.trim();
    String emailDig = controllerEmail.text.trim();


    if (usuarioDig.isEmpty || senhaDig.isEmpty || emailDig.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha os campos obrigatórios!')),
      );
      return;
    }


    var url = Uri.http("10.112.4.154", "/api/cadastro");

    try {
      var resposta = await http.post(
        url,
        body: {
          'nome': usuarioDig,
          'senha': senhaDig,
          'email': emailDig,

        },
      );

      if (resposta.statusCode == 200 || resposta.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Usuário cadastrado com sucesso!')),
        );
        Navigator.pop(context);
      } else if (resposta.statusCode == 400) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: ${resposta.body}')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro inesperado (${resposta.statusCode}).'),
          ),
        );
      }
    } catch (e) {
      print("Erro de conexão com o servidor: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível conectar ao servidor.')),
      );
    }
  }



  bool _ehUrl(String caminho) {
    return caminho.startsWith('http://') || caminho.startsWith('https://');
  }

  @override
  Widget build(BuildContext contexto) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Center(
                  child: Text(
                    "Criar Login",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Preencha as informações abaixo',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
                const SizedBox(height: 20),

                Center(
                  child: GestureDetector(
                    onTap: _selecionarFotoDaGaleria,
                    child: CircleAvatar(
                      radius: 45,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: _caminhoFoto != null && _caminhoFoto!.isNotEmpty
                          ? (_ehUrl(_caminhoFoto!)
                          ? NetworkImage(_caminhoFoto!) as ImageProvider
                          : FileImage(File(_caminhoFoto!)))
                          : null,
                      child: _caminhoFoto == null || _caminhoFoto!.isEmpty
                          ? const Icon(
                        Icons.add_a_photo,
                        color: Colors.white,
                        size: 30,
                      )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 12),


                const Center(
                  child: Text(
                    "Toque para selecionar foto ou insira o link HTTP da imagem",
                    style: TextStyle(color: Colors.white54, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 8),


                TextField(
                  controller: controllerFoto,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (valor) {
                    setState(() {
                      _caminhoFoto = valor.isEmpty ? null : valor;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Http:// ou caminho do arquivo",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Nome", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                TextField(
                  controller: controllerUsu,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Nome de usuário",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Email", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                TextField(
                  controller: controllerEmail,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "seuemail@exemplo.com",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                const Text("Senha", style: TextStyle(color: Colors.white)),
                const SizedBox(height: 8),
                TextField(
                  controller: controllerSenha,
                  obscureText: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Sua senha",
                    hintStyle: const TextStyle(color: Colors.white38),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                  ),
                ),

                const SizedBox(height: 90),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: cadastrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Cadastrar",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "Voltar",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],

            ),
          ),
        ),
      ),
    );
  }
}