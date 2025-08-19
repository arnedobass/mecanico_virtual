import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart' show rootBundle;

class CarApiService {
  // Tu JSON público: {"Marca": ["Modelo1","Modelo2",...], ...}
  static const String _remoteUrl = 'https://georosario.com/marcas_modelos.json?v=20250808';

  // Asset opcional para primer arranque sin red (si lo declaraste en pubspec)
  static const String _assetPath = 'assets/marcas_modelos.json';

  // Clave de caché (SharedPreferences)
  static const String _prefsKeyData = 'car_mm_cache_v2';

  static Map<String, List<String>>? _mem;
  static Future<void>? _loading;

  // ===== API pública =====

  /// Devuelve las marcas ordenadas (carga/caché si hace falta)
  static Future<List<String>> obtenerMarcas() async {
    await _ensureLoaded();
    final marcas = _mem!.keys.toList()..sort();
    return marcas;
  }

  /// Devuelve los modelos de una marca, ordenados
  static Future<List<String>> obtenerModelos(String marca) async {
    await _ensureLoaded();
    final modelos = _mem![marca.trim()] ?? const [];
    return List<String>.from(modelos)..sort();
  }

  // ===== Interno =====

  static Future<void> _ensureLoaded() async {
    if (_mem != null) return;
    if (_loading != null) {
      await _loading;
      return;
    }
    _loading = _loadFromPrefsThenAssetThenNetwork();
    await _loading;
    _loading = null;
  }

  /// Orden de carga:
  /// 1) SharedPreferences (si hay)
  /// 2) Asset local (si existe)
  /// 3) Red (en segundo plano)
  static Future<void> _loadFromPrefsThenAssetThenNetwork() async {
    final prefs = await SharedPreferences.getInstance();

    // 1) Intentar caché persistida
    final cached = prefs.getString(_prefsKeyData);
    if (cached != null) {
      try {
        _mem = _parse(cached);
      } catch (_) {
        _mem = null; // si falla, seguimos
      }
    }

    // 2) Seed desde asset si aún no tenemos nada
    if (_mem == null) {
      try {
        final txt = await rootBundle.loadString(_assetPath);
        final parsed = _parse(txt);
        _mem = parsed;
        await prefs.setString(_prefsKeyData, jsonEncode(_mem));
      } catch (_) {
        // si no hay asset o falla, seguimos
      }
    }

    // Garantizar mapa aunque esté vacío para no romper la UI
    _mem ??= <String, List<String>>{};

    // 3) Refresco en segundo plano desde la web (no bloquea la pantalla)
    _refreshFromNetwork();
  }

  static Future<void> _refreshFromNetwork() async {
    try {
      final res = await http
          .get(Uri.parse(_remoteUrl))
          .timeout(const Duration(seconds: 6));
      if (res.statusCode == 200 && res.body.isNotEmpty) {
        final txt = utf8.decode(res.bodyBytes); // asegura UTF-8 correcto
        final fresh = _parse(txt);

        // Actualizar memoria y caché
        _mem = fresh;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKeyData, jsonEncode(_mem));
      }
    } catch (_) {
      // Silencioso: si falla red/CORS/timeout, seguimos con lo que haya
    }
  }

  static Map<String, List<String>> _parse(String txt) {
    final raw = json.decode(txt) as Map<String, dynamic>;
    final out = <String, List<String>>{};
    for (final e in raw.entries) {
      final marca = _clean(e.key);
      final modelos = (e.value as List)
          .map((x) => _clean(x))
          .where((x) => x.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (marca.isNotEmpty && modelos.isNotEmpty) {
        out[marca] = modelos;
      }
    }
    return out;
  }

  static String _clean(Object? s) =>
      (s?.toString() ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
}

