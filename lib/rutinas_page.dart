import 'package:flutter/material.dart';

class RutinasPage extends StatelessWidget {
  const RutinasPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'Aquí se mostrará la vista de Rutinas.',
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
