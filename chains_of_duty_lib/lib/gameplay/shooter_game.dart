import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:chains_of_duty_lib/style/characters.dart';

class ShooterWorld extends World with TapCallbacks {
  final _random = math.Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(PlayerSquare(Vector2(200, 200)));
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (!event.handled) {
      add(PlayerSquare(event.localPosition));
      event.handled = true;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Spawn an enemy at intervals.
    if (_random.nextDouble() < 0.01) {
      add(EnemySquare(
        position: Vector2(_random.nextDouble() * 400, _random.nextDouble() * 400),
        direction: Vector2(_random.nextDouble() - 0.5, _random.nextDouble() - 0.5).normalized(),
      ));
    }
  }
}

class PlayerSquare extends SpriteComponent with TapCallbacks {
  static const _speed = 2.0;

  PlayerSquare(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(64),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('player.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    angle += _speed * dt;
    angle %= 2 * math.pi;
  }

  @override
  void onTapDown(TapDownEvent event) {
    removeFromParent();
    event.handled = true;
  }
}

class EnemySquare extends SpriteComponent {
  static const _speed = 100.0;
  final Vector2 direction;

  EnemySquare({
    required Vector2 position,
    required this.direction,
  }) : super(position: position, size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await Sprite.load('enemy.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * _speed * dt;
  }
}

class ShooterGame extends FlameGame {
  ShooterGame() : super(world: ShooterWorld());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    camera.zoom = 1.0;
  }
}

extension on CameraComponent {
  set zoom(double zoom) {}
}
