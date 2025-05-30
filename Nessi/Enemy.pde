class Enemy {
  float x, y, w, h;
  int direction = 1;  // 1 = right, -1 = left
  String type;        // "default" or "ghost"
  PImage sprite;

  Enemy(float startX, float startY, String type) {
    this.x = startX;
    this.y = startY;
    this.type = type;
    this.w = 100;
    this.h = 100;
    this.sprite = loadImage("assets/enemy_" + type + ".png");
  }

  void update() {
    x += direction * 2;  // Adjust speed as needed

    if (type.equals("default")) {
      // Reverse direction at screen edges (example logic)
      if (x <= 100 || x >= width - 200) {
        direction *= -1;
      }
    }

    if (type.equals("ghost")) {
      // Teleport to opposite side if out of bounds
      if (x < -w || x > width) {
        x = (x < 0) ? width : 0 - w;
        direction *= -1;
      }
    }
  }

  void show() {
    imageMode(CORNER);
    image(sprite, x, y, w, h);
  }

  boolean touches(Player p) {
    return p.isAlive && dist(x + w/2, y + h/2, p.x + p.w/2, p.y + p.h/2) < w * 0.8;
  }
}
