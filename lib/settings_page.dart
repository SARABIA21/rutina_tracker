import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
      ),
      body: const Center(
        child: Text(
          'Pantalla Ajustes en desarrollo',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
