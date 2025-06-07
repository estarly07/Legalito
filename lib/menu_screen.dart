import 'dart:async';
import 'package:flutter/material.dart';

class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final List<String> _phrases = [
    "¿Firmaste sin leer? ¡Yo reviso por ti!",
    "¡No más letras pequeñas! Legalito te las agranda.",
    "¿Arriendo problemático? 🏠 Legalito al rescate.",
    "¿Dudas legales? 📚 ¡Legalito responde!",
  ];

  int _currentPhraseIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 30), (_) {
      setState(() {
        _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F8F8),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Texto saludo
              _Title(),
              SizedBox(height: 50),

              // 2. Banner con consejo y legalito
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    padding: EdgeInsets.only(
                      top: 16,
                      bottom: 16,
                      left: 16,
                      right: 160,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      child: Text(
                        _phrases[_currentPhraseIndex],
                        key: ValueKey(_phrases[_currentPhraseIndex]),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    right: -10,
                    top: -30,
                    child: Image.asset(
                      'assets/legalito_front.png',
                      width: 150,
                      height: 120,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32),

              // 3. Dos tarjetas en Row sin sombra, pastel naranja y verde
              Row(
                children: [
                  Expanded(
                    child: _buildFlatCard(
                      title: 'Asistente Legal',
                      icon: Icons.chat_bubble_outline,
                      color: Color(0xfffeeae1), // pastel naranja
                      onTap: () => Navigator.pushNamed(context, '/chats'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildFlatCard(
                      title: 'Preguntas rápidas',
                      icon: Icons.flash_on_rounded,
                      color: Color(0xFFe4fce4), // pastel verde
                      onTap:
                          () =>
                              Navigator.pushNamed(context, '/simple_questions'),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 30),

              // 4. Tarjeta de documentos con sombra tipo buscador
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/documentos'),
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        spreadRadius: 2,
                        offset: Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_rounded,
                        size: 32,
                        color: Colors.black87,
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          'Generar documentos legales',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 18,
                        color: Colors.black54,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFlatCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 120,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 36, color: Colors.black87),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 24),
          Text(
            "¡Hey!",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),

          SizedBox(height: 4),
          Row(
            children: [
              Text(
                "Soy Legalito",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              AnimatedSwitcher(
                duration: Duration(milliseconds: 600),
                transitionBuilder:
                    (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                child: Text(
                  " 🚀 ",
                  key: ValueKey(
                    DateTime.now().second % 2 == 0,
                  ), // Cambio forzado para reiniciar animación
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Colors.orangeAccent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
