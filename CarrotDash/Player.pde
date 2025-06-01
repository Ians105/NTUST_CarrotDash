class Player {
  float x, y, w, h;
  int spriteIndex = 0;
  boolean isAlive = true;

  // flip status
  boolean isFlipped = false;
  int flipStartTime = 0;
  int flipDuration = 5000;

  // invincibility status
  boolean isInvincible = false;
  int invincibleStartTime = 0;
  int invincibleDuration = 5000;

  // Grid tracking
  ArrayList<PVector> recentPositions = new ArrayList<PVector>();
  ArrayList<Integer> positionTimes = new ArrayList<Integer>();
  int maxRecentPositions = 10;
  boolean showGridIndicator = false;
  
  // Movement tracking - fix duplicate direction detection
  String lastMoveDirection = "";
  int lastMoveTime = 0;
  int moveBuffer = 100; // 100ms buffer to prevent accidental repeated moves

  Player() {
    w = 100;
    h = 100;
    
    if (grid != null) {
      // Calculate center position of playable area (in playable coordinate system)
      int centerRow = grid.playableRows / 2;  // 0-based in playable area
      int centerCol = grid.playableCols / 2;  // 0-based in playable area
      
      // Convert to absolute coordinates (add border offset)
      int absoluteRow = centerRow + 1;  // +1 because border occupies row 0
      int absoluteCol = centerCol + 1;  // +1 because border occupies column 0
      
      // Calculate pixel position
      x = grid.originX + absoluteCol * grid.cellSize;
      y = grid.originY + absoluteRow * grid.cellSize;
      
      println("=== Player Initialization ===");
      println("Playable area center: (" + centerRow + ", " + centerCol + ")");
      println("Absolute grid position: (" + absoluteRow + ", " + absoluteCol + ")");
      println("Pixel position: (" + x + ", " + y + ")");
      println("Grid origin: (" + grid.originX + ", " + grid.originY + ")");
      println("Cell size: " + grid.cellSize);
      println("=============================");
    } else {
      x = width/2 - w/2;
      y = height/2 - h/2;
    }
  }
  
  void snapToGrid() {
    if (grid == null) return;
    
    // Calculate current absolute grid position
    int absoluteGridCol = round((x - grid.originX) / grid.cellSize);
    int absoluteGridRow = round((y - grid.originY) / grid.cellSize);
    
    // Convert to playable area coordinates
    int playableGridCol = absoluteGridCol - 1;
    int playableGridRow = absoluteGridRow - 1;
    
    // Limit to playable area
    playableGridCol = constrain(playableGridCol, 0, grid.playableCols - 1);
    playableGridRow = constrain(playableGridRow, 0, grid.playableRows - 1);
    
    // Convert back to absolute coordinates
    absoluteGridCol = playableGridCol + 1;
    absoluteGridRow = playableGridRow + 1;
    
    // Set pixel position
    x = grid.originX + absoluteGridCol * grid.cellSize;
    y = grid.originY + absoluteGridRow * grid.cellSize;
  }

  void show() {
    if (playerSprites != null && spriteIndex < playerSprites.length && playerSprites[spriteIndex] != null) {
      // Add visual effects based on player status
      pushMatrix();
      translate(x + w/2, y + h/2);
      
      // Invincibility effect
      if (isInvincible) {
        tint(255, 255, 0, 150 + 105 * sin(frameCount * 0.3));
        scale(1.1 + sin(frameCount * 0.2) * 0.1);
      }
      
      // Flip effect
      if (isFlipped) {
        tint(255, 0, 255, 200);
        rotate(sin(frameCount * 0.1) * 0.1);
      }
      
      imageMode(CENTER);
      image(playerSprites[spriteIndex], 0, 0, w, h);
      noTint();
      popMatrix();
      
      // Show grid tracking effect
      if (showGridIndicator && recentPositions.size() > 1) {
        stroke(0, 255, 0, 150);
        strokeWeight(5);
        noFill();
        
        for (int i = 1; i < recentPositions.size(); i++) {
          PVector prev = recentPositions.get(i-1);
          PVector curr = recentPositions.get(i);
          float alpha = map(i, 0, recentPositions.size(), 50, 150);
          stroke(0, 255, 0, alpha);
          line(prev.x + w/2, prev.y + h/2, curr.x + w/2, curr.y + h/2);
        }
        noStroke();
      }
    } else {
      // Fallback display
      fill(255, 140, 0);
      ellipse(x + w/2, y + h/2, w, h);
    }
    
    // Update status effects
    updateStatusEffects();
  }

  void move(String direction) {
    if (!isAlive || grid == null) return;

    int currentTime = millis();
    if (currentTime - lastMoveTime < moveBuffer) {
      return;
    }

    // 檢查是否為重複方向移動
    boolean isRepeatedMove = direction.equals(lastMoveDirection) && currentTime - lastMoveTime > moveBuffer;

    if (showGridIndicator) {
      recentPositions.add(new PVector(x, y));
      positionTimes.add(currentTime);
      
      if (recentPositions.size() > maxRecentPositions) {
        recentPositions.remove(0);
        positionTimes.remove(0);
      }
    }

    // Apply flip effect
    String actualDirection = direction;
    if (isFlipped) {
      if (direction.equals("UP")) actualDirection = "DOWN";
      else if (direction.equals("DOWN")) actualDirection = "UP";
      else if (direction.equals("LEFT")) actualDirection = "RIGHT";
      else if (direction.equals("RIGHT")) actualDirection = "LEFT";
    }

    // Calculate current absolute grid position
    int currentAbsoluteGridCol = (int)((x - grid.originX) / grid.cellSize);
    int currentAbsoluteGridRow = (int)((y - grid.originY) / grid.cellSize);
    
    // Calculate new absolute grid position
    int newAbsoluteGridCol = currentAbsoluteGridCol;
    int newAbsoluteGridRow = currentAbsoluteGridRow;
    
    if (actualDirection.equals("UP")) {
      newAbsoluteGridRow--;
      spriteIndex = 1;
    } else if (actualDirection.equals("RIGHT")) {
      newAbsoluteGridCol++;
      spriteIndex = 2;
    } else if (actualDirection.equals("DOWN")) {
      newAbsoluteGridRow++;
      spriteIndex = 3;
    } else if (actualDirection.equals("LEFT")) {
      newAbsoluteGridCol--;
      spriteIndex = 4;
    }

    // Convert to playable area coordinates to check boundaries
    int newPlayableGridRow = newAbsoluteGridRow - 1;
    int newPlayableGridCol = newAbsoluteGridCol - 1;
    
    // Check if within playable area
    if (newPlayableGridRow >= 0 && newPlayableGridRow < grid.playableRows && 
        newPlayableGridCol >= 0 && newPlayableGridCol < grid.playableCols) {
      
      // Check if there's an active gopher at target position
      boolean hasActiveGopher = false;
      for (GridIndicator indicator : gridIndicators) {
        if (indicator.isActive && indicator.isAtPosition(newAbsoluteGridRow, newAbsoluteGridCol)) {
          hasActiveGopher = true;
          println("Blocked by active gopher at absolute (" + newAbsoluteGridRow + ", " + newAbsoluteGridCol + ")");
          break;
        }
      }
      
      if (!hasActiveGopher) {
        // Calculate new pixel position
        float newX = grid.originX + newAbsoluteGridCol * grid.cellSize;
        float newY = grid.originY + newAbsoluteGridRow * grid.cellSize;
        
        x = newX;
        y = newY;
        
        // 如果是重複方向移動，在下一格生成 gopher
        if (isRepeatedMove) {
          spawnGopherAtNextPosition(actualDirection, newAbsoluteGridRow, newAbsoluteGridCol);
        }
        
        lastMoveTime = currentTime;
        lastMoveDirection = direction;
        
        println("✓ Moved successfully to (" + newAbsoluteGridRow + ", " + newAbsoluteGridCol + ")");
      } else {
        println("✗ Movement blocked by active gopher");
      }
    } else {
      println("✗ Movement out of playable bounds");
    }
  }
  
  // 新增：在下一格位置生成 gopher
  void spawnGopherAtNextPosition(String direction, int currentRow, int currentCol) {
    int gopherRow = currentRow;
    int gopherCol = currentCol;
    
    // 計算 gopher 應該出現的位置（玩家移動方向的下一格）
    if (direction.equals("UP")) {
      gopherRow--;
    } else if (direction.equals("RIGHT")) {
      gopherCol++;
    } else if (direction.equals("DOWN")) {
      gopherRow++;
    } else if (direction.equals("LEFT")) {
      gopherCol--;
    }
    
    // 檢查 gopher 位置是否在可玩區域內
    int gopherPlayableRow = gopherRow - 1;
    int gopherPlayableCol = gopherCol - 1;
    
    if (gopherPlayableRow >= 0 && gopherPlayableRow < grid.playableRows && 
        gopherPlayableCol >= 0 && gopherPlayableCol < grid.playableCols) {
      
      // 尋找現有的 gopher 或創建新的
      GridIndicator targetGopher = null;
      for (GridIndicator indicator : gridIndicators) {
        if (indicator.isAtPosition(gopherRow, gopherCol)) {
          targetGopher = indicator;
          break;
        }
      }
      
      // 如果沒有現有的 gopher，創建新的
      if (targetGopher == null) {
        targetGopher = new GridIndicator(gopherRow, gopherCol);
        gridIndicators.add(targetGopher);
      }
      
      // 激活 gopher
      targetGopher.activate();
      println("Gopher spawned at next position (" + gopherRow + ", " + gopherCol + ") due to repeated move");
    } else {
      println("Cannot spawn gopher - next position out of bounds");
    }
  }

  void updateStatusEffects() {
    // Update flip status
    if (isFlipped && millis() - flipStartTime > flipDuration) {
      isFlipped = false;
      println("Flip effect ended");
    }
    
    // Update invincibility status
    if (isInvincible && millis() - invincibleStartTime > invincibleDuration) {
      isInvincible = false;
      println("Invincibility ended");
    }
    
    // Update grid indicator status
    if (showGridIndicator) {
      // Clean up old positions
      int currentTime = millis();
      for (int i = positionTimes.size() - 1; i >= 0; i--) {
        if (currentTime - positionTimes.get(i) > 5000) { // 5 seconds
          positionTimes.remove(i);
          if (i < recentPositions.size()) {
            recentPositions.remove(i);
          }
        }
      }
      
      // Turn off if no recent positions
      if (recentPositions.size() == 0) {
        showGridIndicator = false;
      }
    }
  }

  void activateFlip() {
    isFlipped = true;
    flipStartTime = millis();
    println("Flip activated for " + flipDuration + "ms");
  }

  void activateStar() {
    isInvincible = true;
    invincibleStartTime = millis();
    println("Invincibility activated for " + invincibleDuration + "ms");
  }

  void activateGridIndicator() {
    showGridIndicator = true;
    recentPositions.clear();
    positionTimes.clear();
    println("Grid indicator tracking activated");
  }

  void die() {
    if (!isInvincible) {
      isAlive = false;
      spriteIndex = 5; // defeated sprite
      println("Player died! Last direction: " + lastMoveDirection);
    } else {
      println("Death blocked by invincibility");
    }
  }

  // Helper method to get current playable grid position (0-based)
  PVector getCurrentGridPosition() {
    if (grid == null) return new PVector(-1, -1);
    
    // Calculate absolute position
    int absoluteGridCol = (int)((x - grid.originX) / grid.cellSize);
    int absoluteGridRow = (int)((y - grid.originY) / grid.cellSize);
    
    // Convert to playable area coordinates (subtract border offset)
    int playableGridCol = absoluteGridCol - 1;
    int playableGridRow = absoluteGridRow - 1;
    
    return new PVector(playableGridRow, playableGridCol);
  }
  
  // Helper method to get absolute grid position (including border)
  PVector getAbsoluteGridPosition() {
    if (grid == null) return new PVector(-1, -1);
    
    int gridCol = (int)((x - grid.originX) / grid.cellSize);
    int gridRow = (int)((y - grid.originY) / grid.cellSize);
    
    return new PVector(gridRow, gridCol);
  }
}
