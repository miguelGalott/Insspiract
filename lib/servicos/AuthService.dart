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

  static Future<bool> enviarSolicitacao({
    required int professorId,
    required String tipo,
    required String descricao,
  }) async {
    final db = await ConexaoSqflite.obterConexao();

    try {
      await db.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO SOLICITACAO (PROFESSOR_ID, TIPO, DESCRICAO) VALUES (?, ?, ?)',
          [professorId, tipo, descricao],
        );
      });
      return true;
    } catch (e) {
      print('Erro ao inserir solicitação: $e');
      return false;
    }
  }

  static Future<bool> entrarNaFila({
    required int reservaId, required int professorId,
  }) async {
    final db = await ConexaoSqflite.obterConexao();

    try {
      await db.transaction((txn) async {
        final resultado = await txn.rawQuery(
          'SELECT COUNT(*) AS total FROM FILA_ESPERA WHERE RESERVA_ID = ?',
          [reservaId],
        );
        final int posicao = (resultado.first['total'] as int) + 1;

        await txn.rawInsert(
          'INSERT INTO FILA_ESPERA (RESERVA_ID, PROFESSOR_ID, POSICAO) VALUES (?, ?, ?)',
          [reservaId, professorId, posicao],
        );
      });
      return true;
    } catch (e) {
      print('Erro ao entrar na fila: $e');
      return false;
    }
  }


  static Future<List<Map<String, dynamic>>> listarFila(int reservaId) async {
    final db = await ConexaoSqflite.obterConexao();

    return db.rawQuery(
      '''
    SELECTILA_ FILA_ESPERA.PROFESSOR_ID, FILA_ESPERA.POSICAO, FILA_ESPERA.ESTADO, USUARIO.NOME
    FROM FESPERA
    JOIN USUARIO ON USUARIO.ID = FILA_ESPERA.PROFESSOR_ID
    WHERE FILA_ESPERA.RESERVA_ID = ?
    ORDER BY FILA_ESPERA.POSICAO ASC
    ''',
      [reservaId],
    );
  }


}