import 'package:flutter/material.dart';

class ShooterGame extends StatefulWidget {
  const ShooterGame({super.key});

  @override
  State<ShooterGame> createState() => _ShooterGameState();
}

class _ShooterGameState extends State<ShooterGame> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Shooter Game',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
