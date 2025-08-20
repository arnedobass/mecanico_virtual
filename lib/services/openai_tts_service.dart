import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'env_service.dart';

/// Genera una reseña corta y la convierte a audio (voz "ballad").
class OpenAiTtsService {
  final String _apiKey = EnvService.openAiKey; // cargada en main con EnvService.init()
  final String _modelText = 'gpt-4o-mini';
  final String _modelTts  = 'gpt-4o-mini-tts';
  final AudioPlayer _player = AudioPlayer();

  Future<String> _postJson(Uri uri, Map<String, dynamic> body) async {
    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );
    if (res.statusCode != 200) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('HTTP ${res.statusCode} ${uri.path} => ${res.body}');
      }
      throw Exception('OpenAI error ${res.statusCode}');
    }
    return res.body;
  }

  Future<String> _buildResumen({
    required String marca,
    required String modelo,
    required String anio,
    required String nombre,
  }) async {
    final prompt = '''
Genera una reseña MUY breve (80–120 palabras) en español de Argentina para $nombre sobre su $marca $modelo $anio.
Incluye 2–3 fortalezas generales y 1–2 debilidades típicas, sin ofender (tono amable). Habla en segunda persona ("tu auto").
Evita datos hiper específicos que no sean universales del modelo.
''';

    final uri = Uri.parse('https://api.openai.com/v1/chat/completions');
    final body = {
      'model': _modelText,
      'messages': [
        {
          'role': 'system',
          'content': 'Eres un asesor automotriz breve y claro. Responde en español de Argentina.'
        },
        {'role': 'user', 'content': prompt},
      ],
      'temperature': 0.7,
      'max_tokens': 220,
    };

    final raw = await _postJson(uri, body);
    final data = jsonDecode(raw) as Map<String, dynamic>;
    final content = (data['choices']?[0]?['message']?['content'] ?? '').toString().trim();
    if (content.isEmpty) throw Exception('Respuesta de texto vacía');
    return content;
  }

  Future<File> _synthesize(String texto) async {
    final uri = Uri.parse('https://api.openai.com/v1/audio/speech');

    final input = '''
[Personaje: CHISPA CH-C1 · robot tipo C3PO]
[Idioma: español de Argentina · Tono: jocoso y educado · Ritmo: ágil, pausas cortas]
$texto
''';

    final body = {
      'model': _modelTts,
      'voice': 'ballad',
      'input': input,
      'format': 'mp3',
    };

    final res = await http.post(
      uri,
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(body),
    );

    if (res.statusCode != 200) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('HTTP ${res.statusCode} ${uri.path} => ${res.body}');
      }
      throw Exception('OpenAI TTS error ${res.statusCode}');
    }

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/chispa_tts.mp3');
    await file.writeAsBytes(res.bodyBytes, flush: true);
    return file;
  }

  Future<void> speakResumenAuto({
    required String marca,
    required String modelo,
    required String anio,
    required String nombre,
  }) async {
    if (_apiKey.isEmpty) {
      throw Exception('Falta OPENAI_API_KEY (EnvService.openAiKey vacío)');
    }
    final texto = await _buildResumen(marca: marca, modelo: modelo, anio: anio, nombre: nombre);
    final mp3 = await _synthesize(texto);
    await _player.setFilePath(mp3.path);
    await _player.play();
  }

  Future<void> stop() async => _player.stop();
  void dispose() => _player.dispose();
}
