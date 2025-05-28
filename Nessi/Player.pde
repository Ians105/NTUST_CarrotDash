class Player {
  float x, y, w, h;
  int spriteIndex = 0;
  boolean isAlive = true;

  int lastMoveTime = 0;
  String lastMoveDirection = "";

  Player() {
    w = SPRITE_SIZE;
    h = SPRITE_SIZE;
    x = width/2 - w/2;
    y = height/2 - h/2;
  }

  void show() {
    // After 0.5 seconds and isAlive, return to the default sprite.
    if (isAlive && millis() - lastMoveTime > 500) {
      spriteIndex = 0;
    }

    image(playerSprites[spriteIndex], x, y);
  }

  void move(String direction, Grid grid) {
    if (!isAlive) return;

    float newX = x, newY = y;

    if (direction.equals("UP")) {
      newY -= SPEED;
    } else if (direction.equals("RIGHT")) {
      newX += SPEED;
    } else if (direction.equals("DOWN")) {
      newY += SPEED;
    } else if (direction.equals("LEFT")) {
      newX -= SPEED;
    }

    // Check bounds using the Grid object
    boolean withinBounds =
      newX >= grid.leftBound() &&
      newX + w <= grid.rightBound() &&
      newY >= grid.topBound() &&
      newY + h <= grid.bottomBound();

    if (!withinBounds) {
      // If move is out-of-bounds, ignore it entirely
      return;
    }

    boolean repeatedDirection = direction.equals(lastMoveDirection);
    if (repeatedDirection) {
      die();
      return;
    }

    // Safe to move
    x = newX;
    y = newY;

    if (direction.equals("UP")) spriteIndex = 1;
    if (direction.equals("RIGHT")) spriteIndex = 2;
    if (direction.equals("DOWN")) spriteIndex = 3;
    if (direction.equals("LEFT")) spriteIndex = 4;

    lastMoveTime = millis();
    lastMoveDirection = direction;
  }

  void die() {
    isAlive = false;
    spriteIndex = 5;
    image(playerSprites[spriteIndex], x, y);
  }
}
