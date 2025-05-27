import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  String _userName = 'Usuario';
  String? _imagePath;
  late final String _phrase;

  final List<String> _phrases = [
    '¡SIGUE ADELANTE, CADA REP CUENTA!',
    '¡NO TE DETENGAS HASTA SENTIRTE ORGULLOSO!',
    '¡LA FUERZA VIENE DE CADA ESFUERZO!',
    '¡HOY ES EL DÍA PARA ROMPER TUS LÍMITES!',
    '¡TU CUERPO TE AGRADECERÁ HOY!',
    '¡CON DISCIPLINA TODO ES POSIBLE!',
    '¡HAZLO POR TU YO DEL FUTURO!',
    '¡CADA GOTA DE SUDOR TE ACERCA A TU META!',
    '¡LEVANTA PESOS, LEVANTA LA PASIÓN!',
    '¡EL DOLOR DE HOY SERÁ TU FUERZA MAÑANA!',
    '¡TRANSFORMA TU ESFUERZO EN RESULTADOS!',
    '¡UN GRAN CAMINO EMPIEZA CON UN PASO!',
    '¡NO HAY EXCUSAS, SOLO RESULTADOS!',
    '¡HAZ QUE CADA REP CUENTE!',
    '¡SUPÉRATE CADA DÍA MÁS!',
    '¡TU VOLUNTAD ES MÁS FUERTE QUE TUS MÚSCULOS!',
    '¡ENTRENA DURO, SONRÍE MÁS!',
    '¡TU PROGRESO HABLA MÁS QUE TUS PALABRAS!',
    '¡DIFICULTAD ES SINÓNIMO DE CRECIMIENTO!',
    '¡EL ÉXITO ES LA SUMA DE PEQUEÑOS ESFUERZOS!',
  ];

  late final AnimationController _ctrl;
  late final Animation<double> _greetOpacity;
  late final Animation<Offset> _phraseSlide;
  late final Animation<double> _phraseOpacity;
  late final Animation<double> _avatarScale;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _phrase = _phrases[Random().nextInt(_phrases.length)];

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _greetOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.4, curve: Curves.easeOut))
    );

    _phraseSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 0.7, curve: Curves.easeOut))
    );
    _phraseOpacity = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.4, 0.7, curve: Curves.easeOut))
    );

    _avatarScale = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: const Interval(0.7, 1.0, curve: Curves.elasticOut))
    );

    _ctrl.forward();

    Timer(const Duration(seconds: 9), () {
      Navigator.pushReplacementNamed(context, '/dashboard');
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString('userName') ?? 'Usuario';
      _imagePath = prefs.getString('userPhotoPath');
    });
  }

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return '¡Buenos días!';
    if (h < 19) return '¡Buenas tardes!';
    return '¡Buenas noches!';
  }

  @override
  Widget build(BuildContext context) {
    final imageProvider = (_imagePath != null && File(_imagePath!).existsSync())
        ? FileImage(File(_imagePath!))
        : const AssetImage('assets/images/default_profile.png')
            as ImageProvider;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/images/splash_bg_metal.png', fit: BoxFit.cover),
          Container(color: Colors.black.withOpacity(0.3)),
          Column(
            children: [
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => Column(
                  children: [
                    Opacity(
                      opacity: _greetOpacity.value,
                      child: Text(
                        _greeting(),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.bebasNeue(
                          textStyle: TextStyle(
                            color: Colors.grey[200],
                            fontSize: 44,
                            fontWeight: FontWeight.w600,
                            shadows: const [
                              Shadow(blurRadius: 4, color: Colors.black54, offset: Offset(2,2)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SlideTransition(
                      position: _phraseSlide,
                      child: Opacity(
                        opacity: _phraseOpacity.value,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Text(
                            _phrase,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.robotoCondensed(
                              textStyle: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 20,
                                fontStyle: FontStyle.italic,
                                shadows: const [
                                  Shadow(blurRadius: 2, color: Colors.black45, offset: Offset(1,1)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    Transform.scale(
                      scale: _avatarScale.value,
                      child: CircleAvatar(
                        radius: 70,
                        backgroundColor: Colors.grey[800],
                        backgroundImage: imageProvider,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
