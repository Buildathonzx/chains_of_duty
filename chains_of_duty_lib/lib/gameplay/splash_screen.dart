import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToMainMenu();
  }

  Future<void> _navigateToMainMenu() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    GoRouter.of(context).go('/main_menu');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/chainsofduty.jpg'),

        
      ),
    );
  }
}
