import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class EnvService {
  static String openAiKey = '';

  static Future<void> init() async {
    final raw = await rootBundle.loadString('assets/env.json');
    final map = jsonDecode(raw) as Map<String, dynamic>;
    openAiKey = (map['OPENAI_API_KEY'] ?? map['API_KEY'] ?? '').toString();
    if (openAiKey.isEmpty) {
      throw Exception('OPENAI_API_KEY no encontrado en assets/env.json');
    }
  }
}
