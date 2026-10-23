import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ConexaoSqflite {
  static Database? _db;

  static Future<Database> obterConexao() async {
    if (_db != null) return _db!;

    final caminho = join(await getDatabasesPath(), 'insspiract.db');
    _db = await openDatabase(
      caminho,
      version: 1,

      onConfigure: (db) async => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE USUARIO (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            USERNAME TEXT NOT NULL UNIQUE,
            EMAIL TEXT NOT NULL UNIQUE,
            NOME TEXT NOT NULL,
            SENHA TEXT NOT NULL,
            TIPO TEXT NOT NULL CHECK (TIPO IN ('PROFESSOR','SECRETARIA')),
            ESTADO TEXT NOT NULL DEFAULT 'PENDENTE'
              CHECK (ESTADO IN ('PENDENTE','ATIVO','RECUSADO')),
            APROVACOES INTEGER NOT NULL DEFAULT 0
              CHECK (APROVACOES > -2 AND APROVACOES <= 5),
            CODIGO_VERIFICACAO TEXT,
            CRIADO_EM TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
          )
        ''');

        await db.execute('''
          CREATE TABLE PROFESSOR (
            ID INTEGER PRIMARY KEY,
            DIPLOMA TEXT,
            AREA_ENSINO TEXT,
            SALA_HABITUAL TEXT,
            FOREIGN KEY (ID) REFERENCES USUARIO(ID) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE SECRETARIA (
            ID INTEGER PRIMARY KEY,
            MATRICULA_FUNCIONAL TEXT,
            FOREIGN KEY (ID) REFERENCES USUARIO(ID) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE SALA (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            NOME TEXT NOT NULL,
            DESCRICAO TEXT,
            RECURSOS TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE RESERVAS (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            SALA_ID INTEGER NOT NULL,
            PROFESSOR_ID INTEGER NOT NULL,
            AGENDAMENTO TEXT NOT NULL,
            PERIODO TEXT NOT NULL,
            ESTADO TEXT NOT NULL DEFAULT 'PENDENTE'
              CHECK (ESTADO IN ('EM_FILA','PENDENTE','CONFIRMADA','CANCELADA')),
            FOREIGN KEY (SALA_ID) REFERENCES SALA(ID),
            FOREIGN KEY (PROFESSOR_ID) REFERENCES PROFESSOR(ID) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE CONFIRMACAO_RESERVA (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            APROVACOES INTEGER NOT NULL DEFAULT 0,
            RESERVA_ID INTEGER NOT NULL,
            SECRETARIA_ID INTEGER NOT NULL,
            CONFIRMADO_EM TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            UNIQUE (RESERVA_ID, SECRETARIA_ID),
            FOREIGN KEY (RESERVA_ID) REFERENCES RESERVAS(ID) ON DELETE CASCADE,
            FOREIGN KEY (SECRETARIA_ID) REFERENCES SECRETARIA(ID) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE FILA_ESPERA (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            RESERVA_ID INTEGER NOT NULL,
            PROFESSOR_ID INTEGER NOT NULL,
            POSICAO INTEGER NOT NULL,
            ESTADO TEXT NOT NULL DEFAULT 'AGUARDANDO'
              CHECK (ESTADO IN ('AGUARDANDO','NOTIFICADO','EXPIRADO')),
            FOREIGN KEY (RESERVA_ID) REFERENCES RESERVAS(ID) ON DELETE CASCADE,
            FOREIGN KEY (PROFESSOR_ID) REFERENCES PROFESSOR(ID) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE SOLICITACAO (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            PROFESSOR_ID INTEGER NOT NULL,
            TIPO TEXT NOT NULL CHECK (TIPO IN ('RECLAMACAO','PEDIDO')),
            ESTADO TEXT NOT NULL DEFAULT 'PENDENTE'
              CHECK (ESTADO IN ('PENDENTE','RESPONDIDA')),
            DESCRICAO TEXT NOT NULL,
            RESPOSTA TEXT,
            RESPONDIDO_POR INTEGER,
            CRIADO_EM TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (PROFESSOR_ID) REFERENCES PROFESSOR(ID) ON DELETE CASCADE,
            FOREIGN KEY (RESPONDIDO_POR) REFERENCES SECRETARIA(ID) ON DELETE SET NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE AVISO (
            ID INTEGER PRIMARY KEY AUTOINCREMENT,
            SECRETARIA_ID INTEGER NOT NULL,
            TITULO TEXT NOT NULL,
            MENSAGEM TEXT NOT NULL,
            DATA_ENVIO TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY (SECRETARIA_ID) REFERENCES SECRETARIA(ID) ON DELETE CASCADE
          )
        ''');

        await db.execute('''
          CREATE TABLE AVISO_DESTINO (
            AVISO_ID INTEGER NOT NULL,
            PROFESSOR_ID INTEGER NOT NULL,
            PRIMARY KEY (AVISO_ID, PROFESSOR_ID),
            FOREIGN KEY (AVISO_ID) REFERENCES AVISO(ID) ON DELETE CASCADE,
            FOREIGN KEY (PROFESSOR_ID) REFERENCES PROFESSOR(ID) ON DELETE CASCADE
          )
        ''');

        await db.insert('SALA', {
          'NOME': 'Sala Inspira',
          'DESCRICAO': 'Sala de reservas',
          'RECURSOS': '',
        });

        final idAdmin = await db.insert('USUARIO', {
          'USERNAME': 'admin',
          'EMAIL': 'admin@insspiract.com',
          'NOME': 'Secretaria Teste',
          'SENHA': '123456',
          'TIPO': 'SECRETARIA',
          'ESTADO': 'ATIVO',
        });
        await db.insert('SECRETARIA', {
          'ID': idAdmin,
          'MATRICULA_FUNCIONAL': '0001',
        });
      },
    );

    return _db!;
  }
}