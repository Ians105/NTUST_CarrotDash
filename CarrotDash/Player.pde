class Player {
  float x, y, w, h;
  int spriteIndex = 0;
  boolean isAlive=true;

  // flip status
  boolean isFlipped = false;
  int flipStartTime = 0;
  int flipDuration = 5000;

  // stat status
  boolean isInvincible = false;
  int invincibleStartTime = 0;
  int invincibleDuration = 5000;

  int lastGridX = -1;
  int lastGridY = -1;

  int lastMoveTime = 0;
  String lastMoveDirection = "";

  Player() {
    w = 100;
    h = 100;
    x = width/2 - w/2;
    y = height/2 - h/2;
  }

  void show() {
    // After 0.5 seconds and isAlive, return to the default sprite.
    if (isAlive && millis() - lastMoveTime > 500) {
      spriteIndex = 0;
    }

    // Debug mode
    //circle(x, y, w);

    // hint on last move location
    fill(255, 255, 255, 100);
    noStroke();
    if (lastGridX != -1 && lastGridY != -1) {
      rect(lastGridX, lastGridY, w, h);
    }

    image(playerSprites[spriteIndex], x, y);

    // check if the potion and flip is ended
    if (isFlipped && millis() - flipStartTime > flipDuration) {
      isFlipped = false;
    }
    if (isInvincible && millis() - invincibleStartTime > invincibleDuration) {
      isInvincible = false;
    }
  }

  void move(String direction) {
    if (!isAlive) return;

    if (isFlipped) {
      if (direction.equals("UP")) direction = "DOWN";
      else if (direction.equals("DOWN")) direction = "UP";
      else if (direction.equals("LEFT")) direction = "RIGHT";
      else if (direction.equals("RIGHT")) direction = "LEFT";
    }

    boolean repeatedDirection = direction.equals(lastMoveDirection);

    if (repeatedDirection /*|| touchedEnemy*/) {
      die();
      return;
    }

    if (direction.equals("UP")) {
      y -= SPEED;
      spriteIndex = 1;
    }
    if (direction.equals("RIGHT")) {
      x += SPEED;
      spriteIndex = 2;
    }
    if (direction.equals("DOWN")) {
      y += SPEED;
      spriteIndex = 3;
    }
    if (direction.equals("LEFT")) {
      x -= SPEED;
      spriteIndex = 4;
    }

    lastMoveTime = millis();
    lastMoveDirection = direction;
  }

  void die() {
    isAlive = false;
    spriteIndex = 5;
  }

  void activateFlip() {
    isFlipped = true;
    flipStartTime = millis();
  }

  void activateStar() {
    isInvincible = true;
    invincibleStartTime = millis();
  }
}
