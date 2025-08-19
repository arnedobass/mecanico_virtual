import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../services/local_store.dart';
import '../models/vehicle_selection.dart';
import '../services/google_tts_service.dart';
import 'user_data_step_page.dart';
import '../widgets/animated_cacho.dart';

class PresentacionCachoScreen extends StatefulWidget {
  const PresentacionCachoScreen({super.key});

  @override
  State<PresentacionCachoScreen> createState() => _PresentacionCachoScreenState();
}

class _PresentacionCachoScreenState extends State<PresentacionCachoScreen> {
  // Paleta
  static const Color _primaryBlue   = Color(0xFF0D47A1);
  static const Color _secondaryBlue = Color(0xFF1976D2);
  static const Color _accentRed     = Color(0xFFD32F2F);

  bool _muted = false;
  bool _skipNextTime = false;
  VehicleSelection? _vehiculo;

  bool _argsAplicados = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: _secondaryBlue,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
    _ensureProfileThenLoad();
  }

  Future<void> _ensureProfileThenLoad() async {
    final completo = await LocalStore.isProfileComplete();
    if (!mounted) return;

    if (!completo) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const UserDataStepPage()),
        );
      });
      return;
    }

    await _cargarPrefsYVehiculo();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsAplicados) return;

    final route = ModalRoute.of(context);
    final args = route != null ? route.settings.arguments : null;
    if (args is Map) {
      final b = args['brand'];
      final m = args['model'];
      final y = args['year'];
      final int? parsedYear = (y is int) ? y : int.tryParse((y ?? '').toString());
      if (b != null && m != null && parsedYear != null) {
        setState(() {
          _vehiculo = VehicleSelection(
            brand: b.toString(),
            model: m.toString(),
            year: parsedYear,
          );
        });
      }
    }
    _argsAplicados = true;
  }

  Future<void> _cargarPrefsYVehiculo() async {
    final muted = await LocalStore.getMuteVoice();
    final skip  = await LocalStore.getSkipIntro();
    final veh   = await LocalStore.loadVehicle();

    if (!mounted) return;
    setState(() {
      _muted = muted;
      _skipNextTime = skip;
      _vehiculo ??= veh;
    });

    if (!_muted) {
      unawaited(_speakIntro());
    }
  }

  Future<void> _speakIntro() async {
    await GoogleTtsService.speak(
      _introTexto(),
      languageCode: 'es-US',
      voiceName: 'es-US-Neural2-D',
      speakingRate: 1.1,
      pitch: -4.0,
    );
  }

  Future<void> _toggleMute() async {
    final newVal = !_muted;
    setState(() => _muted = newVal);
    await LocalStore.setMuteVoice(newVal);
    if (newVal) {
      await GoogleTtsService.stop();
    } else {
      await _speakIntro();
    }
  }

  Future<void> _onSkipChanged(bool v) async {
    setState(() => _skipNextTime = v);
    await LocalStore.setSkipIntro(v);
  }

  @override
  void dispose() {
    GoogleTtsService.stop();
    super.dispose();
  }

  void _continuar() async {
    final completo = await LocalStore.isProfileComplete();
    if (!mounted) return;

    if (!completo) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UserDataStepPage()),
      );
    } else {
      Navigator.of(context).pushReplacementNamed(
        '/chispa',
        arguments: {
          'marca': _vehiculo?.brand,
          'modelo': _vehiculo?.model,
          'anio': _vehiculo?.year,
          'brand': _vehiculo?.brand,
          'model': _vehiculo?.model,
          'year': _vehiculo?.year,
        },
      );
    }
  }

  String _introTexto() {
    final b = _vehiculo?.brand;
    final m = _vehiculo?.model;
    final y = _vehiculo?.year;
    final tituloVehiculo = (b != null && m != null && y != null) ? '$b $m $y' : 'tu vehículo';
    return
        'Hola. Soy Cacho Bujía, tu mecánico virtual de confianza. '
        'Estoy acá para ayudarte a cuidar $tituloVehiculo con información clara y útil. '
        'Conmigo vas a poder hacer escaneos y monitoreos en tiempo real, '
        'recibir recordatorios para el cambio de aceite, la verificación técnica y otros mantenimientos importantes. '
        'Si detecto algún problema, te lo voy a explicar de forma sencilla y te voy a guiar para resolverlo. '
        'También vas a poder guardar el historial de tu vehículo y recibir alertas preventivas. '
        'Si estás lista o listo, empecemos.';
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size  = media.size;

    return Scaffold(
      extendBodyBehindAppBar: true,
      extendBody: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Cacho Bujía'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: _muted ? 'Activar voz' : 'Silenciar',
            icon: Icon(_muted ? Icons.volume_off : Icons.volume_up),
            onPressed: _toggleMute,
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                  colors: [_primaryBlue, _secondaryBlue],
                ),
              ),
            ),
          ),
          SafeArea(
            top: true,
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: constraints.maxHeight),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ValueListenableBuilder<bool>(
                            valueListenable: GoogleTtsService.speaking,
                            builder: (_, isSpeaking, __) {
                              return AnimatedCacho(
                                asset: 'assets/cacho_bujia.png',
                                height: size.height * 0.25,
                                speaking: isSpeaking,
                              );
                            },
                          ),
                          const SizedBox(height: 8),
                          if (_vehiculo != null) ...[
                            Text(
                              '${_vehiculo?.brand ?? ''} • ${_vehiculo?.model ?? ''} • ${_vehiculo?.year ?? ''}',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.95),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          const SizedBox(height: 16),
                          const _FeatureWrap(),
                          const SizedBox(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Checkbox(
                                value: _skipNextTime,
                                onChanged: (v) => _onSkipChanged(v ?? false),
                                checkColor: Colors.white,
                                activeColor: _accentRed,
                              ),
                              const Text(
                                'Omitir presentación la próxima vez',
                                style: TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          SizedBox(
                            width: double.infinity,
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
                                'Comenzar',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureWrap extends StatelessWidget {
  const _FeatureWrap();

  @override
  Widget build(BuildContext context) {
    const gap = 12.0;
    final totalWidth = MediaQuery.of(context).size.width - 40;
    final itemW = (totalWidth - gap) / 2;

    const items = [
      (Icons.speed, 'Monitoreo', 'Datos en tiempo real'),
      (Icons.event_note, 'Recordatorios', 'Mantenimientos clave'),
      (Icons.history, 'Historial', 'Servicios y gastos'),
      (Icons.warning_amber_rounded, 'Alertas', 'Prevención temprana'),
    ];

    return Wrap(
      spacing: gap,
      runSpacing: gap,
      children: items.map((it) {
        return SizedBox(
          width: itemW,
          child: _FeatureCard(icon: it.$1, title: it.$2, subtitle: it.$3),
        );
      }).toList(),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.28)),
      ),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.22),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.35)),
            ),
            child: Center(child: Icon(icon, color: Colors.white)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(subtitle,
                  maxLines: 2, overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.95),
                    fontSize: 12, height: 1.15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
