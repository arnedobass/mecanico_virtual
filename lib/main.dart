import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart'; // ✅ dotenv (una sola importación)

// Screens
import 'screens/bienvenida_screen.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/otp_screen.dart';
import 'screens/seleccion_auto_screen.dart';
import 'screens/presentacion_cacho_screen.dart';
import 'screens/chispa_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Cargar variables de entorno (si falta .env no rompe la app)
  try {
    await dotenv.load(fileName: ".env");
  } catch (_) {
    // Podés loguear si querés: debugPrint("⚠️ .env no encontrado, usando defaults");
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
