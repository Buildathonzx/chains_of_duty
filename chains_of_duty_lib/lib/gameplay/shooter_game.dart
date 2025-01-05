import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';  // Add this import
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
    swingAngle = math.sin(gameRef.currentTime() * 2) * 0.3;  // Use gameRef instead of game
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

// New ParkourPlayer class
class ParkourPlayer extends SpriteComponent with HasGameRef<FlameGame> {
  static const double JUMP_VELOCITY = -400.0;
  static const double MOVE_SPEED = 200.0;
  
  Vector2 velocity = Vector2.zero();
  bool isOnGround = false;
  bool isSwinging = false;
  ChainLink? attachedChain;

  ParkourPlayer() : super(size: Vector2(50, 80)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    // Yellow character
    paint = Paint()..color = Colors.amber;
    // Add hitbox for collisions
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if (!isSwinging) {
      // Apply gravity
      velocity.y += 800 * dt;
      
      // Move
      position += velocity * dt;
      
      // Basic platform collision
      for (final platform in parent!.children.whereType<Platform>()) {
        if (_checkCollision(platform)) {
          if (velocity.y > 0) {
            position.y = platform.position.y - size.y / 2;
            velocity.y = 0;
            isOnGround = true;
          }
        }
      }
    } else if (attachedChain != null) {
      // Swing physics
      final chainCenter = attachedChain!.position + Vector2(0, attachedChain!.size.y / 2);
      final toPlayer = position - chainCenter;
      toPlayer.normalize();
      
      position = chainCenter + toPlayer * 200;
      velocity = toPlayer.scaled(300);
    }
  }

  bool _checkCollision(Platform platform) {
    return position.y + size.y/2 > platform.position.y &&
           position.y - size.y/2 < platform.position.y + platform.size.y &&
           position.x + size.x/2 > platform.position.x &&
           position.x - size.x/2 < platform.position.x + platform.size.x;
  }
}

// New Villain class
class Villain extends SpriteComponent with HasGameRef<FlameGame> {
  Vector2 velocity = Vector2.zero();
  List<Vector2> pathPoints = [];
  int currentPathIndex = 0;
  int level;

  Villain(this.level) : super(size: Vector2(50, 80)) {
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    paint = Paint()..color = Colors.red;
    // Add more complex behavior based on level
    switch (level) {
      case 1:
        _setupBasicPath();
        break;
      case 2:
        _setupAdvancedPath();
        break;
      default:
        _setupRandomPath();
    }
  }

  void _setupBasicPath() {
    // Simple left-right movement
    pathPoints = [
      Vector2(100, 300),
      Vector2(700, 300),
    ];
  }

  void _setupAdvancedPath() {
    // More complex movement pattern
    pathPoints = [
      Vector2(100, 300),
      Vector2(400, 200),
      Vector2(700, 300),
      Vector2(400, 400),
    ];
  }

  void _setupRandomPath() {
    // Random movement pattern
    final random = math.Random();
    pathPoints = List.generate(5, (i) {
      return Vector2(
        random.nextDouble() * 700 + 50,
        random.nextDouble() * 300 + 100,
      );
    });
  }

  @override
  void update(double dt) {
    // Move towards current path point
    final target = pathPoints[currentPathIndex];
    final toTarget = target - position;
    
    if (toTarget.length < 10) {
      currentPathIndex = (currentPathIndex + 1) % pathPoints.length;
    } else {
      position += toTarget.normalized() * 150 * dt;
    }

    // Add level-specific behavior
    switch (level) {
      case 2:
        _throwObstacle();
        break;
      case 3:
        _teleportRandomly();
        break;
    }
  }

  void _throwObstacle() {
    if (math.Random().nextDouble() < 0.02) {
      gameRef.add(Obstacle(position.clone()));
    }
  }

  void _teleportRandomly() {
    if (math.Random().nextDouble() < 0.01) {
      position = Vector2(
        math.Random().nextDouble() * 700 + 50,
        math.Random().nextDouble() * 300 + 100,
      );
    }
  }
}

// New Platform class
class Platform extends PositionComponent {
  Platform(Vector2 position, Vector2 size) : super(position: position, size: size);

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = Colors.grey[800]!,
    );
  }
}

// New Obstacle class
class Obstacle extends PositionComponent {
  Vector2 velocity;
  
  Obstacle(Vector2 position) 
      : velocity = Vector2(math.Random().nextDouble() * 200 - 100, -200),
        super(position: position, size: Vector2(20, 20));

  @override
  void update(double dt) {
    velocity.y += 400 * dt;  // Gravity
    position += velocity * dt;
    
    if (position.y > 800) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
      Offset(size.x / 2, size.y / 2),
      10,
      Paint()..color = Colors.redAccent,
    );
  }
}

// Enhanced MultiPlayerShooterGame with new mechanics
class MultiPlayerShooterGame extends FlameGame with HasCollisionDetection {
  late ParkourPlayer player;
  late Villain villain;
  final List<Platform> platforms = [];
  int currentLevel = 1;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    
    // Add enhanced city scenery
    add(CityScenery());

    // Add platforms with varying heights
    _generatePlatforms();

    // Add chains for swinging
    _addSwingingChains();

    // Add player and villain
    player = ParkourPlayer()..position = Vector2(100, 500);
    villain = Villain(currentLevel)..position = Vector2(700, 300);
    
    addAll([player, villain]);

    // Add visual effects
    add(WeatherSystem());
  }

  void _generatePlatforms() {
    // Generate platforms of varying heights and sizes
    final random = math.Random();
    
    for (int i = 0; i < 10; i++) {
      final platform = Platform(
        Vector2(i * 100.0, 300 + random.nextDouble() * 200),
        Vector2(80, 20),
      );
      platforms.add(platform);
      add(platform);
    }

    // Add some floating platforms
    for (int i = 0; i < 5; i++) {
      final platform = Platform(
        Vector2(random.nextDouble() * 700, 200 + random.nextDouble() * 200),
        Vector2(60, 15),
      );
      platforms.add(platform);
      add(platform);
    }
  }

  void _addSwingingChains() {
    for (int i = 0; i < 5; i++) {
      add(ChainLink(Vector2(150 + i * 200, 0)));
    }
  }

  void nextLevel() {
    currentLevel++;
    // Remove existing villain
    villain.removeFromParent();
    // Add new villain with increased difficulty
    villain = Villain(currentLevel)..position = Vector2(700, 300);
    add(villain);
    // Regenerate platforms in new configuration
    _regeneratePlatforms();
  }

  void _regeneratePlatforms() {
    // Remove existing platforms
    for (final platform in platforms) {
      platform.removeFromParent();
    }
    platforms.clear();
    // Generate new platforms
    _generatePlatforms();
  }
}

// New WeatherSystem class
class WeatherSystem extends Component {
  @override
  void update(double dt) {
    // Add weather effects based on game progress
  }
}
