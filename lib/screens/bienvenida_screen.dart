import 'package:flutter/material.dart';

class BienvenidaScreen extends StatelessWidget {
  const BienvenidaScreen({super.key});

  static const Color _primaryBlue = Color(0xFF0D47A1); // Azul profundo
  static const Color _secondaryBlue = Color(0xFF1976D2); // Azul medio
  static const Color _accentRed = Color(0xFFD32F2F); // Rojo acento

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _primaryBlue,
              _secondaryBlue,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 30),

              // Personaje + título
              Column(
                children: [
                  // Personaje centrado
                  Image.asset(
                    'assets/cacho_bujia.png',
                    height: size.height * 0.35,
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    '¡Bienvenido a tu Mecánico Virtual!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                  width: 260, // ajustá el ancho para que rompa en 2
                  child: Text(
                    'Tu asistente con Inteligencia Artificial para cuidar tu auto',
                    maxLines: 3,
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis, // opcional si se pasa de 2
                    style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),

              // Botón de comenzar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _accentRed,
                      foregroundColor: Colors.white,
                      elevation: 4,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Comenzar',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
