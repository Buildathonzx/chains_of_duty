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

// Enhanced CityScenery with vibrant colors and parallax effect
class CityScenery extends Component {
  final List<Rect> _buildings = [];
  final List<Color> _buildingColors = [];
  late List<List<Rect>> _parallaxLayers;
  late List<Color> _skyColors;
  double _time = 0;

  CityScenery() {
    _initializeScenery();
  }

  void _initializeScenery() {
    // Create vibrant sky gradient
    _skyColors = [
      const Color(0xFF1a2a6c),
      const Color(0xFF4b2891),
      const Color(0xFFb21f1f),
      const Color(0xFFfdbb2d),
    ];

    // Generate random buildings with varied heights and colors
    final random = math.Random();
    for (int i = 0; i < 20; i++) {
      final height = 100.0 + random.nextDouble() * 300;
      _buildings.add(Rect.fromLTWH(
        i * 60.0,
        600 - height,
        50,
        height,
      ));
      _buildingColors.add(Color.fromARGB(
        255,
        150 + random.nextInt(105),
        150 + random.nextInt(105),
        200 + random.nextInt(55),
      ));
    }

    // Create parallax layers
    _parallaxLayers = List.generate(3, (index) {
      return List.generate(5, (i) {
        return Rect.fromLTWH(
          i * 200.0,
          400 + (index * 100),
          180,
          200 - (index * 50),
        );
      });
    });
  }

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    // Draw sky gradient
    final Rect skyRect = Rect.fromLTWH(0, 0, 800, 600);
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: _skyColors,
        stops: [0.0, 0.3, 0.6, 1.0],
      ).createShader(skyRect);
    canvas.drawRect(skyRect, paint);

    // Draw thunder effect occasionally
    if (math.Random().nextDouble() < 0.001) {
      canvas.drawColor(
        Colors.white.withOpacity(0.3),
        BlendMode.plus,  // Changed from plusLighter to plus
      );
    }

    // Draw parallax city layers
    for (int layer = 0; layer < _parallaxLayers.length; layer++) {
      final layerOffset = math.sin(_time * (1 + layer * 0.5)) * (10 - layer * 3);
      for (final rect in _parallaxLayers[layer]) {
        canvas.drawRect(
          rect.translate(layerOffset, 0),
          Paint()
            ..color = Colors.blue[900 - (layer * 200)]!.withOpacity(0.5),
        );
      }
    }

    // Draw buildings with neon effect
    for (int i = 0; i < _buildings.length; i++) {
      final buildingPaint = Paint()
        ..color = _buildingColors[i]
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 3);
      
      canvas.drawRect(_buildings[i], buildingPaint);
      
      // Draw windows
      final windowPaint = Paint()..color = Colors.yellow.withOpacity(0.8);
      for (int y = 0; y < 10; y++) {
        for (int x = 0; x < 3; x++) {
          if (math.Random().nextDouble() < 0.7) {
            canvas.drawRect(
              Rect.fromLTWH(
                _buildings[i].left + 10 + (x * 15),
                _buildings[i].top + 10 + (y * 30),
                10,
                20,
              ),
              windowPaint,
            );
          }
        }
      }
    }
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

    // Add snow particles
    for (int i = 0; i < 100; i++) {
      add(SnowParticle());
    }

    // Add chains for movement
    for (int i = 0; i < 5; i++) {
      add(ChainLink(Vector2(150 + i * 200, 0)));
    }

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

// Add new components for visual effects
class SnowParticle extends PositionComponent {
  final Paint _paint = Paint()..color = Colors.white.withOpacity(0.8);
  double _speed = 0;
  
  SnowParticle() : super(size: Vector2(3, 3)) {
    _speed = (math.Random().nextDouble() * 50) + 30;
    position = Vector2(
      math.Random().nextDouble() * 800,
      -10,
    );
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += _speed * dt;
    position.x += math.sin(position.y / 30) * 2 * dt;
    
    if (position.y > 800) {
      position.y = -10;
      position.x = math.Random().nextDouble() * 800;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), 2, _paint);
  }
}

// Update ChainLink to have game reference
class ChainLink extends PositionComponent with HasGameRef<MultiPlayerShooterGame> {
  final Paint _paint = Paint()
    ..color = Colors.amberAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  
  double swingAngle = 0;
  
  ChainLink(Vector2 position) : super(position: position, size: Vector2(30, 200));

  @override
  void update(double dt) {
    super.update(dt);
    swingAngle = math.sin(gameRef.currentTime * 2) * 0.3;  // Use gameRef instead of game
  }

  @override
  void render(Canvas canvas) {
    canvas.save();
    canvas.translate(size.x / 2, 0);
    canvas.rotate(swingAngle);
    
    for (int i = 0; i < 10; i++) {
      canvas.drawOval(
        Rect.fromLTWH(-8, i * 20, 16, 20),
        _paint,
      );
    }
    
    canvas.restore();
  }
}

extension on CameraComponent {
  set zoom(double zoom) {}
}
