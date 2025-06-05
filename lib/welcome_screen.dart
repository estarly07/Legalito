import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:math';
import 'theme.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceOut),
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            _controller.forward(from: 0);
          }
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite, // Set background to white
      body: Stack(
        children: [
          // Background Bubbles
          Positioned(
            top: screenSize.height * 0.05, // Top of the screen
            right: screenSize.width * 0.5, // Towards the right
            child: Container(
              width: 80, // Large size
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.25, // Slightly lower
            right: screenSize.width * 0.35, // Further left
            child: Container(
              width: 40, // Small size
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.35, // Lower
            right: screenSize.width * 0.15, // Closer to the right edge
            child: Container(
              width: 100, // Large size
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: screenSize.height * 0.4, // Vertical center
            left: screenSize.width * 0.4, // Horizontal center
            child: Container(
              width: 50, // Small size
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -50, // Slightly lower
            right: -50, // Slightly to the right
            child: Container(
              width: 120, // Large size
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: screenSize.height * 0.2, // Above the text/buttons
            left: screenSize.width * 0.1, // Towards the left
            child: Container(
              width: 60, // Small size
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.mediumGray.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Panda Image
          Positioned(
            top: 0, // Position at the top
            right:
                -(screenSize.width *
                    0.5), // Position to the right to show half of the image
            child: Transform.rotate(
              // Rotate slightly to the left (in radians)
              angle: -0.3,
              child: Image.asset(
                'assets/legalito_front.png', // Changed to 50% width
                width: screenSize.width,
                height: screenSize.height * 0.7,
                fit: BoxFit.contain,
              ),
            ),
          ),

          // Text and Buttons Column
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize:
                    MainAxisSize
                        .min, // Make the column size based on its content
                children: [
                  // Main Text
                  RichText(
                    text: TextSpan(
                      style: GoogleFonts.inter(
                        // Use Inter font
                        fontSize: 24, // Large font size
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Use textPrimary color
                        height: 1.2,
                      ),
                      children: [
                        const TextSpan(text: 'Bienvenido a\n'),
                        WidgetSpan(
                          child: AnimatedBuilder(
                            animation: _animation,
                            builder: (context, child) {
                              return Transform.translate(
                                offset: Offset(0, -_animation.value),
                                child: Text(
                                  'Legalito!',
                                  style: GoogleFonts.poppins(
                                    // Use Poppins for highlighted text
                                    fontSize:
                                        38, // Larger font size for emphasis
                                    fontWeight:
                                        FontWeight.bold, // Extra bold weight
                                    color:
                                        AppColors
                                            .primaryBlue, // Highlight with primary blue
                                    shadows: [
                                      Shadow(
                                        color: Colors.black.withOpacity(0.3),
                                        offset: const Offset(2, 2),
                                        blurRadius: 3,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8.0), // Small space between texts
                  Text(
                    'No soy tu abogado ...pero te asesoro bonito',
                    style: GoogleFonts.inter(
                      fontSize: 16, // Smaller font size
                      fontWeight: FontWeight.w500,
                      color: AppColors.mediumGray, // More subtle color
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ), // Add space between text and buttons
                  // Buttons
                  Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // Make buttons full width
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            // Use pushReplacementNamed for welcome screen
                            context,
                            '/menu', // Navigate to main screen
                          ); // Navigate to main screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryBlue,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32, // Increase horizontal padding
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                        ),
                        child: Text(
                          '¡Vamos al Caso!',
                          style: GoogleFonts.poppins(
                            fontSize: 16, // Adjusted font size
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ), // Add vertical space between buttons
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(
                            context, // Use pushReplacementNamed
                            '/auth', // Assuming '/auth' route exists for login/registration
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white, // White background
                          foregroundColor:
                              AppColors.primaryBlue, // Primary color for text
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                          side: BorderSide(
                            // Primary color border
                            color: AppColors.primaryBlue,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          'Unirme',
                          style: GoogleFonts.poppins(
                            fontSize: 16, // Adjusted font size
                            color:
                                AppColors
                                    .primaryBlue, // Use primary blue for text
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32.0), // Add padding at the bottom
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
