import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/menu/guide/bloc/guide_bloc.dart';

// ... imports (no cambian)

class GuideScreen extends StatefulWidget {
  final String title;
  const GuideScreen({super.key, required this.title});

  @override
  _GuideScreenState createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> {
  int _currentStepIndex = 0;
  int _currentLegalitoImage = 0;
  late Timer _legalitoTimer;

  final List<String> _legalitoImages = [
    'assets/legalito_banner.png',
    'assets/legalito_thinking.png',
    'assets/legalito_no_cases.png',
  ];

  @override
  void initState() {
    super.initState();
    _startLegalitoAnimation();
  }

  void _startLegalitoAnimation() {
    _legalitoTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
      setState(() {
        _currentLegalitoImage =
            (_currentLegalitoImage + 1) % _legalitoImages.length;
      });
    });
  }

  void _goToNextStep() {
    setState(() {
      _currentStepIndex++;
    });
  }

  void _goToStep(int index) {
    if (index < _currentStepIndex) {
      setState(() {
        _currentStepIndex = index;
      });
    }
  }

  void _completeGuide() {
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _legalitoTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = const Color(0xFF00C569);
    final Color secondaryColor = const Color(0xFFF7F9FA);

    return Scaffold(
      backgroundColor: secondaryColor,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 6),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 12,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  color: Colors.white,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.arrow_back,
                        color: Color(0xFFFA4A0C),
                        size: 24,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    widget.title,
                    maxLines: 2,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: BlocBuilder<GuideBloc, GuideState>(
        builder: (context, state) {
          if (state is GuideLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is GuideLoaded) {
            final steps = state.steps;
            if (steps.isEmpty) {
              return const Center(child: Text('No se encontraron pasos.'));
            }

            return Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      // Progress circles
                      SizedBox(
                        height: 60,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: steps.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final isActive = index == _currentStepIndex;
                            final isDone = index < _currentStepIndex;

                            return GestureDetector(
                              onTap: () => _goToStep(index),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: isActive ? 50 : 40,
                                height: isActive ? 50 : 40,
                                decoration: BoxDecoration(
                                  color: isDone
                                      ? primaryColor
                                      : isActive
                                          ? Colors.white
                                          : Colors.transparent,
                                  border: Border.all(
                                    color: primaryColor,
                                    width: 2,
                                  ),
                                  shape: BoxShape.circle,
                                  boxShadow: isActive
                                      ? [
                                          BoxShadow(
                                            color:
                                                primaryColor.withOpacity(0.4),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: TextStyle(
                                      color:
                                          isDone ? Colors.white : primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: isActive ? 18 : 16,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Step card
                      Expanded(
                        child: Card(
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          shadowColor: Colors.black.withOpacity(0.1),
                          color: Colors.white,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 20.0),
                            child: SingleChildScrollView(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 20.0),
                                child: RichText(
                                  text: TextSpan(
                                    children:
                                        steps[_currentStepIndex].textSpans,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontSize: 16,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _completeGuide,
                              icon: const Icon(Icons.check_circle_outline),
                              label: const Text('Problema solucionado'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                if (_currentStepIndex < steps.length - 1) {
                                  _goToNextStep();
                                } else {
                                  _completeGuide();
                                }
                              },
                              icon: const Icon(Icons.navigate_next),
                              label: Text(
                                _currentStepIndex < steps.length - 1
                                    ? 'Siguiente solución'
                                    : 'Finalizar',
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 4,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Legalito animado
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            )
                          ],
                        ),
                        child: const Text(
                          '¿Te sirvió este paso?',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      Image.asset(
                        _legalitoImages[_currentLegalitoImage],
                        height: 70,
                        width: 70,
                      ),
                    ],
                  ),
                ),
              ],
            );
          } else if (state is GuideError) {
            return Center(
              child: Text(
                'Error: ${state.message}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
