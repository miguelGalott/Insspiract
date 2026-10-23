import 'package:primeiro_app/bancoDados/conect.dart';

class AuthService {
  static Future<bool> cadastrarUsuario(Map<String, String> dados) async {
    final db = await ConexaoSqflite.obterConexao();

    try {
      await db.transaction((txn) async {
        int idUsuario = await txn.rawInsert(
          'INSERT INTO USUARIO (USERNAME, EMAIL, NOME, SENHA, TIPO) VALUES (?, ?, ?, ?, ?)',
          [
            dados['username'],
            dados['email'],
            dados['nome'],
            dados['senha'],
            dados['tipo'],
          ],
        );

        if (dados['tipo'] == 'PROFESSOR') {
          await txn.rawInsert(
            'INSERT INTO PROFESSOR (ID, DIPLOMA, AREA_ENSINO, SALA_HABITUAL) VALUES (?, ?, ?, ?)',
            [
              idUsuario,
              dados['diploma'],
              dados['areaEnsino'],
              dados['salaHabitual'],
            ],
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

  static Future<Map<String, dynamic>?> validarLogin(
      String usuario,
      String senha,
      ) async {
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
    required int reservaId,
    required int professorId,
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
    SELECT FILA_ESPERA.PROFESSOR_ID, FILA_ESPERA.POSICAO, FILA_ESPERA.ESTADO, USUARIO.NOME
    FROM FILA_ESPERA
    JOIN USUARIO ON USUARIO.ID = FILA_ESPERA.PROFESSOR_ID
    WHERE FILA_ESPERA.RESERVA_ID = ?
    ORDER BY FILA_ESPERA.POSICAO ASC
    ''',
      [reservaId],
    );
  }

  static Future<List<Map<String, dynamic>>> listarAgendamentos(
      int professorId,
      ) async {
    final db = await ConexaoSqflite.obterConexao();

    return db.rawQuery(
      '''
    SELECT
      RESERVAS.ID,
     RESERVAS.AGENDAMENTO,
      RESERVAS.PERIODO,
     RESERVAS.ESTADO,
      SALA.NOME AS SALA_NOME,
      (SELECT COUNT(*) FROM CONFIRMACAO_RESERVA WHERE CONFIRMACAO_RESERVA.RESERVA_ID = RESERVAS.ID) AS CONFIRMACOES
    FROM RESERVAS
    JOIN SALA ON SALA.ID = RESERVAS.SALA_ID
    WHERE RESERVAS.PROFESSOR_ID = ?
    ORDER BY RESERVAS.AGENDAMENTO ASC, RESERVAS.PERIODO ASC
    ''',
      [professorId],
    );
  }
  static Future<bool> cancelarReserva(int reservaId) async{
    final db = await ConexaoSqflite.obterConexao();
    try{

      await db.rawUpdate("UPDATE RESERVAS SET ESTADO = 'CANCELADA' WHERE ID = ?", [reservaId]);
      return true;
    }
    catch (e){
      print('Erro ao cancelar reserva: $e');
      return false;
    }
  }
  static Future<bool> enviarAviso({
    required int secretariaId,
    required String titulo,
    required String mensagem,
  }) async {
    final db = await ConexaoSqflite.obterConexao();

    try {
      await db.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO AVISO (SECRETARIA_ID, TITULO, MENSAGEM) VALUES (?, ?, ?)',
          [secretariaId, titulo, mensagem],
        );
      });
      return true;
    } catch (e) {
      print('Erro ao mandar aviso: $e');
      return false;
    }
  }


  static Future<bool> validarCad({required int idUsuario}) async {
    final db = await ConexaoSqflite.obterConexao();

    try {
      return await db.transaction((txn) async {
        final res = await txn.rawQuery('SELECT APROVACOES FROM USUARIO WHERE ID = ?', [idUsuario]);
        if (res.isEmpty) return false;

        final int aprovacoes = (res.first['APROVACOES'] as int?) ?? 0;
        final int novaAprovacao = aprovacoes + 1;

        if (novaAprovacao >= 3) {
          await txn.rawUpdate(
            'UPDATE USUARIO SET ESTADO = ?, APROVACOES = ? WHERE ID = ?',
            ['ATIVO', novaAprovacao, idUsuario],
          );
        } else {
          await txn.rawUpdate('UPDATE USUARIO SET APROVACOES = ? WHERE ID = ?', [novaAprovacao, idUsuario]);
        }
        return true;
      });
    } catch (e) {
      print('Erro ao atualizar aprovação: $e');
      return false;
    }
  }




  static Future<bool> recusoCad({required int idUsuario}) async {
    final db = await ConexaoSqflite.obterConexao();

    try {
      return await db.transaction((txn) async {
        final res = await txn.rawQuery('SELECT APROVACOES FROM USUARIO WHERE ID = ?', [idUsuario]);
        if (res.isEmpty) return false;

        final int aprovacoes = (res.first['APROVACOES'] as int?) ?? 0;

        final int novaAprovacao = aprovacoes - 1 < -1 ? -1 : aprovacoes - 1;

        if (novaAprovacao <= -1) {
          await txn.rawUpdate(
            'UPDATE USUARIO SET ESTADO = ?, APROVACOES = ? WHERE ID = ?',
            ['RECUSADO', novaAprovacao, idUsuario],
          );
        } else {
          await txn.rawUpdate('UPDATE USUARIO SET APROVACOES = ? WHERE ID = ?', [novaAprovacao, idUsuario]);
        }
        return true;
      });
    } catch (e) {
      print('Erro ao atualizar aprovação: $e');
      return false;
    }
  }

  static Future<List<Map<String, dynamic>>> listarCadastrosPendentes() async {
    final db = await ConexaoSqflite.obterConexao();

    return db.rawQuery('''
    SELECT
      USUARIO.ID, USUARIO.NOME, USUARIO.EMAIL, USUARIO.TIPO, USUARIO.APROVACOES,
      PROFESSOR.AREA_ENSINO,
      SECRETARIA.MATRICULA_FUNCIONAL
    FROM USUARIO
    LEFT JOIN PROFESSOR ON PROFESSOR.ID = USUARIO.ID
    LEFT JOIN SECRETARIA ON SECRETARIA.ID = USUARIO.ID
    WHERE USUARIO.ESTADO = 'PENDENTE'
    ORDER BY USUARIO.CRIADO_EM ASC
  ''');
  }


  static Future<List<Map<String, dynamic>>> listarReservasParaGerenciar() async {
    final db = await ConexaoSqflite.obterConexao();
    return db.rawQuery('''
    SELECT
      RESERVAS.ID,
      RESERVAS.AGENDAMENTO,
      RESERVAS.PERIODO,
      RESERVAS.ESTADO,
      USUARIO.NOME AS PROFESSOR_NOME,
      (SELECT COUNT(*) FROM CONFIRMACAO_RESERVA
        WHERE CONFIRMACAO_RESERVA.RESERVA_ID = RESERVAS.ID) AS CONFIRMACOES
    FROM RESERVAS
    JOIN PROFESSOR ON PROFESSOR.ID = RESERVAS.PROFESSOR_ID
    JOIN USUARIO ON USUARIO.ID = PROFESSOR.ID
    WHERE RESERVAS.ESTADO != 'CANCELADA'
    ORDER BY RESERVAS.AGENDAMENTO ASC
  ''');
  }




  static Future<bool> confirmarReserva({
    required int reservaId,
    required int secretariaId,
  }) async {
    final db = await ConexaoSqflite.obterConexao();
    try {
      await db.transaction((txn) async {
        await txn.rawInsert(
          'INSERT INTO CONFIRMACAO_RESERVA (RESERVA_ID, SECRETARIA_ID) VALUES (?, ?)',
          [reservaId, secretariaId],
        );

        final resultado = await txn.rawQuery(
          'SELECT COUNT(*) AS total FROM CONFIRMACAO_RESERVA WHERE RESERVA_ID = ?',
          [reservaId],
        );
        final total = resultado.first['total'] as int;

        if (total >= 3) {
          await txn.rawUpdate(
            "UPDATE RESERVAS SET ESTADO = 'CONFIRMADA' WHERE ID = ?",
            [reservaId],
          );
        }
      });
      return true;
    } catch (e) {

      return false;
    }
  }






  static Future<List<Map<String, dynamic>>> relatorioDeUso() async {
    final db = await ConexaoSqflite.obterConexao();

    final reservasPorMes = await db.rawQuery('''
    SELECT
      strftime('%Y-%m', AGENDAMENTO) AS MES,
      COUNT(*) AS TOTAL,
      SUM(CASE WHEN ESTADO = 'CANCELADA' THEN 1 ELSE 0 END) AS CANCELADAS
    FROM RESERVAS
    GROUP BY MES
    ORDER BY MES
  ''');

    final solicitacoesPorMes = await db.rawQuery('''
    SELECT
      strftime('%Y-%m', CRIADO_EM) AS MES,
      SUM(CASE WHEN TIPO = 'RECLAMACAO' THEN 1 ELSE 0 END) AS RECLAMACOES,
      SUM(CASE WHEN TIPO = 'PEDIDO' THEN 1 ELSE 0 END) AS PEDIDOS
    FROM SOLICITACAO
    GROUP BY MES
    ORDER BY MES
  ''');

    final Map<String, Map<String, dynamic>> porMes = {};

    for (final linha in reservasPorMes) {
      final mes = linha['MES'] as String;
      porMes[mes] = {
        'MES': mes,
        'TOTAL': linha['TOTAL'] as int,
        'CANCELADAS': linha['CANCELADAS'] as int,
        'RECLAMACOES': 0,
        'PEDIDOS': 0,
      };
    }

    for (final linha in solicitacoesPorMes) {
      final mes = linha['MES'] as String;
      final atual = porMes[mes] ?? {
        'MES': mes,
        'TOTAL': 0,
        'CANCELADAS': 0,
        'RECLAMACOES': 0,
        'PEDIDOS': 0,
      };
      atual['RECLAMACOES'] = linha['RECLAMACOES'] as int;
      atual['PEDIDOS'] = linha['PEDIDOS'] as int;
      porMes[mes] = atual;
    }

    final lista = porMes.values.toList();
    lista.sort((a, b) => (a['MES'] as String).compareTo(b['MES'] as String));
    return lista;
  }


  static Future<List<Map<String, dynamic>>> listarHorariosDoDia({
    required String data,
    required int professorId,
  }) async {
    final db = await ConexaoSqflite.obterConexao();

    return db.rawQuery('''
    SELECT
      RESERVAS.ID,
      RESERVAS.PERIODO,
      RESERVAS.ESTADO,
      RESERVAS.PROFESSOR_ID,
      USUARIO.NOME AS PROFESSOR_NOME,
      (SELECT COUNT(*) FROM FILA_ESPERA
        WHERE FILA_ESPERA.RESERVA_ID = RESERVAS.ID
          AND FILA_ESPERA.ESTADO = 'AGUARDANDO') AS NA_FILA,
      (SELECT COUNT(*) FROM FILA_ESPERA
        WHERE FILA_ESPERA.RESERVA_ID = RESERVAS.ID
          AND FILA_ESPERA.PROFESSOR_ID = ?) AS EU_NA_FILA
    FROM RESERVAS
    JOIN USUARIO ON USUARIO.ID = RESERVAS.PROFESSOR_ID
    WHERE date(RESERVAS.AGENDAMENTO) = ?
      AND RESERVAS.ESTADO != 'CANCELADA'
  ''', [professorId, data]);
  }

  static Future<bool> solicitarReserva({
    required int professorId,
    required String data,
    required String periodo,
  }) async {
    final db = await ConexaoSqflite.obterConexao();
    try {
      return await db.transaction((txn) async {
        final ocupado = await txn.rawQuery('''
        SELECT COUNT(*) AS total FROM RESERVAS
        WHERE date(AGENDAMENTO) = ? AND PERIODO = ? AND ESTADO != 'CANCELADA'
      ''', [data, periodo]);
        if ((ocupado.first['total'] as int) > 0) return false;

        final sala = await txn.rawQuery('SELECT ID FROM SALA ORDER BY ID LIMIT 1');
        if (sala.isEmpty) return false;

        await txn.rawInsert(
          'INSERT INTO RESERVAS (SALA_ID, PROFESSOR_ID, AGENDAMENTO, PERIODO) VALUES (?, ?, ?, ?)',
          [sala.first['ID'], professorId, data, periodo],
        );
        return true;
      });
    } catch (e) {
      return false;
    }
  }
}