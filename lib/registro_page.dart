// lib/registro_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/rutina.dart';

class RegistroPage extends StatefulWidget {
  final Ejercicio ejercicio;
  final String? campo;

  const RegistroPage({super.key, required this.ejercicio, this.campo});

  @override
  State<RegistroPage> createState() => _RegistroPageState();
}

class _RegistroPageState extends State<RegistroPage> {
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _pesoController = TextEditingController();
  DateTime _fecha = DateTime.now();

  @override
  void initState() {
    super.initState();
    _cargarUltimoRegistro();
  }

  Future<void> _cargarUltimoRegistro() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'registro_${widget.ejercicio.nombre}';
    final lista = prefs.getStringList(key) ?? [];
    if (lista.isNotEmpty) {
      final partes = lista.last.split('|');
      if (partes.length == 3) {
        _repsController.text = partes[0];
        _pesoController.text = partes[1];
        _fecha = DateTime.tryParse(partes[2]) ?? DateTime.now();
        setState(() {});
      }
    }
  }

  Future<void> _guardarRegistro() async {
    final reps = _repsController.text.trim();
    final peso = _pesoController.text.trim();
    final fecha = _fecha.toIso8601String();

    final prefs = await SharedPreferences.getInstance();
    final key = 'registro_${widget.ejercicio.nombre}';
    final registros = prefs.getStringList(key) ?? [];

    String nuevoRegistro;

    if (widget.campo == 'reps') {
      nuevoRegistro = '$reps|${peso.isNotEmpty ? peso : '0'}|$fecha';
    } else if (widget.campo == 'peso') {
      nuevoRegistro = '${reps.isNotEmpty ? reps : '0'}|$peso|$fecha';
    } else {
      nuevoRegistro = '${reps.isNotEmpty ? reps : '0'}|${peso.isNotEmpty ? peso : '0'}|$fecha';
    }

    registros.add(nuevoRegistro);
    await prefs.setStringList(key, registros);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registro guardado')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Editar Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (widget.campo == 'reps') ...[
              TextField(
                controller: _repsController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Repeticiones (Ej: 2x13)'),
              ),
            ] else if (widget.campo == 'peso') ...[
              TextField(
                controller: _pesoController,
                keyboardType: TextInputType.text,
                decoration: const InputDecoration(labelText: 'Peso (Ej: 20 kg)'),
              ),
            ] else ...[
              ListTile(
                title: const Text('Fecha'),
                subtitle: Text('${_fecha.toLocal()}'.split(' ')[0]),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: _fecha,
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (picked != null) {
                      setState(() {
                        _fecha = picked;
                      });
                    }
                  },
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _guardarRegistro,
              child: const Text('Guardar'),
            )
          ],
        ),
      ),
    );
  }
}
