import 'package:flutter/material.dart';
import '../services/local_store.dart';
import '../models/user_profile.dart';
import 'presentacion_cacho_screen.dart';
import 'panel_servicios_screen.dart';

class UserDataStepPage extends StatefulWidget {
  const UserDataStepPage({super.key});

  @override
  State<UserDataStepPage> createState() => _UserDataStepPageState();
}

class _UserDataStepPageState extends State<UserDataStepPage> {
  // Paleta para mantener coherencia visual
  static const Color _primaryBlue   = Color(0xFF0D47A1);
  static const Color _secondaryBlue = Color(0xFF1976D2);
  static const Color _accentRed     = Color(0xFFD32F2F);

  final _formKey   = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl  = TextEditingController();
  final _firstFocus = FocusNode();
  final _lastFocus  = FocusNode();

  bool _saving = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final profile = UserProfile(
      firstName: _firstCtrl.text.trim(),
      lastName:  _lastCtrl.text.trim(),
    );
    await LocalStore.saveUserProfile(profile);

    if (!mounted) return;

    final skipIntro = await LocalStore.getSkipIntro();

    // Navegar respetando la preferencia de “omitir intro”
    if (skipIntro) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PanelServiciosScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const PresentacionCachoScreen()),
      );
    }
  }

  InputDecoration _inputDeco({
    required String label,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.white),
      labelStyle: const TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.white.withOpacity(0.9)), // <-- TextStyle (fix)
      filled: true,
      fillColor: Colors.white.withOpacity(0.14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.white.withOpacity(0.26)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: _accentRed, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Colors.redAccent, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final size  = media.size;

    return Scaffold(
      extendBody: true,
      backgroundColor: _secondaryBlue,
      appBar: AppBar(
        title: const Text('Tus Datos'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Fondo con gradiente
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                children: [
                  // Personaje / header visual (opcional)
                  Image.asset(
                    'assets/cacho_bujia.png',
                    height: size.height * 0.22,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Antes de empezar…',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.98),
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Decime tu nombre y apellido para personalizar la experiencia.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.95),
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Tarjeta translúcida con el formulario
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.25)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: _firstCtrl,
                            focusNode: _firstFocus,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco(
                              label: 'Nombre',
                              icon: Icons.person_outline,
                            ),
                            validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                ? 'Ingresá tu nombre'
                                : null,
                            onFieldSubmitted: (_) => _lastFocus.requestFocus(),
                          ),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _lastCtrl,
                            focusNode: _lastFocus,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(color: Colors.white),
                            decoration: _inputDeco(
                              label: 'Apellido',
                              icon: Icons.badge_outlined,
                            ),
                            validator: (v) =>
                              (v == null || v.trim().isEmpty)
                                ? 'Ingresá tu apellido'
                                : null,
                            onFieldSubmitted: (_) => _save(),
                          ),

                          const SizedBox(height: 16),

                          // Botón rojo principal
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _saving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _accentRed,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Guardar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: media.padding.bottom + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
