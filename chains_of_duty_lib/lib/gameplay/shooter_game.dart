import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:chains_of_duty/lib/style/characters.dart';

class ShooterGame extends FlameGame with HasTappables, HasCollidables {
  late PlayerCharacter _playerData;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.viewport = FixedResolutionViewport(Vector2(400, 700));
    _playerData = PlayerCharacter();

    final playerSprite = SpriteComponent()
      ..sprite = await loadSprite('player.png')
      ..position = Vector2(200, 600)
      ..size = Vector2(50, 50);
    add(playerSprite);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!_playerData.isAlive()) {
      // handle player death
    }
  }
}
