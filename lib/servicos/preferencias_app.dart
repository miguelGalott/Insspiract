import 'package:shared_preferences/shared_preferences.dart';

enum ModoDados { local, remoto }

class PreferenciasApp {
  static const String _chaveModo = 'MODO_DADOS';
  static const String _chaveApiUrl = 'API_URL';

  static const ModoDados _modoPadrao = ModoDados.local;

  static const String _apiUrlPadrao = 'http://10.29.112.213';

  static Future<void> salvarModoDados(ModoDados modo) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveModo, modo.name);
  }

  static Future<ModoDados> obterModoDados() async {
    final prefs = await SharedPreferences.getInstance();
    final valorSalvo = prefs.getString(_chaveModo);

    return ModoDados.values.firstWhere(
          (m) => m.name == valorSalvo,
      orElse: () => _modoPadrao,
    );
  }

  static Future<void> salvarApiUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_chaveApiUrl, url);
  }

  static Future<String> obterApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_chaveApiUrl) ?? _apiUrlPadrao;
  }
}