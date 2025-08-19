import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/chispa_prefs.dart';
import 'panel_servicios_screen.dart'; // ✅ importa el panel
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ChispaScreen extends StatefulWidget {
  const ChispaScreen({super.key});

  @override
  State<ChispaScreen> createState() => _ChispaScreenState();
}

class _ChispaScreenState extends State<ChispaScreen> {
  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _secondaryBlue = Color(0xFF1976D2);
  static const Color _accentRed   = Color(0xFFD32F2F);

  bool _omitNext = false;
  late final String _uid;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Datos recibidos por arguments
  String marca = '';
  String modelo = '';
  String anio = '';
  String nombre = '';
  String apellido = '';

  @override
  void initState() {
    super.initState();
    _uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    _cargarPreferencia();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = (ModalRoute.of(context)?.settings.arguments ?? {}) as Map;
    marca   = (args['marca'] ?? '').toString();
    modelo  = (args['modelo'] ?? '').toString();
    anio    = (args['anio'] ?? '').toString();
    nombre  = (args['nombre'] ?? '').toString();
    apellido= (args['apellido'] ?? '').toString();
    if (mounted) setState(() {});
  }

  Future<void> _cargarPreferencia() async {
    final skip = await ChispaPrefs.getSkip(_uid);
    if (mounted) setState(() => _omitNext = skip);
  }

  Future<void> _continuar() async {
    await ChispaPrefs.setSkip(_uid, _omitNext);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const PanelServiciosScreen()),
    );
  }

  String _informeNarrado() {
    final usuario = (nombre.isNotEmpty) ? nombre : '¡Hola!';
    final titulo = (marca.isNotEmpty && modelo.isNotEmpty && anio.isNotEmpty)
        ? '$marca $modelo $anio'
        : 'tu vehículo';

    return
      '👋 $usuario. Soy Chispa CH-C1, el ayudante de Cacho Bujía en Mecánico Virtual. '
      'Te presento el informe inicial de $titulo.\n\n'
      '🔧 Mantenimiento sugerido:\n'
      '— Service cada 10.000 km o una vez al año (aceite, filtros, frenos).\n'
      '— Si tu auto supera los 5 años, revisá batería y suspensión.\n\n'
      '💪 Fortalezas:\n'
      '— Buen nivel de seguridad y confort en viajes.\n'
      '— Desempeño equilibrado para uso diario y ruta.\n\n'
      '⚠️ Debilidades:\n'
      '— Consumo algo elevado en ciudad según el estilo de manejo.\n'
      '— Costos de mantenimiento por encima de la media en algunos casos.\n\n'
      '🚨 Alertas comunes:\n'
      '— Controlar desgaste de frenos y niveles de aceite en viajes largos.\n\n'
      '✅ Próximos pasos:\n'
      '— Voy a recordarte mantenimientos y recomendaciones desde la app o por WhatsApp.\n';
  }

  Future<void> _reproducirVoz() async {
    final apiKey = dotenv.env['OPENAI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty) {
      debugPrint("No se encontró la API Key en .env");
      return;
    }

    final text = _informeNarrado();

    final url = Uri.parse("https://api.openai.com/v1/audio/speech");

    final response = await http.post(
      url,
      headers: {
        "Authorization": "Bearer $apiKey",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "model": "gpt-4o-mini-tts",
        "voice": "ballad", // 🎙️ voz tipo C3PO
        "input": text,
        "prompt": "Tiene que ser una voz para un robot tipo C3PO de Star Wars. Hablar en español de Argentina con tono jocoso, divertido."
      }),
    );

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      await _audioPlayer.play(BytesSource(Uint8List.fromList(bytes)));
    } else {
      debugPrint("Error en TTS: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _secondaryBlue,
      appBar: AppBar(
        backgroundColor: _primaryBlue,
        title: const Text(
          'Informe de tu auto',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (marca.isNotEmpty || modelo.isNotEmpty || anio.isNotEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.25)),
                  ),
                  child: Text(
                    '${marca.isNotEmpty ? marca : ''} '
                    '${modelo.isNotEmpty ? modelo : ''} '
                    '${anio.isNotEmpty ? anio : ''}'.trim(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              const SizedBox(height: 12),

              // ✅ Imagen de Chispa
              Center(
                child: Image.asset(
                  'assets/ch_c1.png',
                  height: 180,
                ),
              ),

              const SizedBox(height: 12),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    _informeNarrado(),
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 16,
                      height: 1.35,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Omitir esta pantalla la próxima vez',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.95),
                        fontSize: 15,
                      ),
                    ),
                  ),
                  Switch(
                    value: _omitNext,
                    onChanged: (v) => setState(() => _omitNext = v),
                    activeColor: _accentRed,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _continuar,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accentRed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Ir al panel',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    onPressed: _reproducirVoz,
                    icon: const Icon(Icons.volume_up, color: Colors.white, size: 32),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
