import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/menu/bloc/menu_bloc.dart';
import 'package:legalito/menu/bloc/menu_state.dart';

class MenuScreen extends StatefulWidget {
  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  List<String> _phrases = [
    "Evita prestar tu nombre para abrir cuentas bancarias",
  ];

  int _currentPhraseIndex = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(Duration(seconds: 15), (_) {
      setState(() {
        if (_phrases.isNotEmpty) {
          _currentPhraseIndex = (_currentPhraseIndex + 1) % _phrases.length;
        }
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
    final blocState = context.read<MenuBloc>().state;
    if (blocState is MenuLoaded && blocState.legalTips.isNotEmpty) {
      _phrases = blocState.legalTips;
    }
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
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 16,
                      left: 16,
                      right: 150,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        // Burbujas decorativas en el fondo
                        Positioned.fill(
                          child: CustomPaint(
                            painter: BubbleBackgroundPainter(),
                          ),
                        ),

                        // Contenido del banner (frase animada)
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 500),
                          transitionBuilder: (
                            Widget child,
                            Animation<double> animation,
                          ) {
                            final inAnimation = Tween<Offset>(
                              begin: const Offset(
                                1.0,
                                0.0,
                              ), // entra desde la derecha
                              end: Offset.zero,
                            ).animate(animation);

                            final outAnimation = Tween<Offset>(
                              begin: Offset.zero,
                              end: const Offset(
                                -1.0,
                                0.0,
                              ), // sale hacia la izquierda
                            ).animate(animation);

                            return SlideTransition(
                              position:
                                  animation.status == AnimationStatus.reverse
                                      ? outAnimation
                                      : inAnimation,
                              child: child,
                            );
                          },
                          child: Text(
                            _phrases[_currentPhraseIndex],
                            key: ValueKey(
                              _phrases[_currentPhraseIndex],
                            ), // Cambia para disparar animación
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: -70,
                    child: Image.asset(
                      'assets/legalito_banner.png',
                      width: 130,
                      height: 180,
                      fit: BoxFit.fill,
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
                      image: 'assets/legalito_chat.png',
                      color: Color(0xfffeeae1), // pastel naranja
                      onTap: () => Navigator.pushNamed(context, '/chats'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _buildFlatCard(
                      title: 'Solucionar problemas',
                      image: 'assets/legalito_thinking.png',
                      color: Color(0xFFe4fce4), // pastel verde
                      onTap: () =>
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
                      Image.asset(
                        "assets/pdf.png",
                        width: 60,
                        height: 60,
                        fit: BoxFit.fill,
                      ),
                      SizedBox(width: 6),
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
    required String image,
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
              Image.asset(image, width: 65, height: 90, fit: BoxFit.fill),
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
              const BouncingRocket(),
            ],
          ),
        ],
      ),
    );
  }
}

class BouncingRocket extends StatefulWidget {
  const BouncingRocket({Key? key}) : super(key: key);

  @override
  State<BouncingRocket> createState() => _BouncingRocketState();
}

class _BouncingRocketState extends State<BouncingRocket>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 4), // rebote + giro en este tiempo
      vsync: this,
    )..repeat();

    _bounceAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(
          begin: 0.0,
          end: -10.0,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: -10.0,
          end: 0.0,
        ).chain(CurveTween(curve: Curves.bounceOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: ConstantTween(0.0),
        weight: 50,
      ), // pausa antes del siguiente rebote
    ]).animate(_controller);

    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * 3.1416) // 360°
        .animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.translate(
          offset: Offset(0, _bounceAnimation.value),
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: child,
          ),
        );
      },
      child: const Text(
        "🚀",
        style: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w800,
          color: Colors.orangeAccent,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class BubbleBackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color.fromARGB(50, 245, 154, 8) // tono más claro
      ..style = PaintingStyle.fill;

    final bubbles = [
      Offset(20, 20),
      Offset(size.width * 0.25, 10),
      Offset(size.width - 30, 20),
      Offset(size.width * 0.75, 50),
      Offset(10, size.height * 0.4),
      Offset(size.width - 40, size.height * 0.35),
      Offset(size.width * 0.5, size.height * 0.6),
      Offset(30, size.height - 30),
      Offset(size.width - 20, size.height - 40),
      Offset(size.width * 0.5, size.height - 10),
    ];

    final radii = [12.0, 8.0, 10.0, 6.0, 14.0, 10.0, 8.0, 6.0, 12.0, 10.0];

    for (int i = 0; i < bubbles.length; i++) {
      canvas.drawCircle(bubbles[i], radii[i], paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
