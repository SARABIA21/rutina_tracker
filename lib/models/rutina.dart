
// lib/models/rutina.dart

import 'package:flutter/material.dart';

/// Representa un ejercicio en la rutina.
class Ejercicio {
  String nombre;
  int series;
  int reps;
  Color color;

  Ejercicio({
    required this.nombre,
    required this.series,
    required this.reps,
    required this.color,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      nombre: json['nombre'],
      series: json['series'],
      reps: json['reps'],
      color: Color(json['color']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nombre': nombre,
      'series': series,
      'reps': reps,
      'color': color.value,
    };
  }
}

/// Representa un día de entrenamiento con su lista de ejercicios.
class DiaRutina {
  int numero;            // Día número (1 a n)
  String titulo;         // Ej. "Día 1: Pecho + Hombro + Tríceps"
  List<Ejercicio> ejercicios;

  DiaRutina({
    required this.numero,
    required this.titulo,
    required this.ejercicios,
  });

  factory DiaRutina.fromJson(Map<String, dynamic> json) {
    return DiaRutina(
      numero: json['numero'],
      titulo: json['titulo'],
      ejercicios: (json['ejercicios'] as List)
          .map((e) => Ejercicio.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'titulo': titulo,
      'ejercicios': ejercicios.map((e) => e.toJson()).toList(),
    };
  }
}
