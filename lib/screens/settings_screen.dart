import 'package:flutter/material.dart';
import 'dart:io'; // Para el uso de File (para la imagen de perfil)
import 'package:image_picker/image_picker.dart'; // Para seleccionar imágenes

class SettingsScreen extends StatefulWidget {
  final String userName;
  final String? userPhotoPath;
  final Function(String) updateUserName;
  final Function(String?) updateUserPhoto;
  final String weightUnit;
  final Function(String) updateWeightUnit;
  final bool notificationsEnabled;
  final Function(bool) updateNotificationsEnabled;

  const SettingsScreen({
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
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _userNameController;
  late String _selectedWeightUnit;
  late bool _notificationsToggle;
  File? _imageFile; // Para la imagen seleccionada del dispositivo

  @override
  void initState() {
    super.initState();
    _userNameController = TextEditingController(text: widget.userName);
    _selectedWeightUnit = widget.weightUnit;
    _notificationsToggle = widget.notificationsEnabled;
    if (widget.userPhotoPath != null) {
      _imageFile = File(widget.userPhotoPath!);
    }
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  // Método para seleccionar una imagen de la galería
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      widget.updateUserPhoto(pickedFile.path); // Guarda la ruta de la imagen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ajustes'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Sección de perfil
            const Text(
              'Perfil',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: _pickImage, // Abre el selector de imagen al tocar
                child: CircleAvatar(
                  radius: 70,
                  backgroundColor: Colors.grey[700],
                  backgroundImage: _imageFile != null
                      ? FileImage(_imageFile!)
                      : const AssetImage('assets/default_profile.png') as ImageProvider, // Si no hay foto, usa un asset por defecto
                  child: _imageFile == null
                      ? const Icon(
                          Icons.camera_alt,
                          size: 40,
                          color: Colors.white54,
                        )
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _userNameController,
              decoration: InputDecoration(
                labelText: 'Nombre de Usuario',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              onChanged: (value) {
                widget.updateUserName(value); // Actualiza el nombre de usuario
              },
            ),
            const SizedBox(height: 30),

            // Sección de unidades
            const Text(
              'Unidades',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: _selectedWeightUnit,
              decoration: InputDecoration(
                labelText: 'Unidad de Peso',
                labelStyle: const TextStyle(color: Colors.white70),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.orange, width: 2),
                ),
              ),
              dropdownColor: Colors.grey[800],
              style: const TextStyle(color: Colors.white),
              items: <String>['kg', 'lbs']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedWeightUnit = newValue!;
                });
                widget.updateWeightUnit(newValue!); // Actualiza la unidad de peso
              },
            ),
            const SizedBox(height: 30),

            // Sección de notificaciones
            const Text(
              'Notificaciones',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: const Text(
                'Habilitar Notificaciones',
                style: TextStyle(color: Colors.white),
              ),
              value: _notificationsToggle,
              onChanged: (bool value) {
                setState(() {
                  _notificationsToggle = value;
                });
                widget.updateNotificationsEnabled(value); // Actualiza el estado de las notificaciones
              },
              activeColor: Colors.orange,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[700],
            ),
          ],
        ),
      ),
    );
  }
}