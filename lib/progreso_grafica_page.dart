// lib/progreso_grafica.dart

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgresoGraficaPage extends StatefulWidget {
  const ProgresoGraficaPage({super.key});

  @override
  State<ProgresoGraficaPage> createState() => _ProgresoGraficaPageState();
}

class _ProgresoGraficaPageState extends State<ProgresoGraficaPage> {
  Map<String, List<Map<String, dynamic>>> registrosPorEjercicio = {};

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    final claves = prefs.getKeys().where((k) => k.startsWith('registro_'));

    final mapa = <String, List<Map<String, dynamic>>>{};

    for (var clave in claves) {
      final lista = prefs.getStringList(clave) ?? [];
      final nombre = clave.replaceFirst('registro_', '');

      mapa[nombre] = lista.map((item) {
        final partes = item.split('|');
        return {
          'fecha': DateTime.tryParse(partes[2]) ?? DateTime.now(),
          'peso': double.tryParse(partes[1]) ?? 0.0,
        };
      }).toList();
    }

    setState(() {
      registrosPorEjercicio = mapa;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso de Peso'),
      ),
      body: registrosPorEjercicio.isEmpty
          ? const Center(child: Text('No hay datos disponibles'))
          : ListView(
              padding: const EdgeInsets.all(12.0),
              children: registrosPorEjercicio.entries.map((entry) {
                final nombre = entry.key;
                final datos = entry.value;

                final spots = datos.map((registro) {
                  return FlSpot(
                    registro['fecha'].millisecondsSinceEpoch.toDouble(),
                    registro['peso'],
                  );
                }).toList();

                spots.sort((a, b) => a.x.compareTo(b.x));

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        AspectRatio(
                          aspectRatio: 1.5,
                          child: LineChart(
                            LineChartData(
                              borderData: FlBorderData(show: true),
                              titlesData: FlTitlesData(show: false),
                              gridData: FlGridData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  barWidth: 3,
                                  color: Colors.blue,
                                  dotData: FlDotData(show: false),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}
