// lib/progress_chart_page.dart

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
  Map<String, List<_RegistroProgreso>> registrosPorEjercicio = {};
  String ejercicioSeleccionado = '';

  @override
  void initState() {
    super.initState();
    _cargarRegistros();
  }

  Future<void> _cargarRegistros() async {
    final prefs = await SharedPreferences.getInstance();
    final todosLosRegistros = <String, List<_RegistroProgreso>>{};

    for (var key in prefs.getKeys()) {
      if (key.startsWith('registro_')) {
        final nombreEjercicio = key.replaceFirst('registro_', '');

        final rutinaData = prefs.getString('rutina_guardada');
        if (rutinaData != null && !rutinaData.contains(nombreEjercicio)) {
          await prefs.remove(key);
          continue;
        }

        final lista = prefs.getStringList(key) ?? [];

        final registros = lista.map((registro) {
          final partes = registro.split('|');
          return _RegistroProgreso(
            fecha: DateTime.tryParse(partes[2]) ?? DateTime.now(),
            peso: double.tryParse(partes[1]) ?? 0,
          );
        }).toList();

        registros.sort((a, b) => a.fecha.compareTo(b.fecha));
        todosLosRegistros[nombreEjercicio] = registros;
      }
    }

    setState(() {
      registrosPorEjercicio = todosLosRegistros;
      if (!registrosPorEjercicio.containsKey(ejercicioSeleccionado) && registrosPorEjercicio.isNotEmpty) {
        ejercicioSeleccionado = registrosPorEjercicio.keys.first;
      } else if (registrosPorEjercicio.isEmpty) {
        ejercicioSeleccionado = '';
      }
    });
  }

  void _reiniciarGrafica() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('¿Borrar toda la gráfica?'),
        content: const Text('Esto eliminará todos los registros de progreso.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final prefs = await SharedPreferences.getInstance();
      for (String key in prefs.getKeys()) {
        if (key.startsWith('registro_')) {
          await prefs.remove(key);
        }
      }
      setState(() {
        registrosPorEjercicio.clear();
        ejercicioSeleccionado = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final registros = registrosPorEjercicio[ejercicioSeleccionado] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso en Peso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualizar',
            onPressed: _cargarRegistros,
          ),
          IconButton(
            icon: const Icon(Icons.delete_forever),
            tooltip: 'Borrar gráfica',
            onPressed: _reiniciarGrafica,
          )
        ],
      ),
      body: registrosPorEjercicio.isEmpty
          ? const Center(child: Text('No hay datos de progreso.'))
          : Column(
              children: [
                DropdownButton<String>(
                  value: ejercicioSeleccionado,
                  isExpanded: true,
                  items: registrosPorEjercicio.keys.map((nombre) {
                    return DropdownMenuItem(
                      value: nombre,
                      child: Text(nombre),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => ejercicioSeleccionado = value);
                    }
                  },
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 48.0),
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: true,
                          horizontalInterval: 5,
                          verticalInterval: 1,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: Colors.grey.shade700,
                            strokeWidth: 1,
                          ),
                          getDrawingVerticalLine: (value) => FlLine(
                            color: Colors.grey.shade700,
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: const Text('Peso', style: TextStyle(color: Colors.white)),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 5,
                              getTitlesWidget: (value, meta) => Text(
                                value.toStringAsFixed(0),
                                style: const TextStyle(fontSize: 10),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            axisNameWidget: const Padding(
                              padding: EdgeInsets.only(top: 8.0),
                              child: Text('Fecha', style: TextStyle(color: Colors.white)),
                            ),
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                if (value.toInt() >= 0 && value.toInt() < registros.length) {
                                  final date = registros[value.toInt()].fecha;
                                  return Transform.rotate(
                                    angle: -0.7,
                                    child: Text(
                                      '${date.day}/${date.month}',
                                      style: const TextStyle(fontSize: 10),
                                    ),
                                  );
                                }
                                return const Text('');
                              },
                            ),
                          ),
                          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        ),
                        borderData: FlBorderData(
                          show: true,
                          border: const Border(
                            bottom: BorderSide(color: Colors.white),
                            left: BorderSide(color: Colors.white),
                          ),
                        ),
                        minX: 0,
                        maxX: (registros.length - 1).toDouble(),
                        minY: 0,
                        maxY: registros.map((e) => e.peso).fold<double>(0, (a, b) => b > a ? b : a) + 5,
                        lineBarsData: [
                          LineChartBarData(
                            spots: registros
                                .asMap()
                                .entries
                                .map((e) => FlSpot(e.key.toDouble(), e.value.peso))
                                .toList(),
                            isCurved: true,
                            barWidth: 3,
                            color: Colors.cyanAccent,
                            dotData: FlDotData(
                              show: true,
                              getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                radius: 4,
                                color: Colors.cyanAccent,
                                strokeWidth: 1,
                                strokeColor: Colors.white,
                              ),
                            ),
                            belowBarData: BarAreaData(show: false),
                          )
                        ],
                        lineTouchData: LineTouchData(
                          handleBuiltInTouches: true,
                          touchTooltipData: LineTouchTooltipData(
                            tooltipBgColor: Colors.black87,
                            showOnTopOfTheChartBoxArea: true,
                            fitInsideHorizontally: true,
                            fitInsideVertically: true,
                            getTooltipItems: (touchedSpots) {
                              return touchedSpots.map((spot) {
                                final index = spot.x.toInt();
                                if (index < registros.length) {
                                  final registro = registros[index];
                                  final fecha = '${registro.fecha.day}/${registro.fecha.month}/${registro.fecha.year}';
                                  return LineTooltipItem(
                                    'Fecha: $fecha\nPeso: ${registro.peso} kg',
                                    const TextStyle(color: Colors.white),
                                  );
                                }
                                return null;
                              }).toList();
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }
}

class _RegistroProgreso {
  final DateTime fecha;
  final double peso;

  _RegistroProgreso({required this.fecha, required this.peso});
}
