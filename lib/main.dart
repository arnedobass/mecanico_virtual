import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// Screens
import 'screens/bienvenida_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/seleccion_auto_screen.dart';
import 'screens/presentacion_cacho_screen.dart';
import 'screens/chispa_screen.dart';

// ✅ Carga de API key desde assets/env.json (sin dotenv)
import 'services/env_service.dart';

String _mask(String s) {
  if (s.isEmpty) return '(vacía)';
  final start = s.length >= 6 ? s.substring(0, 6) : s;
  final end   = s.length >= 4 ? s.substring(s.length - 4) : '';
  return '$start...$end';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Inicializa la clave desde assets/env.json
  try {
    await EnvService.init();
    // Debug opcional: mostrar parcialmente la key
    // (no publiques esto en builds públicos)
    // ignore: avoid_print
    print('OPENAI_KEY => ${_mask(EnvService.openAiKey)}');
  } catch (e) {
    // ignore: avoid_print
    print('⚠️ No se pudo cargar assets/env.json: $e');
  }

  // ✅ Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MecanicoVirtualApp());
}

class MecanicoVirtualApp extends StatelessWidget {
  const MecanicoVirtualApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mecánico Virtual',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
      ),
      initialRoute: '/', // o '/login' si querés saltar la bienvenida
      routes: {
        '/':                   (context) => const BienvenidaScreen(),
        '/login':              (context) => const LoginScreen(),
        '/home':               (context) => const HomeScreen(),
        '/otp':                (context) => const OtpScreen(),
        '/seleccion_auto':     (context) => const SeleccionAutoScreen(),
        '/presentacion-cacho': (context) => const PresentacionCachoScreen(),
        '/chispa':             (context) => const ChispaScreen(),
      },
    );
  }
}
