class Item {
  float x, y, w, h;
  String type; // "flip", "star", "gridIndicator"
  PImage[] sprites;
  boolean collected = false;
  
  // Grid position tracking
  int gridRow, gridCol;
  
  // Animation variables
  int animFrame = 0;
  int lastAnimTime = 0;
  int animSpeed = 120;
  float bobbingOffset = 0;

  Item(float startX, float startY, String type) {
    this.type = type;
    this.w = 80;
    this.h = 80;
    
    // Align item position to nearest grid cell
    snapToGrid(startX, startY);
    
    // Load appropriate sprites
    loadSpritesForType(type);
  }
  
  // Create item using grid coordinates (limit to playable area)
  Item(int row, int col, String type) {
    this.type = type;
    this.w = 80;
    this.h = 80;
    this.gridRow = row;
    this.gridCol = col;
    
    if (grid != null) {
      // Ensure items only spawn in playable area (using absolute coordinates)
      // Playable area absolute coordinate range is [1, playableRows] and [1, playableCols]
      int playableRow = constrain(row, 0, grid.playableRows - 1); // 0 to playableRows-1
      int playableCol = constrain(col, 0, grid.playableCols - 1); // 0 to playableCols-1
      
      // Convert to absolute grid coordinates (add border offset)
      int absoluteRow = playableRow + 1; // 1 to playableRows
      int absoluteCol = playableCol + 1; // 1 to playableCols
      
      this.gridRow = absoluteRow;
      this.gridCol = absoluteCol;
      
      // Calculate actual pixel position
      x = grid.originX + gridCol * grid.cellSize + (grid.cellSize - w) / 2;
      y = grid.originY + gridRow * grid.cellSize + (grid.cellSize - h) / 2;
      
      println("Item " + type + " created at playable(" + playableRow + "," + playableCol + ") absolute(" + gridRow + "," + gridCol + ")");
    } else {
      x = col * 100 + 10;
      y = row * 100 + 10;
    }
    
    // Load appropriate sprites
    loadSpritesForType(type);
  }
  
  void snapToGrid(float posX, float posY) {
    if (grid == null) {
      x = posX;
      y = posY;
      return;
    }
    
    // Calculate nearest grid cell (limit to playable area)
    int nearestCol = round((posX - grid.originX) / grid.cellSize);
    int nearestRow = round((posY - grid.originY) / grid.cellSize);
    
    // Limit to playable area (absolute coordinates)
    nearestCol = constrain(nearestCol, 1, grid.playableCols);
    nearestRow = constrain(nearestRow, 1, grid.playableRows);
    
    // Set grid position
    gridCol = nearestCol;
    gridRow = nearestRow;
    
    // Calculate actual pixel position (cell center)
    x = grid.originX + gridCol * grid.cellSize + (grid.cellSize - w) / 2;
    y = grid.originY + gridRow * grid.cellSize + (grid.cellSize - h) / 2;
  }
  
  void loadSpritesForType(String itemType) {
    sprites = new PImage[3]; // Simplify to 3 frame animation
    
    if (itemType.equals("flip")) {
      // flip uses mushroom images
      sprites[0] = loadImage("data/poisonousMushroom.png");
      sprites[1] = loadImage("data/halfPoisonousMushroom.png");
      sprites[2] = loadImage("data/littlePoisonousMushroom.png");
    } else if (itemType.equals("star")) {
      // star uses scarecrow images
      sprites[0] = loadImage("data/scarecrowMain.PNG");
      sprites[1] = loadImage("data/scarecrowUp.PNG");
      sprites[2] = loadImage("data/scarecrowDown.PNG");
    }
    
    // Check if images loaded successfully
    for (int i = 0; i < sprites.length; i++) {
      if (sprites[i] == null) {
        sprites[i] = createImage(80, 80, RGB);
        sprites[i].loadPixels();
        for (int j = 0; j < sprites[i].pixels.length; j++) {
          sprites[i].pixels[j] = color(255, 100, 100); // Red fallback
        }
        sprites[i].updatePixels();
      }
    }
  }

  void update() {
    // 移除：浮動動畫 - 保持靜態位置
    // bobbingOffset = sin(frameCount * 0.08) * 8; 
    
    // 移除：旋轉動畫
    // rotationAngle += 0.03;
    
    // Frame animation - 保留圖片動畫切換
    if (millis() - lastAnimTime > animSpeed) {
      animFrame = (animFrame + 1) % sprites.length;
      lastAnimTime = millis();
    }
  }

  void show() {
    if (!collected && sprites != null && animFrame < sprites.length) {
      pushMatrix();
      translate(x + w/2, y + h/2); // 移除：+ bobbingOffset
      // 移除：rotate(rotationAngle * 0.5);
      
      // 移除：所有光暈效果
      /*
      if (type.equals("star")) {
        // star/scarecrow - golden glow (beneficial item)
        fill(255, 255, 0, 100 + 50 * sin(frameCount * 0.15));
        noStroke();
        ellipse(0, 0, w + 20, h + 20);
      } else if (type.equals("flip")) {
        // flip/mushroom - purple glow (harmful item)
        fill(255, 0, 255, 100 + 50 * sin(frameCount * 0.15));
        noStroke();
        ellipse(0, 0, w + 15, h + 15);
      }
      */
      
      // 移除：脈衝縮放效果
      // float pulseScale = 1.0 + sin(frameCount * 0.15) * 0.1;
      // scale(pulseScale);
      
      imageMode(CENTER);
      if (sprites[animFrame] != null) {
        image(sprites[animFrame], 0, 0, w, h);
      } else {
        // Fallback display
        fill(255, 140, 0);
        noStroke();
        ellipse(0, 0, w * 0.8, h * 0.8);
      }
      popMatrix();
      
      // Debug: show grid position (when 'd' key pressed)
      if (keyPressed && key == 'd') {
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(12);
        text("(" + gridRow + "," + gridCol + ")", x + w/2, y - 10);
        text(type, x + w/2, y + h + 15);
      }
    }
  }

  boolean touches(Player p) {
    return !collected && p.isAlive && 
           dist(x + w/2, y + h/2, p.x + p.w/2, p.y + p.h/2) < (w + p.w) * 0.4;
  }

  // Check if collides with enemy
  boolean touchesEnemy(Enemy enemy) {
    return !collected && 
           dist(x + w/2, y + h/2, enemy.x + enemy.w/2, enemy.y + enemy.h/2) < (w + enemy.w) * 0.4;
  }

  void applyEffect(Player player) {
    if (collected) return;
    
    collected = true;
    
    switch(type) {
      case "flip":
        // Mushroom: activate flip effect
        player.activateFlip();
        println("Player touched mushroom - Flip activated!");
        break;
        
      case "star":
        // Scarecrow: activate invincibility effect
        player.activateStar();
        println("Player touched scarecrow - Invincibility activated!");
        break;
    }
  }

  // Apply effect to enemy
  void applyEffectToEnemy(Enemy enemy) {
    if (collected) return;
    
    if (type.equals("flip")) {
      // Mushroom: reverse enemy movement direction
      enemy.reverseDirection();
      collected = true; // Mushroom is consumed
      println("Enemy touched mushroom - Direction reversed!");
    }
  }

  void collect() {
    collected = true;
  }
  
  // Check if item is in playable area
  boolean isInPlayableArea() {
    return grid.isPlayableCell(gridRow, gridCol);
  }
}
