import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:legalito/menu/guide/bloc/guide_bloc.dart';
import 'package:legalito/menu/guide/guide.dart';
import 'package:legalito/menu/guide/guide_screen.dart';

class ProblemCarouselPageView extends StatefulWidget {
  final List<Guide> guides;
  const ProblemCarouselPageView({super.key, required this.guides});

  @override
  State<ProblemCarouselPageView> createState() =>
      _ProblemCarouselPageViewState();
}

class _ProblemCarouselPageViewState extends State<ProblemCarouselPageView> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  late Timer _autoScrollTimer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(Duration(seconds: 4), (_) {
      if (_pageController.hasClients) {
        _currentIndex++;
        if (_currentIndex >= widget.guides.length) {
          _currentIndex = 0;
        }
        _pageController.animateToPage(
          _currentIndex,
          duration: Duration(milliseconds: 600),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: PageView.builder(
        controller: _pageController,
        itemCount: widget.guides.length,
        itemBuilder: (context, index) {
          final guide = widget.guides[index];

          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BlocProvider(
                    create: (_) =>
                        GuideBloc()..add(GetSolutionStepsEvent(guide.title)),
                    child: GuideScreen(title: guide.title),
                  ),
                ),
              );
            },
            child: AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double scale = 1.0;
                if (_pageController.position.haveDimensions) {
                  scale = (_pageController.page! - index).abs();
                  scale = (1 - (scale * 0.15)).clamp(0.85, 1.0);
                }

                return Transform.scale(
                  scale: scale,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8), // espacio entre items
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 10,
                                offset: Offset(0, 6),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.asset(
                              guide.image,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 60,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.vertical(
                                  bottom: Radius.circular(20)),
                              gradient: LinearGradient(
                                colors: [
                                  Colors.black.withOpacity(0.75),
                                  Colors.transparent
                                ],
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                              ),
                            ),
                            child: Text(
                              guide.title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
