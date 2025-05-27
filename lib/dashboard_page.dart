// lib/dashboard_page.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/rutina.dart';
import 'registro_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  List<DiaRutina> _rutina = [];
  List<bool> _expansionEstado = [];
  Map<String, Map<String, String>> _ultimosRegistros = {};

  @override
  void initState() {
    super.initState();
    _cargarRutina();
    _cargarRegistros();
  }

  Future<void> _cargarRutina() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('rutina_guardada');
    if (data != null) {
      final lista = jsonDecode(data) as List;
      _rutina = lista.map((e) => DiaRutina.fromJson(e)).toList();
      _expansionEstado = List<bool>.filled(_rutina.length, false);
    } else {
      _rutina = [];
      _expansionEstado = [];
    }
    setState(() {});
  }

  Future<void> _cargarRegistros() async {
    final prefs = await SharedPreferences.getInstance();
    final registros = <String, Map<String, String>>{};
    for (var dia in _rutina) {
      for (var ejercicio in dia.ejercicios) {
        final key = 'registro_${ejercicio.nombre}';
        final lista = prefs.getStringList(key) ?? [];
        if (lista.isNotEmpty) {
          final ultimo = lista.last.split('|');
          if (ultimo.length == 3) {
            registros[ejercicio.nombre] = {
              'reps': ultimo[0],
              'peso': ultimo[1],
              'fecha': DateTime.tryParse(ultimo[2])?.toLocal().toString().split(' ')[0] ?? ultimo[2],
            };
          }
        }
      }
    }
    setState(() => _ultimosRegistros = registros);
  }

  Future<void> _guardarRutina() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'rutina_guardada',
      jsonEncode(_rutina.map((e) => e.toJson()).toList()),
    );
  }

  void _agregarDia() {
    setState(() {
      _rutina.add(DiaRutina(
        numero: _rutina.length + 1,
        titulo: 'Día ${_rutina.length + 1}: Nuevo día',
        ejercicios: [],
      ));
      _expansionEstado.add(false);
    });
    _guardarRutina();
  }

  void _eliminarDia(int index) {
    setState(() {
      _rutina.removeAt(index);
      _expansionEstado.removeAt(index);
    });
    _guardarRutina();
    _cargarRegistros();
  }

  void _agregarEjercicio(int diaIndex) {
    setState(() {
      _rutina[diaIndex].ejercicios.add(Ejercicio(
        nombre: 'Nuevo ejercicio',
        series: 3,
        reps: 10,
        color: Colors.grey,
      ));
    });
    _guardarRutina();
  }

  void _eliminarEjercicio(int diaIndex, Ejercicio ejercicio) {
    setState(() {
      _rutina[diaIndex].ejercicios.remove(ejercicio);
    });
    _guardarRutina();
    _cargarRegistros();
  }

  void _reiniciarRutina() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Estás seguro?'),
        content: const Text('Esto eliminará toda la rutina guardada.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
        ],
      ),
    );
    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('rutina_guardada');
      setState(() {
        _rutina.clear();
        _expansionEstado.clear();
        _ultimosRegistros.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RUTINA TRACKER'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.show_chart), onPressed: () => Navigator.pushNamed(context, '/progresoGrafica')),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _reiniciarRutina),
        ],
      ),
      floatingActionButton: FloatingActionButton(onPressed: _agregarDia, child: const Icon(Icons.add)),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: _rutina.length,
        itemBuilder: (context, diaIndex) {
          final dia = _rutina[diaIndex];
          return Card(
            key: ValueKey(dia),
            margin: const EdgeInsets.symmetric(vertical: 8),
            color: Colors.blueGrey.shade800,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ExpansionTile(
              key: ValueKey('exp_${dia.hashCode}'),
              initiallyExpanded: _expansionEstado[diaIndex],
              onExpansionChanged: (exp) => setState(() => _expansionEstado[diaIndex] = exp),
              title: TextFormField(
                initialValue: dia.titulo,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                decoration: const InputDecoration(border: InputBorder.none),
                onChanged: (v) { dia.titulo = v; _guardarRutina(); },
              ),
              children: [
                ...dia.ejercicios.map((ejercicio) {
                  final datos = _ultimosRegistros[ejercicio.nombre] ?? {};
                  return Card(
                    key: ObjectKey(ejercicio),
                    margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    color: ejercicio.color.withOpacity(0.5),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TextFormField(
                            initialValue: ejercicio.nombre,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                            decoration: const InputDecoration(border: OutlineInputBorder(), labelText: 'Nombre'),
                            onChanged: (v) => setState(() { ejercicio.nombre = v; _guardarRutina(); }),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  await _abrirRegistro(context, ejercicio, campo: 'reps');
                                  await _cargarRegistros();
                                },
                                child: Text('Reps\n${datos['reps'] ?? '-'}'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await _abrirRegistro(context, ejercicio, campo: 'peso');
                                  await _cargarRegistros();
                                },
                                child: Text('Peso\n${datos['peso'] ?? '-'}'),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await _abrirRegistro(context, ejercicio, campo: 'fecha');
                                  await _cargarRegistros();
                                },
                                child: Text('Fecha\n${datos['fecha'] ?? '-'}'),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => _eliminarEjercicio(diaIndex, ejercicio),
                            icon: const Icon(Icons.delete_forever),
                            label: const Text('Eliminar ejercicio'),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                TextButton.icon(onPressed: () => _agregarEjercicio(diaIndex), icon: const Icon(Icons.add), label: const Text('Agregar ejercicio')),
                TextButton.icon(onPressed: () => _eliminarDia(diaIndex), icon: const Icon(Icons.delete_forever), label: const Text('Eliminar día')),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _abrirRegistro(BuildContext ctx, Ejercicio ejercicio, {String? campo}) async {
    await Navigator.push(ctx, MaterialPageRoute(builder: (_) => RegistroPage(ejercicio: ejercicio, campo: campo)));
  }
}
