import 'package:flutter/material.dart';
import '../services/local_store.dart';
import '../models/vehicle_selection.dart';
import 'user_data_step_page.dart';

class VehicleStepPage extends StatefulWidget {
  final String brand;
  final String model;

  const VehicleStepPage({super.key, required this.brand, required this.model});

  @override
  State<VehicleStepPage> createState() => _VehicleStepPageState();
}

class _VehicleStepPageState extends State<VehicleStepPage> {
  late int _year;
  late int _minYear;
  late int _maxYear;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now().year;
    _minYear = 1980;
    _maxYear = now;
    _year = now; // por defecto
    _preloadIfAny();
  }

  Future<void> _preloadIfAny() async {
    final v = await LocalStore.loadVehicle();
    if (v != null && v.brand == widget.brand && v.model == widget.model) {
      setState(() => _year = v.year.clamp(_minYear, _maxYear));
    }
  }

  Future<void> _saveAndContinue() async {
    setState(() => _saving = true);
    await LocalStore.getOrCreateInstallId(); // asegura ID
    final selection = VehicleSelection(
      brand: widget.brand,
      model: widget.model,
      year: _year,
    );
    await LocalStore.saveVehicle(selection);
    setState(() => _saving = false);

    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const UserDataStepPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final divisions = (_maxYear - _minYear).clamp(1, 1000);
    return Scaffold(
      appBar: AppBar(title: const Text('Tu Vehículo')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Marca: ${widget.brand}', style: Theme.of(context).textTheme.titleMedium),
            Text('Modelo: ${widget.model}', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            Text('Año: $_year', style: Theme.of(context).textTheme.headlineSmall),
            Slider(
              value: _year.toDouble(),
              min: _minYear.toDouble(),
              max: _maxYear.toDouble(),
              divisions: divisions,
              label: '$_year',
              onChanged: (v) => setState(() => _year = v.round()),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _saving ? null : _saveAndContinue,
              child: _saving
                  ? const SizedBox(
                      width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
