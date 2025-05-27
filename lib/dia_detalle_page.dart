import 'package:flutter/material.dart';
import 'package:rutina_tracker_app/models/rutina.dart';

class DiaDetallePage extends StatelessWidget {
  final String tituloDia;
  final List<Ejercicio> ejercicios;
  final void Function(int index, String nuevoNombre) onNombreEditado;

  const DiaDetallePage({
    Key? key,
    required this.tituloDia,
    required this.ejercicios,
    required this.onNombreEditado,
  }) : super(key: key);

  void _editarEjercicio(BuildContext context, int index) {
    final controller = TextEditingController(text: ejercicios[index].nombre);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Nuevo nombre'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final nuevoNombre = controller.text.trim();
              if (nuevoNombre.isNotEmpty) {
                onNombreEditado(index, nuevoNombre);
              }
              Navigator.pop(context);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(tituloDia)),
      body: ListView.builder(
        itemCount: ejercicios.length,
        itemBuilder: (context, index) {
          final ejercicio = ejercicios[index];
          return ListTile(
            leading: const Icon(Icons.fitness_center),
            title: Text(ejercicio.nombre),
            trailing: IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => _editarEjercicio(context, index),
            ),
          );
        },
      ),
    );
  }
}
