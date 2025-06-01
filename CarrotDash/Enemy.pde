class Enemy {
  float x, y, w, h;
  float velocityX; // Only need horizontal movement speed
  String type;        // "pest", "bird"
  PImage[] sprites;   // Store multiple animation frames
  float speed;
  
  // Animation variables
  int animFrame = 0;
  int lastAnimTime = 0;
  int animSpeed = 200; // milliseconds per frame

  Enemy(float startX, float startY, String type) {
    this.type = type;
    this.w = 100;
    this.h = 100;
    
    // Load sprites based on type
    loadSpritesForType(type);
    
    // Set different speeds for different enemy types - 大幅加速動畫
    if (type.equals("pest")) {
      speed = 2.0;
      animSpeed = 120; // 減少：300 → 120
    }
    else if (type.equals("bird")) {
      speed = 1.5;
      animSpeed = 80;  // 減少：150 → 80
    }
    else {
      speed = 1.5; // default
      animSpeed = 100; // 減少：250 → 100
    }
    
    // 修正：只在垂直方向置中到格子，水平位置保持原始
    if (grid != null) {
      // 水平位置：保持原始 startX
      this.x = startX;
      
      // 垂直位置：對齊到最接近的格子中心
      int spawnRow = round((startY - grid.originY) / grid.cellSize);
      spawnRow = constrain(spawnRow, 1, grid.playableRows); // 限制在可玩區域的行
      
      // 計算垂直置中位置
      this.y = grid.originY + spawnRow * grid.cellSize + (grid.cellSize - h) / 2;
      
      println("Enemy " + type + " vertically aligned to grid - Row: " + spawnRow);
      println("  Original spawn: (" + startX + ", " + startY + ")");
      println("  Final position: (" + this.x + ", " + this.y + ")");
    } else {
      // 如果沒有網格，使用原始位置
      this.x = startX;
      this.y = startY;
    }
    
    // Determine movement direction based on spawn position
    setMovementDirection(startX);
    
    println("Enemy " + type + " created at (" + x + ", " + y + ") velocityX: " + velocityX);
  }
  
  void setMovementDirection(float originalStartX) {
    if (grid == null) {
      // If no grid, default to moving right
      velocityX = speed;
      return;
    }
    
    // Calculate grid center position
    float gridCenterX = grid.originX + (grid.cols * grid.cellSize) / 2;
    
    // 使用原始生成位置來判斷方向
    if (originalStartX < gridCenterX) {
      // Spawn from left, move right
      velocityX = speed;
      println("Enemy spawned on LEFT, moving RIGHT with velocity: " + velocityX);
    } else {
      // Spawn from right, move left
      velocityX = -speed;
      println("Enemy spawned on RIGHT, moving LEFT with velocity: " + velocityX);
    }
  }

  // New: reverse movement direction
  void reverseDirection() {
    velocityX = -velocityX;
    println("Enemy " + type + " direction reversed! New velocityX: " + velocityX);
  }
  
  void loadSpritesForType(String enemyType) {
    if (enemyType.equals("pest")) {
      sprites = new PImage[3];
      sprites[0] = loadImage("data/pest1.PNG");
      sprites[1] = loadImage("data/pest2.PNG");
      sprites[2] = loadImage("data/pest3.PNG");
    }
    else if (enemyType.equals("bird")) {
      sprites = new PImage[4];
      sprites[0] = loadImage("data/bird1.png");
      sprites[1] = loadImage("data/bird2.png");
      sprites[2] = loadImage("data/bird3.png");
      sprites[3] = loadImage("data/bird4.png");
    }
    else {
      // Default sprite
      sprites = new PImage[1];
      sprites[0] = loadImage("data/pest1.PNG");
    }
    
    // Check if images loaded successfully
    for (int i = 0; i < sprites.length; i++) {
      if (sprites[i] == null) {
        sprites[i] = createImage(100, 100, RGB);
        sprites[i].loadPixels();
        for (int j = 0; j < sprites[i].pixels.length; j++) {
          sprites[i].pixels[j] = color(255, 0, 0); // Red fallback
        }
        sprites[i].updatePixels();
      }
    }
  }

  void update() {
    // Update animation
    if (millis() - lastAnimTime > animSpeed) {
      animFrame = (animFrame + 1) % sprites.length;
      lastAnimTime = millis();
    }
    
    // Movement logic based on enemy type - 恢復原來的移動方式
    if (type.equals("pest")) {
      // pest simple horizontal linear movement
      x += velocityX;
    } else if (type.equals("bird")) {
      // bird special teleport logic
      updateBirdMovement();
    } else {
      // Default movement
      x += velocityX;
    }
  }
  
  // 修改：Bird 移動邏輯（保持原來的傳送但垂直置中）
  void updateBirdMovement() {
    if (grid == null) {
      x += velocityX;
      return;
    }
    
    // Calculate Grid boundaries
    float gridLeft = grid.originX;
    float gridRight = grid.originX + grid.cols * grid.cellSize;
    
    // Check if hitting Grid boundaries and handle teleportation
    if (velocityX > 0) {
      // Moving right, check if hitting left boundary
      if (x + w >= gridLeft && x <= gridLeft) {
        // Teleport to inside Grid on right side - 但保持水平連續位置
        x = gridRight - w - 20; // 在右側邊界內側一點
        velocityX = -speed; // Change to moving left
        println("Bird teleported to RIGHT side, now moving LEFT");
      } else {
        // Normal movement
        x += velocityX;
      }
    } else if (velocityX < 0) {
      // Moving left, check if hitting right boundary  
      if (x <= gridRight && x + w >= gridRight) {
        // Teleport to inside Grid on left side - 但保持水平連續位置
        x = gridLeft + 20; // 在左側邊界內側一點
        velocityX = speed; // Change to moving right
        println("Bird teleported to LEFT side, now moving RIGHT");
      } else {
        // Normal movement
        x += velocityX;
      }
    }
  }

  void show() {
    pushMatrix();
    translate(x + w/2, y + h/2);
    
    // Fix image flip logic
    if (type.equals("pest")) {
      // pest flip logic
      if (velocityX > 0) {
        scale(-1, 1); // Flip when moving right
      }
    } else if (type.equals("bird")) {
      // bird flip logic
      if (velocityX < 0) {
        scale(-1, 1); // Flip when moving left
      }
    }
    
    // Add visual effects based on type
    if (type.equals("bird")) {
      // Bird has slight transparency and floating effect
      tint(255, 230);
      // Slight up-down floating
      translate(0, sin(frameCount * 0.1) * 5);
    } else if (type.equals("pest")) {
      // pest keep fully opaque
      noTint();
    } else {
      noTint();
    }
    
    imageMode(CENTER);
    if (sprites != null && animFrame < sprites.length && sprites[animFrame] != null) {
      image(sprites[animFrame], 0, 0, w, h);
    } else {
      // Fallback display
      if (type.equals("pest")) {
        fill(255, 0, 0); // pest red
      } else if (type.equals("bird")) {
        fill(0, 0, 255); // bird blue
      } else {
        fill(255, 0, 0); // default red
      }
      ellipse(0, 0, w, h);
    }
    
    noTint();
    popMatrix();
    
    // Debug: show enemy position
    if (keyPressed && key == 'd') {
      fill(255, 255, 0);
      textAlign(CENTER, CENTER);
      textSize(10);
      
      // 計算當前垂直格子位置
      int currentRow = round((y + h/2 - grid.originY) / grid.cellSize);
      
      text(type + " (" + (int)x + "," + (int)y + ") Row:" + currentRow, x + w/2, y - 15);
      text("vX:" + velocityX, x + w/2, y - 5);
    }
  }

  boolean touches(Player p) {
    // Collision detection
    return p.isAlive && dist(x + w/2, y + h/2, p.x + p.w/2, p.y + p.h/2) < (w + p.w) * 0.4;
  }
  
  boolean isOffScreen() {
    if (type.equals("bird")) {
      // bird won't truly leave screen because it teleports
      return false;
    }
    
    // pest allow moving off map, only remove when completely off screen
    return x < -200 || x > width + 200;
  }
  
  // 新增：取得當前垂直格子位置
  PVector getCurrentGridPosition() {
    if (grid == null) return new PVector(-1, -1);
    
    float centerY = y + h/2;
    int gridRow = round((centerY - grid.originY) / grid.cellSize);
    
    return new PVector(gridRow, x); // 返回行和實際X位置
  }
}
