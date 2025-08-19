import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';          // ⬅️ para obtener el uid del usuario
import '../services/car_api_service.dart';
import 'presentacion_cacho_screen.dart';                   // pantalla de “Chispa”
import '../utils/chispa_prefs.dart';                        // helper de preferencia “omitir”

class SeleccionAutoScreen extends StatefulWidget {
  const SeleccionAutoScreen({super.key});

  @override
  State<SeleccionAutoScreen> createState() => _SeleccionAutoScreenState();
}

class _SeleccionAutoScreenState extends State<SeleccionAutoScreen> {
  // Colores
  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _secondaryBlue = Color(0xFF1976D2);
  static const Color _accentRed   = Color(0xFFD32F2F);

  // Datos
  List<String> _marcas = [];
  List<String> _modelos = [];

  // Selecciones
  String? _marcaSeleccionada;
  String? _modeloSeleccionado;

  // Año (deslizable)
  late final int _anioMin;
  late final int _anioMax;
  int? _anioSeleccionado;

  // Cargando
  bool _cargandoMarcas = true;
  bool _cargandoModelos = false;

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    _anioMin = 1980;
    _anioMax = currentYear + 1;
    _anioSeleccionado = currentYear;
    _cargarMarcas();
  }

  Future<void> _cargarMarcas() async {
    try {
      final marcas = await CarApiService.obtenerMarcas();
      if (!mounted) return;
      setState(() {
        _marcas = marcas;
        _cargandoMarcas = false;
      });
    } catch (e) {
      debugPrint('Error al obtener marcas: $e');
      if (!mounted) return;
      setState(() => _cargandoMarcas = false);
      _showSnack('Error cargando marcas');
    }
  }

  Future<void> _cargarModelos(String marca) async {
    setState(() {
      _cargandoModelos = true;
      _modelos = [];
      _modeloSeleccionado = null;
    });

    try {
      final modelos = await CarApiService.obtenerModelos(marca);
      if (!mounted) return;
      setState(() => _modelos = modelos);
    } catch (e) {
      debugPrint('Error al obtener modelos: $e');
      if (!mounted) return;
      _showSnack('Error cargando modelos');
    } finally {
      if (!mounted) return;
      setState(() => _cargandoModelos = false);
    }
  }

  Future<void> _confirmar() async {
    if (_marcaSeleccionada == null || _modeloSeleccionado == null || _anioSeleccionado == null) {
      _showSnack('Completá marca, modelo y año');
      return;
    }

    // (Opcional) acá podrías guardar el vehículo en tu backend/Firestore
    // await guardarVehiculo(_marcaSeleccionada!, _modeloSeleccionado!, _anioSeleccionado!);

    // Chequear preferencia “omitir la próxima vez” por usuario
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'anon';
    final skip = await ChispaPrefs.getSkip(uid);

    if (!mounted) return;

    if (skip) {
      // Saltea pantalla de Chispa y va directo al panel
      Navigator.pushNamedAndRemoveUntil(context, '/home', (_) => false);
    } else {
      // Va a tu pantalla de presentación/Chispa (la que ya tenías)
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => const PresentacionCachoScreen(),
          settings: RouteSettings(arguments: {
            'brand': _marcaSeleccionada!,
            'model': _modeloSeleccionado!,
            'year': _anioSeleccionado!,
          }),
        ),
      );
    }
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  bool get _listoParaConfirmar =>
      _marcaSeleccionada != null && _modeloSeleccionado != null && _anioSeleccionado != null;

  InputDecoration _decInput(String label) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.9)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withOpacity(0.25)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.white, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      );

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size  = media.size;

    return Scaffold(
      extendBody: true,
      backgroundColor: _secondaryBlue, // fallback
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_primaryBlue, _secondaryBlue],
                ),
              ),
            ),
          ),
          SafeArea(
            child: _cargandoMarcas
                ? const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : CustomScrollView(
                    physics: const ClampingScrollPhysics(),
                    slivers: [
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/cacho_bujia.png',
                                height: size.height * 0.22,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(height: 10),

                              const Text(
                                'Seleccioná tu auto',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 14),

                              // Marca
                              DropdownButtonFormField<String>(
                                value: _marcaSeleccionada,
                                isExpanded: true,
                                decoration: _decInput('Marca'),
                                dropdownColor: _primaryBlue,
                                style: const TextStyle(color: Colors.white),
                                iconEnabledColor: Colors.white,
                                hint: const Text('Elegí una marca', style: TextStyle(color: Colors.white70)),
                                items: _marcas
                                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                                    .toList(),
                                onChanged: (valor) {
                                  if (valor == null) return;
                                  setState(() => _marcaSeleccionada = valor);
                                  _cargarModelos(valor);
                                },
                              ),

                              const SizedBox(height: 14),

                              // Modelo
                              _cargandoModelos
                                  ? const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 8.0),
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : DropdownButtonFormField<String>(
                                      value: _modeloSeleccionado,
                                      isExpanded: true,
                                      decoration: _decInput('Modelo'),
                                      dropdownColor: _primaryBlue,
                                      style: const TextStyle(color: Colors.white),
                                      iconEnabledColor: Colors.white,
                                      hint: const Text('Elegí un modelo', style: TextStyle(color: Colors.white70)),
                                      items: _modelos
                                          .map((mo) => DropdownMenuItem(value: mo, child: Text(mo)))
                                          .toList(),
                                      onChanged: (valor) => setState(() => _modeloSeleccionado = valor),
                                    ),

                              const SizedBox(height: 18),

                              // Año (Slider)
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'Año: ${_anioSeleccionado ?? ''}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  thumbColor: _accentRed,
                                  activeTrackColor: Colors.white,
                                  inactiveTrackColor: Colors.white70,
                                  overlayColor: Colors.white24,
                                  valueIndicatorColor: _accentRed,
                                  valueIndicatorTextStyle: const TextStyle(color: Colors.white),
                                ),
                                child: Slider(
                                  min: _anioMin.toDouble(),
                                  max: _anioMax.toDouble(),
                                  divisions: (_anioMax - _anioMin),
                                  label: '${_anioSeleccionado ?? ''}',
                                  value: (_anioSeleccionado ?? _anioMin).toDouble(),
                                  onChanged: (v) => setState(() => _anioSeleccionado = v.round()),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('$_anioMin', style: const TextStyle(color: Colors.white70)),
                                  Text('$_anioMax', style: const TextStyle(color: Colors.white70)),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Confirmar
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _listoParaConfirmar ? _confirmar : null,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accentRed,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: const Text(
                                    'Confirmar',
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                                  ),
                                ),
                              ),

                              const Spacer(),
                            ],
                          ),
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
