import 'package:primeiro_app/bancoDados/conect.dart';

class AuthService {
  static Future<bool> cadastrarUsuario(Map<String, String> dados) async {
    final db = await ConexaoSqflite.obterConexao();

    try {
      await db.transaction((txn) async {
        int idUsuario = await txn.rawInsert(
          'INSERT INTO USUARIO (USERNAME, EMAIL, NOME, SENHA, TIPO) VALUES (?, ?, ?, ?, ?)',
          [dados['username'], dados['email'], dados['nome'], dados['senha'], dados['tipo']],

        );

        if (dados['tipo'] == 'PROFESSOR') {
          await txn.rawInsert(
            'INSERT INTO PROFESSOR (ID, DIPLOMA, AREA_ENSINO, SALA_HABITUAL) VALUES (?, ?, ?, ?)',
            [idUsuario, dados['diploma'], dados['areaEnsino'], dados['salaHabitual']],
          );
        } else {
          await txn.rawInsert(
            'INSERT INTO SECRETARIA (ID, MATRICULA_FUNCIONAL) VALUES (?, ?)',
            [idUsuario, dados['matriculaFuncional']],
          );
        }
      });

      return true;
    } catch (e) {
      print('Erro ao cadastrar: $e');
      return false;
    }
  }



  static Future<Map<String, dynamic>?> validarLogin(String usuario, String senha) async {
    final db = await ConexaoSqflite.obterConexao();

    final resultado = await db.rawQuery(
      'SELECT ID, TIPO, ESTADO FROM USUARIO WHERE (USERNAME = ? OR EMAIL = ?) AND SENHA = ?',
      [usuario, usuario, senha],
    );

    if (resultado.isEmpty) return null;

    final linha = resultado.first;
    if (linha['ESTADO'] != 'ATIVO') return null;

    return {'id': linha['ID'] as int, 'tipo': linha['TIPO'] as String};
  }

}