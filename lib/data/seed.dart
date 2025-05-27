// lib/data/seed.dart
import 'package:flutter/material.dart';
import '../models/rutina.dart';  // import relativo al modelo

/// Lista inicial de la rutina precargada (6 días) con sus ejercicios.
final List<DiaRutina> rutinasIniciales = [
  DiaRutina(
    numero: 1,
    titulo: 'Día 1: Pecho + Hombro + Tríceps',
    ejercicios: [
      Ejercicio(nombre: 'Hammer Chest Press',    series: 4, reps: 12, color: Colors.red),
      Ejercicio(nombre: 'Pectoral Fly',           series: 4, reps: 15, color: Colors.orange),
      Ejercicio(nombre: 'Hammer Shoulder Press',  series: 4, reps: 15, color: Colors.amber),
      Ejercicio(nombre: 'Shoulder Press',         series: 3, reps: 10, color: Colors.blue),
      Ejercicio(nombre: 'Extensión Tríceps con barra', series: 4, reps: 12, color: Colors.green),
      Ejercicio(nombre: 'Skull crushers con cuerda',    series: 3, reps: 20, color: Colors.purple),
    ],
  ),
  // … repite para los días 2 a 6 exactamente como los definiste …
];
