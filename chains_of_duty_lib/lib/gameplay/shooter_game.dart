import 'dart:math' as math;
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';  // Add this import
import 'package:flutter/material.dart';
import 'package:flame/camera.dart';  // Add this import
import 'package:flame/extensions.dart';
import 'package:chains_of_duty_lib/style/characters.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';  // Add this import

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
class PlayerSquare extends SpriteComponent with HasGameRef<FlameGame> {
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
    final image = await gameRef.images.load('assets/images/player.png'); // Updated path
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

// Corrected EnemySquare to properly initialize sprite
class EnemySquare extends SpriteComponent with HasGameRef<FlameGame> {
  static const _speed = 100.0;
  final Vector2 direction;

  EnemySquare({
    required Vector2 position,
    required this.direction,
  }) : super(position: position, size: Vector2.all(48), anchor: Anchor.center);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    final image = await gameRef.images.load('assets/images/enemy.png'); // Corrected path
    sprite = Sprite(image);
  }

  @override
  void update(double dt) { // Fix method signature
    super.update(dt);
    position += direction * _speed * dt;
  }
}

class ShooterGame extends FlameGame {
  ShooterGame() : super(world: ShooterWorld());

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // camera.zoom = 1.0; // Removed the invalid zoom setter
  }
}

// Enhanced CityScenery with vibrant colors and parallax effect
class CityScenery extends Component {
  final List<Rect> _buildings = [];
  final List<Color> _buildingColors = [];
  late List<List<Rect>> _parallaxLayers;
  late List<Color> _skyColors;
  double _time = 0;

  // Added scroll speed for buildings
  final double _buildingsScrollSpeed = 50.0; // pixels per second

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

    // Move buildings leftward
    for (int i = 0; i < _buildings.length; i++) {
      _buildings[i] = _buildings[i].translate(-_buildingsScrollSpeed * dt, 0);
      // Reset position if building moves out of screen
      if (_buildings[i].right < 0) {
        _buildings[i] = Rect.fromLTWH(
          800, // Assuming screen width is 800
          _buildings[i].top,
          _buildings[i].width,
          _buildings[i].height,
        );
      }
    }

    // Move parallax layers leftward
    for (int layer = 0; layer < _parallaxLayers.length; layer++) {
      for (int i = 0; i < _parallaxLayers[layer].length; i++) {
        _parallaxLayers[layer][i] = _parallaxLayers[layer][i].translate(-_buildingsScrollSpeed * dt * (layer + 1) * 0.5, 0);
        // Reset position if layer moves out of screen
        if (_parallaxLayers[layer][i].right < 0) {
          _parallaxLayers[layer][i] = Rect.fromLTWH(
            800, // Assuming screen width is 800
            _parallaxLayers[layer][i].top,
            _parallaxLayers[layer][i].width,
            _parallaxLayers[layer][i].height,
          );
        }
      }
    }
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

    // Draw parallax city layers with movement
    for (int layer = 0; layer < _parallaxLayers.length; layer++) {
      for (final rect in _parallaxLayers[layer]) {
        canvas.drawRect(
          rect,
          Paint()
            ..color = Colors.blue[900 - (layer * 200)]!.withOpacity(0.5),
        );
      }
    }

    // Draw buildings with neon effect and movement
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
class Weapon extends SpriteComponent with HasGameRef<FlameGame> {
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
    final image = await gameRef.images.load('assets/images/weapon.png'); // Updated path
    sprite = Sprite(image);
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

// Corrected OpponentSquare to properly initialize sprite
class OpponentSquare extends SpriteComponent with HasGameRef<FlameGame> {
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
    final image = await gameRef.images.load('assets/images/enemy.png'); // Corrected path
    sprite = Sprite(image);
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
class MultiPlayerShooterGame extends FlameGame with KeyboardEvents, HasCollisionDetection {
  late ParkourPlayer player;
  late Villain villain;
  final List<Platform> platforms = [];
  int currentLevel = 1;
  bool isPaused = false;
  Vector2 cameraOffset = Vector2.zero();
  double parallaxEffect = 0;

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

    // Set up camera viewport instead of using zoom setter
    camera.viewport = FixedResolutionViewport(
      resolution: Vector2(800, 600),
    );
    
    // Make the camera follow the player without worldBounds
    camera.follow(player);
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      super.update(dt);
      
      // Update camera position with parallax effect
      final targetX = player.position.x - size.x / 2;
      cameraOffset.x = targetX;
      parallaxEffect = (targetX / size.x) * 100;
      
      // Update chain swinging using game time
      final gameTime = dt * 1000; // Convert to milliseconds
      children.whereType<ChainLink>().forEach((chain) {
        chain.swingAngle = math.sin(gameTime * 0.002) * 0.3 + (parallaxEffect * 0.001);
      });

      // Clamp camera position within world bounds
      camera.viewfinder.position.clamp(
        Vector2(0, 0),
        Vector2(2000, 2000),
      );

      // Remove manual camera positioning
      // camera.moveTo(Vector2(
      //   player.position.x - size.x / 2,
      //   player.position.y - size.y / 2
      // ));
    }
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (!isPaused) {
      final isKeyDown = event is RawKeyDownEvent;

      // Handle player movement
      if (keysPressed.contains(const LogicalKeyboardKey(0x00070050))) { // Left arrow
        player.velocity.x = -ParkourPlayer.MOVE_SPEED;
      } else if (keysPressed.contains(const LogicalKeyboardKey(0x0700004F))) { // Right arrow
        player.velocity.x = ParkourPlayer.MOVE_SPEED;
      } else {
        player.velocity.x = 0;
      }

      // Handle jumping
      if (isKeyDown && keysPressed.contains(const LogicalKeyboardKey(0x00070044)) && player.isOnGround) { // Space
        player.velocity.y = ParkourPlayer.JUMP_VELOCITY;
        player.isOnGround = false;
      }

      // Handle chain swinging
      if (isKeyDown && keysPressed.contains(const LogicalKeyboardKey(0x00070014))) { // E key
        _tryAttachToNearestChain();
      }
    }

    return KeyEventResult.handled;
  }

  void togglePause() {
    isPaused = !isPaused;
    if (isPaused) {
      overlays.add('PauseMenu');
    } else {
      overlays.remove('PauseMenu');
    }
  }

  void _tryAttachToNearestChain() {
    if (player.isSwinging) {
      player.isSwinging = false;
      player.attachedChain = null;
      return;
    }

    // Find nearest chain
    ChainLink? nearestChain;
    double nearestDistance = double.infinity;

    children.whereType<ChainLink>().forEach((chain) {
      final distance = chain.position.distanceTo(player.position);
      if (distance < 100 && distance < nearestDistance) { // Adjust range as needed
        nearestChain = chain;
        nearestDistance = distance;
      }
    });

    if (nearestChain != null) {
      player.attachedChain = nearestChain;
      player.isSwinging = true;
    }
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

// FiringDetector for handling weapon firing
class FiringDetector extends Component with HasGameRef<FlameGame> {
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
class ChainLink extends PositionComponent with HasGameRef<FlameGame> {
  final Paint _paint = Paint()
    ..color = Colors.amberAccent
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;
  
  double swingAngle = 0;
  double _time = 0; // Added time tracking
  
  ChainLink(Vector2 position) : super(position: position, size: Vector2(30, 200));

  @override
  void update(double dt) {
    super.update(dt);
    _time += dt;
    swingAngle = math.sin(_time * 2) * 0.3; // Updated swing calculation
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
} // Added missing closing brace for ChainLink

// Corrected ParkourPlayer to properly initialize sprite
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
    await super.onLoad();
    final image = await gameRef.images.load('assets/images/player.png'); // Ensure player image exists
    sprite = Sprite(image);
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

// Corrected Villain to properly initialize sprite
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
    await super.onLoad();
    final imagePath = 'assets/images/villain.png'; // Ensure villain image exists
    final image = await gameRef.images.load(imagePath);
    sprite = Sprite(image);
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

// New WeatherSystem class
class WeatherSystem extends Component {
  @override
  void update(double dt) {
    // Add weather effects based on game progress
  }
}
