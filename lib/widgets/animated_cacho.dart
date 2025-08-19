import 'package:flutter/material.dart';

class AnimatedCacho extends StatefulWidget {
  final String asset;
  final double height;
  final bool speaking; // amplifica la animación cuando habla

  const AnimatedCacho({
    super.key,
    required this.asset,
    required this.height,
    this.speaking = false,
  });

  @override
  State<AnimatedCacho> createState() => _AnimatedCachoState();
}

class _AnimatedCachoState extends State<AnimatedCacho>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac;
  late final Animation<double> _bob;    // sube/baja
  late final Animation<double> _tilt;   // leve inclinación
  late final Animation<double> _breath; // micro respiración

  @override
  void initState() {
    super.initState();
    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat(reverse: true);

    final curve = CurvedAnimation(parent: _ac, curve: Curves.easeInOutSine);
    _bob    = Tween<double>(begin: -6, end: 6).animate(curve);
    _tilt   = Tween<double>(begin: -0.025, end: 0.025).animate(curve); // ~±1.4°
    _breath = Tween<double>(begin: 0.995, end: 1.005).animate(curve);  // micro-scale
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) {
        final amp   = widget.speaking ? 1.6 : 1.0;
        final dy    = _bob.value * amp;
        final angle = _tilt.value * (amp * 0.9);
        final baseScale = _breath.value;
        final scale = 1 + (baseScale - 1) * amp;

        final shadowScale = (1.0 + (-dy / 30)).clamp(0.9, 1.1);
        final shadowAlpha = (0.25 + (-dy / 40)).clamp(0.15, 0.35);

        return SizedBox(
          height: widget.height + 20,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Positioned(
                bottom: 4,
                child: Transform.scale(
                  scale: shadowScale,
                  child: Container(
                    width: widget.height * 0.55,
                    height: widget.height * 0.12,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(shadowAlpha),
                      borderRadius: BorderRadius.circular(widget.height),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 24,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Transform.translate(
                offset: Offset(0, dy),
                child: Transform.rotate(
                  angle: angle,
                  child: Transform.scale(
                    scale: scale,
                    child: Image.asset(
                      widget.asset,
                      height: widget.height,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
