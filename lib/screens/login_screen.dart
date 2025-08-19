import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  static const Color _primaryBlue = Color(0xFF0D47A1);
  static const Color _secondaryBlue = Color(0xFF1976D2);
  static const Color _accentRed   = Color(0xFFD32F2F);

  PhoneNumber? _phone; // valor internacional (código país + número)
  bool _isSending = false;
  int? _resendToken;
  String _initialIso = 'AR'; // se setea por Locale en build()

  String _hintForCountry(String? iso) {
    if ((iso ?? '').toUpperCase() == 'AR') {
      return 'Escribí sin 0 ni 15 — Ej: 11 1234 5678';
    }
    return 'Escribí tu número local sin separadores';
  }

  /// Normaliza a E.164 para Firebase. En AR fuerza +549 y elimina 0/15 si aparecen.
  String _e164ForFirebase(PhoneNumber p) {
    // ej: "+54 341 612 3456" → sin espacios
    String tel = p.completeNumber.replaceAll(RegExp(r'\s+'), '');

    final iso = (p.countryISOCode ?? '').toUpperCase();
    if (iso == 'AR') {
      // El paquete suele traer ya sin 0/15, pero reforzamos:
      // 1) Garantizar +549 (móviles)
      if (tel.startsWith('+54') && !tel.startsWith('+549')) {
        tel = tel.replaceFirst('+54', '+549');
      }
      // 2) Remover "0" nacional inmediatamente después de +549 (si apareciera)
      tel = tel.replaceFirst('+5490', '+549');
      // 3) Remover "15" (por si el usuario lo tipeó dentro del número)
      tel = tel.replaceFirst(RegExp(r'^\+549(15)'), '+549');
    }
    return tel;
  }

  Future<void> _enviarCodigo() async {
    if (!_formKey.currentState!.validate() || _phone == null) return;

    final tel = _e164ForFirebase(_phone!); // formato final para Firebase
    setState(() => _isSending = true);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Enviando código a $tel')),
    );

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: tel,
        timeout: const Duration(seconds: 60),
        forceResendingToken: _resendToken,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance.signInWithCredential(credential);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('✅ Verificado automáticamente')),
            );
            Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('❌ Error: $e')),
            );
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ ${e.message ?? e.code}')),
          );
        },
        codeSent: (String verificationId, int? resendToken) {
          _resendToken = resendToken;
          if (!mounted) return;
          Navigator.pushNamed(
            context,
            '/otp',
            arguments: {
              'verificationId': verificationId,
              'telefono': tel,
              'resendToken': resendToken,
            },
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Detectar país inicial por Locale del dispositivo (fallback AR)
    _initialIso = (Localizations.localeOf(context).countryCode ?? 'AR').toUpperCase();

    final media = MediaQuery.of(context);
    final size  = media.size;

    return Scaffold(
      extendBody: true,
      backgroundColor: _secondaryBlue,
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
            child: CustomScrollView(
              physics: const ClampingScrollPhysics(),
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Personaje
                        Image.asset(
                          'assets/cacho_bujia_pulgar_arriba.png',
                          height: size.height * 0.28,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          'Ingresá tu número de teléfono',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Subtítulo dinámico según país seleccionado
                        Text(
                          _hintForCountry(_phone?.countryISOCode ?? _initialIso),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // === FORM ===
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Campo de teléfono internacional
                              DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.30),
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                  child: IntlPhoneField(
                                    initialCountryCode: _initialIso, // auto por Locale
                                    // IMPORTANTE: desactivar chequeo de largo del paquete
                                    // para evitar invalidaciones como "12 dígitos"
                                    disableLengthCheck: true,
                                    showDropdownIcon: true,
                                    dropdownIconPosition: IconPosition.trailing,
                                    dropdownTextStyle: const TextStyle(color: Colors.white),
                                    style: const TextStyle(color: Colors.white),
                                    decoration: InputDecoration(
                                      hintText: _initialIso == 'AR'
                                          ? 'Ej: 11 1234 5678'
                                          : 'Número local',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.60),
                                      ),
                                      border: InputBorder.none,
                                    ),
                                    flagsButtonPadding: const EdgeInsets.only(left: 8),
                                    onChanged: (phone) {
                                      setState(() {
                                        _phone = phone; // actualiza hint dinámico
                                      });
                                    },
                                    onCountryChanged: (country) {
                                      // reseteamos hint al cambiar de país
                                      setState(() {
                                        // si ya hay número escrito, igual dejamos que Firebase valide
                                      });
                                    },
                                    // Validador laxo: solo vacío → error. Chequeo real lo hace Firebase.
                                    validator: (phone) {
                                      if (phone == null || phone.number.trim().isEmpty) {
                                        return 'Ingresá tu número';
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 30),

                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _isSending ? null : _enviarCodigo,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _accentRed,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Text(
                                    _isSending ? 'Enviando...' : 'Enviar código',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),
                        SizedBox(height: media.padding.bottom + 12),
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
