import 'package:flutter/material.dart';
import 'package:rutina_tracker_app/screens/settings_screen.dart'; // Importa la pantalla de ajustes
import 'dart:io'; // Para el uso de File (para la imagen de perfil)

class MainScreen extends StatefulWidget {
  final String userName;
  final String? userPhotoPath;
  final Function(String) updateUserName;
  final Function(String?) updateUserPhoto;
  final String weightUnit;
  final Function(String) updateWeightUnit;
  final bool notificationsEnabled;
  final Function(bool) updateNotificationsEnabled;

  const MainScreen({
    Key? key,
    required this.userName,
    this.userPhotoPath,
    required this.updateUserName,
    required this.updateUserPhoto,
    required this.weightUnit,
    required this.updateWeightUnit,
    required this.notificationsEnabled,
    required this.updateNotificationsEnabled,
  }) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Para controlar la pestaña seleccionada en el BottomNavigationBar

  // Lista de Widgets (pantallas) para el BottomNavigationBar
  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      _buildDashboardScreen(), // Pantalla de inicio o dashboard
      _buildRoutinesScreen(), // Pantalla de rutinas
      _buildProgressScreen(), // Pantalla de progreso
      SettingsScreen( // Pantalla de ajustes
        userName: widget.userName,
        userPhotoPath: widget.userPhotoPath,
        updateUserName: widget.updateUserName,
        updateUserPhoto: widget.updateUserPhoto,
        weightUnit: widget.weightUnit,
        updateWeightUnit: widget.updateWeightUnit,
        notificationsEnabled: widget.notificationsEnabled,
        updateNotificationsEnabled: widget.updateNotificationsEnabled,
      ),
    ];
  }

  // Método para construir la pantalla del Dashboard (simulado por ahora)
  Widget _buildDashboardScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '¡Bienvenido, ${widget.userName}!',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 60,
            // Si tienes una imagen de perfil, úsala. De lo contrario, un placeholder.
            backgroundImage: widget.userPhotoPath != null && File(widget.userPhotoPath!).existsSync()
                ? FileImage(File(widget.userPhotoPath!))
                : const AssetImage('assets/default_profile.png') as ImageProvider, // Imagen por defecto
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              // Lógica para iniciar una nueva rutina
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Iniciando nueva rutina...')),
              );
            },
            icon: const Icon(Icons.play_arrow),
            label: const Text('Comenzar Rutina'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              textStyle: const TextStyle(fontSize: 18),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Unidad de peso actual: ${widget.weightUnit}',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          Text(
            'Notificaciones: ${widget.notificationsEnabled ? "Activadas" : "Desactivadas"}',
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  // Método para construir la pantalla de Rutinas (simulado por ahora)
  Widget _buildRoutinesScreen() {
    return const Center(
      child: Text(
        'Pantalla de Rutinas (Próximamente)',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }

  // Método para construir la pantalla de Progreso (simulado por ahora)
  Widget _buildProgressScreen() {
    return const Center(
      child: Text(
        'Pantalla de Progreso (Próximamente)',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rutina Tracker - ${_getScreenTitle(_selectedIndex)}'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navegar directamente a la pantalla de ajustes
              // Aunque ya está en el BottomNavigationBar, se puede acceder desde aquí también
              setState(() {
                _selectedIndex = 3; // Índice de SettingsScreen
              });
            },
          ),
        ],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Rutinas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Progreso',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Ajustes',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Para que los ítems sean fijos
        backgroundColor: Colors.grey[850], // Fondo oscuro para la barra de navegación
      ),
    );
  }

  String _getScreenTitle(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Rutinas';
      case 2:
        return 'Progreso';
      case 3:
        return 'Ajustes';
      default:
        return 'Rutina Tracker';
    }
  }
}