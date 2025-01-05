import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';

class GameInputController with KeyboardEventListener {
  bool leftPressed = false;
  bool rightPressed = false;
  bool jumpPressed = false;
  bool swingPressed = false;

  @override
  bool onKeyEvent(KeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    leftPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft) || 
                 keysPressed.contains(LogicalKeyboardKey.keyA);
    rightPressed = keysPressed.contains(LogicalKeyboardKey.arrowRight) || 
                  keysPressed.contains(LogicalKeyboardKey.keyD);
    jumpPressed = keysPressed.contains(LogicalKeyboardKey.space) || 
                 keysPressed.contains(LogicalKeyboardKey.arrowUp);
    swingPressed = keysPressed.contains(LogicalKeyboardKey.keyE);

    return true;
  }
}

mixin KeyboardEventListener {
}

// Example of setting sprite in a new SpriteComponent
class SomeNewSpriteComponent extends SpriteComponent with HasGameRef<FlameGame> {
  // ...existing properties...

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    sprite = await gameRef.images.load('assets/images/some_new_image.png'); // Ensure correct path
  }

  // ...existing methods...
}
