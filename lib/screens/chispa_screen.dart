import 'package:flutter/material.dart';
import '../services/local_store.dart';
import '../services/openai_tts_service.dart';
import '../models/vehicle_selection.dart';

class ChispaScreen extends StatefulWidget {
  const ChispaScreen({super.key});

  @override
  State<ChispaScreen> createState() => _ChispaScreenState();
}

class _ChispaScreenState extends State<ChispaScreen> {
  // Estado
  late final OpenAiTtsService _voice;
  bool _loading = false;

  VehicleSelection? _veh;
  String _saludoNombre = 'conductor';

  @override
  void initState() {
    super.initState();
    _voice = OpenAiTtsService();
    _loadData();
  }

  Future<void> _loadData() async {
    final v = await LocalStore.loadVehicle();
    final first = await LocalStore.getFirstName();
    final last  = await LocalStore.getLastName();

    final nombre = [
      if ((first ?? '').trim().isNotEmpty) first!.trim(),
      if ((last  ?? '').trim().isNotEmpty)  last!.trim(),
    ].join(' ').trim();

    setState(() {
      _veh = v;
      _saludoNombre = nombre.isNotEmpty ? nombre : 'conductor';
    });
  }

  @override
  void dispose() {
    _voice.dispose();
    super.dispose();
  }

  Future<void> _speak() async {
    setState(() => _loading = true);
    try {
      final marca  = (_veh?.brand ?? 'Chevrolet').trim();
      final modelo = (_veh?.model ?? 'Equinox').trim();
      final anio   = (_veh?.year?.toString() ?? '2019').trim();

      await _voice.speakResumenAuto(
        marca: marca,
        modelo: modelo,
        anio: anio,
        nombre: _saludoNombre,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de voz: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _clearData() async {
    await LocalStore.clearVehicle();
    await LocalStore.clearUserProfile();
    await _loadData();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Datos borrados.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final marca  = _veh?.brand ?? '-';
    final modelo = _veh?.model ?? '';
    final anio   = _veh?.year?.toString() ?? '-';

    return Scaffold(
      appBar: AppBar(title: const Text('CHISPA CH-C1')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(radius: 28, child: Text('🤖')),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '¡Hola $_saludoNombre! Soy CHISPA CH‑C1',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Card(
              child: ListTile(
                title: Text('$marca $modelo ($anio)'),
                subtitle: const Text('Selección recordada'),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  tooltip: 'Borrar datos guardados',
                  onPressed: _loading ? null : _clearData,
                ),
              ),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              icon: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.volume_up),
              label: Text(_loading ? 'Generando voz…' : 'Escuchar reseña'),
              onPressed: _loading ? null : _speak,
            ),
            const SizedBox(height: 8),
            const Text(
              'Voz: ballad (OpenAI) · Estilo C3PO, español AR, tono divertido',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }
}
