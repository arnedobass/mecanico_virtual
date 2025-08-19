import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../models/vehicle_selection.dart';
import '../models/user_profile.dart';

class LocalStore {
  // ====== Keys ======
  static const _kInstallId     = 'install_id';
  static const _kVehicle       = 'vehicle_selection';
  static const _kUserProfile   = 'user_profile';
  static const _kSkipIntro     = 'skip_intro';
  static const _kMuteVoice     = 'mute_voice';

  // Compat (si alguna vez guardaste nombre/apellido sueltos)
  static const _kFirstNameLegacy = 'first_name';
  static const _kLastNameLegacy  = 'last_name';

  // ====== Helpers ======
  static String _t(String? s) => s?.trim() ?? ''; // trim seguro
  static bool _hasText(String? s) => _t(s).isNotEmpty;

  // ====== Identidad de instalación ======
  static Future<String> getOrCreateInstallId() async {
    final sp = await SharedPreferences.getInstance();
    final existing = sp.getString(_kInstallId);
    if (_hasText(existing)) return existing!;
    final id = const Uuid().v4();
    await sp.setString(_kInstallId, id);
    return id;
  }

  // ====== VehicleSelection ======
  static Future<void> saveVehicle(VehicleSelection v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kVehicle, jsonEncode(v.toJson()));
  }

  static Future<VehicleSelection?> loadVehicle() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kVehicle);
    if (raw == null) return null;
    try {
      return VehicleSelection.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearVehicle() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kVehicle);
  }

  // ====== UserProfile ======
  static Future<void> saveUserProfile(UserProfile u) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_kUserProfile, jsonEncode(u.toJson()));

    // Mantener legacy (opcional)
    await sp.setString(_kFirstNameLegacy, _t(u.firstName));
    await sp.setString(_kLastNameLegacy,  _t(u.lastName));
  }

  static Future<UserProfile?> loadUserProfile() async {
    final sp = await SharedPreferences.getInstance();
    final raw = sp.getString(_kUserProfile);
    if (raw == null) {
      // Intentar armar desde legacy
      final legacyFirst = _t(sp.getString(_kFirstNameLegacy));
      final legacyLast  = _t(sp.getString(_kLastNameLegacy));
      if (legacyFirst.isNotEmpty || legacyLast.isNotEmpty) {
        final profile = UserProfile(firstName: legacyFirst, lastName: legacyLast);
        await saveUserProfile(profile);
        return profile;
      }
      return null;
    }
    try {
      return UserProfile.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  static Future<void> clearUserProfile() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kUserProfile);
    await sp.remove(_kFirstNameLegacy);
    await sp.remove(_kLastNameLegacy);
  }

  /// Nombre/apellido con null-safety
  static Future<String?> getFirstName() async {
    final u = await loadUserProfile();
    final fromProfile = _t(u?.firstName);
    if (fromProfile.isNotEmpty) return fromProfile;

    final sp = await SharedPreferences.getInstance();
    final legacy = _t(sp.getString(_kFirstNameLegacy));
    return legacy.isNotEmpty ? legacy : null;
  }

  static Future<String?> getLastName() async {
    final u = await loadUserProfile();
    final fromProfile = _t(u?.lastName);
    if (fromProfile.isNotEmpty) return fromProfile;

    final sp = await SharedPreferences.getInstance();
    final legacy = _t(sp.getString(_kLastNameLegacy));
    return legacy.isNotEmpty ? legacy : null;
  }

  /// ¿Perfil completo?
  static Future<bool> isProfileComplete() async {
    final n = _t(await getFirstName());
    final a = _t(await getLastName());
    return n.isNotEmpty && a.isNotEmpty;
  }

  // ====== Preferencias de presentación / audio ======
  static Future<bool> getSkipIntro() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kSkipIntro) ?? false;
  }

  static Future<void> setSkipIntro(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kSkipIntro, v);
  }

  static Future<bool> getMuteVoice() async {
    final sp = await SharedPreferences.getInstance();
    return sp.getBool(_kMuteVoice) ?? false;
  }

  static Future<void> setMuteVoice(bool v) async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_kMuteVoice, v);
  }

  // ====== Utilidad ======
  static Future<void> clearAll() async {
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_kInstallId);
    await sp.remove(_kVehicle);
    await sp.remove(_kUserProfile);
    await sp.remove(_kSkipIntro);
    await sp.remove(_kMuteVoice);
    await sp.remove(_kFirstNameLegacy);
    await sp.remove(_kLastNameLegacy);
  }
}
