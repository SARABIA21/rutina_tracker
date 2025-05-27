
import 'package:flutter/material.dart';

class ProgresoPage extends StatelessWidget {
  const ProgresoPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso'),
      ),
      body: const Center(
        child: Text(
          'Pantalla Progreso en desarrollo',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
