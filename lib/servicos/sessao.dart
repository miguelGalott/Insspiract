import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sessao {
  static const String _chaveToken = 'TOKEN_AUTOTICACAO';
  static const String _chaveIdUsuario = 'ID_USUARIO_LOGADO';

  static const FlutterSecureStorage _storageSeguro = FlutterSecureStorage();


  static Future<void> salvarUsuarioLogado(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_chaveIdUsuario, id);
  }

  static Future<int?> obterUsuarioLogado() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_chaveIdUsuario);
  }


  static Future<void> salvarToken(String token) async {
    await _storageSeguro.write(key: _chaveToken, value: token);
  }


static Future<String?> obterToken() async{

    return await _storageSeguro.read (key: _chaveToken);

}


  static Future<void> sair() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chaveIdUsuario);
    await _storageSeguro.delete(key: _chaveToken);
  }
}


