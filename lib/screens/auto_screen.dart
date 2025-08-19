import 'package:flutter/material.dart';
import '../services/car_api_service.dart'; // ajustá si está en otro folder

class AutoScreen extends StatefulWidget {
  const AutoScreen({super.key});

  @override
  State<AutoScreen> createState() => _AutoScreenState();
}

class _AutoScreenState extends State<AutoScreen> {
  List<String> _marcas = [];
  String? _marcaSeleccionada;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarMarcas();
  }

  void _cargarMarcas() async {
    try {
      final marcas = await CarApiService.obtenerMarcas();
      setState(() {
        _marcas = marcas;
        _cargando = false;
      });
    } catch (e) {
      print('Error cargando marcas: $e');
      setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Seleccioná tu auto')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _cargando
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(labelText: 'Marca'),
                    value: _marcaSeleccionada,
                    items: _marcas.map((marca) {
                      return DropdownMenuItem(
                        value: marca,
                        child: Text(marca),
                      );
                    }).toList(),
                    onChanged: (valor) {
                      setState(() {
                        _marcaSeleccionada = valor;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _marcaSeleccionada == null
                        ? null
                        : () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content:
                                    Text('Seleccionaste: $_marcaSeleccionada'),
                              ),
                            );
                          },
                    child: Text('Confirmar marca'),
                  )
                ],
              ),
      ),
    );
  }
}
