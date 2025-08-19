// lib/services/google_tts_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart' show kIsWeb, ValueNotifier;

class GoogleTtsService {
  static const String _endpoint = 'https://georosario.com/tts.php';
  static final AudioPlayer _player = AudioPlayer();

  // Observable: true mientras está reproduciendo TTS
  static final ValueNotifier<bool> speaking = ValueNotifier<bool>(false);

  /// Reproduce texto/SSML usando tu backend PHP.
  static Future<void> speak(
    String text, {
    String voiceName = 'es-US-Neural2-D',
    String languageCode = 'es-US',
    double speakingRate = 1.1,
    double pitch = -4.0,
    bool useSsml = false,
  }) async {
    await _player.stop();
    speaking.value = false; // reset

    final payload = useSsml
        ? {'ssml': text, 'voice': voiceName, 'lang': languageCode, 'rate': speakingRate, 'pitch': pitch}
        : {'text': text, 'voice': voiceName, 'lang': languageCode, 'rate': speakingRate, 'pitch': pitch};

    final r = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (r.statusCode != 200) {
      speaking.value = false;
      throw Exception('TTS error ${r.statusCode}: ${r.body}');
    }

    speaking.value = true;

    // Apagar automáticamente cuando termina / se detiene
    _player.onPlayerComplete.first.then((_) => speaking.value = false);
    _player.onPlayerStateChanged.listen((s) {
      if (s == PlayerState.completed || s == PlayerState.stopped || s == PlayerState.paused) {
        speaking.value = false;
      }
    });

    if (kIsWeb) {
      final b64 = base64Encode(r.bodyBytes);
      final url = 'data:audio/mpeg;base64,$b64';
      await _player.play(UrlSource(url));
    } else {
      await _player.play(BytesSource(r.bodyBytes));
    }
  }

  static Future<void> stop() async {
    speaking.value = false;
    await _player.stop();
  }
}
