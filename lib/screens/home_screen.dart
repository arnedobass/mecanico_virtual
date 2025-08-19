import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const Color _primaryBlue = Color(0xFF0D47A1); // azul profundo
  static const Color _secondaryBlue = Color(0xFF1976D2); // azul medio
  static const Color _accentRed = Color(0xFFD32F2F); // rojo acento

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Mecánico Virtual'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // Fondo con gradiente azul
          Container(
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
          ),

          // Contenido
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // Personaje (PNG con transparencia)
                  Expanded(
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: LayoutBuilder(
                        builder: (_, constraints) {
                          // Tamaño adaptable según alto disponible
                          final double imgHeight = 
                              (constraints.maxHeight * 0.72).clamp(220.0, 420.0).toDouble(); // <- cast

                          return Stack(
                            alignment: Alignment.center,
                            children: [
                              // Halo suave detrás del personaje
                              Container(
                                width: imgHeight * 0.85,
                                height: imgHeight * 0.85,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      _accentRed.withOpacity(0.16),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              ),
                              // Imagen
                              Image.asset(
                                'assets/cacho_bujia.png',
                                height: imgHeight,
                                fit: BoxFit.contain,
                                filterQuality: FilterQuality.high,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Título + subtítulo
                  const Text(
                    '¡Hola! Soy Cacho Bujía',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Te ayudo a registrar tu auto y darte tips de mantenimiento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 22),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/seleccion_auto');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accentRed,
                            foregroundColor: Colors.white,
                            elevation: 2,
                            padding: const EdgeInsets.symmetric(
                              vertical: 14, horizontal: 18),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text(
                            'Cargar datos de mi auto',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // Botón secundario
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/presentacion');
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Ver cómo funciona',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
