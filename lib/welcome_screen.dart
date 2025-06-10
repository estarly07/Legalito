import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounce;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _bounce = Tween<double>(
      begin: 0,
      end: -12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          // Fondo con burbujas suaves
          Positioned(
            top: -40,
            left: -30,
            child: _bubble(150, AppColors.primaryBlue.withOpacity(0.1)),
          ),
          Positioned(
            bottom: -50,
            right: -40,
            child: _bubble(180, AppColors.primaryBlue.withOpacity(0.08)),
          ),
          // Contenido principal
          Stack(
            children: [
              Wrap(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: size.height * 0.4,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.08,
                            ), // Color muy suave
                            blurRadius: 24, // Qué tan difusa es la sombra
                            spreadRadius:
                                12, // Qué tanto se extiende desde el widget
                            offset: const Offset(
                              0,
                              8,
                            ), // Dirección de la sombra (eje X, Y)
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bienvenido a',
                              style: GoogleFonts.inter(
                                fontSize: 20,
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Legalito',
                              style: GoogleFonts.poppins(
                                fontSize: 36,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryBlue,
                                shadows: [
                                  Shadow(
                                    blurRadius: 4,
                                    offset: const Offset(2, 2),
                                    color: Colors.black12,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No soy tu abogado...\npero te asesoro bonito 😉',
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: AppColors.mediumGray,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _mainButton(
                              context,
                              text: '¡Vamos al Caso!',
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/menu',
                              ),
                              filled: true,
                            ),
                            const SizedBox(height: 12),
                            _mainButton(
                              context,
                              text: 'Unirme',
                              onTap: () => Navigator.pushReplacementNamed(
                                context,
                                '/login',
                              ),
                              filled: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: size.height * 0.1),
                child: Align(
                  alignment: Alignment.topRight,
                  child: AnimatedBuilder(
                    animation: _bounce,
                    builder: (_, child) {
                      return Transform.translate(
                        offset: Offset(0, _bounce.value),
                        child: child,
                      );
                    },
                    child: Image.asset(
                      'assets/legalito_juez.png',
                      height: size.height * 0.4,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bubble(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _mainButton(
    BuildContext context, {
    required String text,
    required VoidCallback onTap,
    required bool filled,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AppColors.primaryBlue : Colors.white,
          foregroundColor: filled ? Colors.white : AppColors.primaryBlue,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: filled
                ? BorderSide.none
                : BorderSide(color: Color(0xfffeeae1), width: 1.5),
          ),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
