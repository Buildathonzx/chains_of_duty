import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:chains_of_duty_lib/gameplay/shooter_game.dart';

class FundamentalGameScreen extends StatefulWidget {
  const FundamentalGameScreen({Key? key}) : super(key: key);

  @override
  State<FundamentalGameScreen> createState() => _FundamentalGameScreenState();
}

class _FundamentalGameScreenState extends State<FundamentalGameScreen> {
  int _score = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GameWidget(
        game: ShooterGame(),
        overlayBuilderMap: {
          'ScoreOverlay': (context, game) {
            return Positioned(
              top: 50,
              left: 20,
              child: Text(
                'Score: $_score',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            );
          },
        },
      ),
    );
  }
}