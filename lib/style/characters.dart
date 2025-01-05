abstract class BaseCharacter {
  int health;
  double xPos, yPos;

  BaseCharacter({required this.health, required this.xPos, required this.yPos});

  void move(double dx, double dy) {
    xPos += dx;
    yPos += dy;
  }

  bool isAlive() => health > 0;
}

class PlayerCharacter extends BaseCharacter {
  PlayerCharacter({super.health = 100, super.xPos = 0, super.yPos = 0});

  void shoot() {
    // Implement shooting logic
  }
}

class EnemyCharacter extends BaseCharacter {
  EnemyCharacter({super.health = 50, super.xPos = 0, super.yPos = 0});
}
