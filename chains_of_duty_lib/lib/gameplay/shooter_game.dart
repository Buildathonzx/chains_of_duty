import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:chains_of_duty_lib/style/characters.dart';
import 'package:flame/input.dart';

class ShooterWorld extends World {
  final _random = math.Random();

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(PlayerSquare(Vector2(200, 200)));
  }

  @override
  void onTapDown(TapDownEvent event) {
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

// Updated PlayerSquare with Weapon
class PlayerSquare extends SpriteComponent with HasGameRef<MultiPlayerShooterGame> {
  static const _speed = 150.0;
  Vector2 velocity = Vector2.zero();

  PlayerSquare(Vector2 position)
      : super(
          position: position,
          size: Vector2.all(64),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Load the image then create a sprite:
    final image = await gameRef.images.load('player.png');
    sprite = Sprite(image);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += velocity * dt;
    // Keep player within screen bounds
    position.clamp(Vector2.zero() + size / 2, gameRef.size - size / 2);
  }

  void fireWeapon() {
    final weaponPosition = position + Vector2(0, -size.y / 2);
    gameRef.add(Weapon(weaponPosition, Vector2(0, -1)));
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

// CityScenery Component
class CityScenery extends Component {
  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = Colors.grey;
    // Draw buildings
    for (int i = 0; i < 10; i++) {
      canvas.drawRect(Rect.fromLTWH(i * 80.0, 300, 60, 200), paint);
    }
    // Draw roads
    paint.color = Colors.grey[800]!;
    canvas.drawRect(Rect.fromLTWH(0, 500, 800, 100), paint);
  }

  @override
  void update(double dt) {
    // Static scenery; no updates needed
  }
}

// Weapon Component
class Weapon extends SpriteComponent with HasGameRef<MultiPlayerShooterGame> {
  final Vector2 direction;

  Weapon(Vector2 position, this.direction)
      : super(
          position: position,
          size: Vector2(20, 10),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('weapon.png');
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * 300 * dt;
    // Remove weapon if out of bounds
    if (position.x < 0 || position.x > gameRef.size.x || position.y < 0 || position.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}

// OpponentSquare with Red Tag
class OpponentSquare extends SpriteComponent with HasGameRef<MultiPlayerShooterGame> {
  static const _speed = 100.0;
  final Vector2 direction;

  OpponentSquare({
    required Vector2 position,
    required this.direction,
  }) : super(
          position: position,
          size: Vector2.all(64),
          anchor: Anchor.center,
        );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.loadSprite('enemy.png');
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // Draw red tag at center
    final paint = Paint()..color = Colors.red;
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 5, paint);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position += direction * _speed * dt;
    // Remove opponent if out of bounds
    if (position.x < 0 || position.x > gameRef.size.x || position.y < 0 || position.y > gameRef.size.y) {
      removeFromParent();
    }
  }
}

// Enhanced MultiPlayerShooterGame
class MultiPlayerShooterGame extends FlameGame {
  late PlayerSquare player1;
  late PlayerSquare player2;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CityScenery());

    // Initialize players
    player1 = PlayerSquare(Vector2(100, 400));
    player2 = PlayerSquare(Vector2(700, 400));
    addAll([player1, player2]);

    // Initialize opponents
    spawnOpponent();

    // Add input handling for firing
    add(FiringDetector(player1));
    add(FiringDetector(player2));
  }

  void spawnOpponent() {
    final random = math.Random();
    final position = Vector2(random.nextDouble() * size.x, random.nextDouble() * size.y / 2);
    final direction = Vector2(random.nextDouble() - 0.5, 1).normalized();
    add(OpponentSquare(position: position, direction: direction));
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Spawn opponents periodically
    if (math.Random().nextDouble() < 0.005) {
      spawnOpponent();
    }

    // Collision detection for weapons and opponents
    children.whereType<Weapon>().forEach((weapon) {
      children.whereType<OpponentSquare>().forEach((opponent) {
        if (weapon.toRect().overlaps(opponent.toRect())) {
          opponent.removeFromParent();
          weapon.removeFromParent();
          // Optionally add score or effects here
        }
      });
    });
  }
}

// FiringDetector for handling weapon firing
class FiringDetector extends Component {
  final PlayerSquare player;

  FiringDetector(this.player);
  // Remove 'with TapDetector' for Flame 1.x, or detect taps in the game class
  // so you can call player.fireWeapon() there.
}

extension on CameraComponent {
  set zoom(double zoom) {}
}
