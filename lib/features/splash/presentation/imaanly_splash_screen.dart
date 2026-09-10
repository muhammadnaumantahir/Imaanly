import 'dart:async';

import 'package:flutter/material.dart';

import '../../home/presentation/imaanly_home_page.dart';

class ImaanlySplashScreen extends StatefulWidget {
  const ImaanlySplashScreen({super.key});

  @override
  State<ImaanlySplashScreen> createState() => _ImaanlySplashScreenState();
}

class _ImaanlySplashScreenState extends State<ImaanlySplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<double> _scale;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: .88, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 1450), _openHome);
  }

  void _openHome() {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder<void>(
        pageBuilder: (_, __, ___) => const ImaanlyHomePage(),
        transitionDuration: const Duration(milliseconds: 420),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
          child: child,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const deepGreen = Color(0xFF0B3025);
    const green = Color(0xFF2E6B52);
    const gold = Color(0xFFD4B86A);
    const cream = Color(0xFFF7F1E2);

    return Scaffold(
      backgroundColor: deepGreen,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 154,
                    height: 154,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF123D2F),
                      border: Border.all(color: gold, width: 2),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x55204F3B),
                          blurRadius: 36,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(
                          Icons.nightlight_round,
                          size: 82,
                          color: gold,
                        ),
                        Positioned(
                          top: 31,
                          right: 33,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: cream,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                        const Text(
                          'I',
                          style: TextStyle(
                            color: cream,
                            fontSize: 46,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Imaanly',
                    style: TextStyle(
                      color: cream,
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1.2,
                    ),
                  ),
                  const SizedBox(height: 9),
                  const Text(
                    'Your daily Islamic companion',
                    style: TextStyle(
                      color: Color(0xFFB7CFC3),
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      letterSpacing: .2,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(99),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
