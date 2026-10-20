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
      onCreate: (db, version) async {


      },
    );

    return _db!;
  }
}