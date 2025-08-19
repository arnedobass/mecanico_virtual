import 'package:shared_preferences/shared_preferences.dart';

class ChispaPrefs {
  // armamos la clave con el uid del usuario
  static String _key(String uid) => 'skip_chispa_$uid';

  /// Obtener preferencia (true = omitir Chispa)
  static Future<bool> getSkip(String uid) async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_key(uid)) ?? false;
  }

  /// Guardar preferencia
  static Future<void> setSkip(String uid, bool value) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_key(uid), value);
  }
}
