class Grid {
  int rows, cols;
  int playableRows, playableCols; // Player movable range
  int cellSize;
  int offset = 50;
  float originX, originY;
  PImage gridImage;

  Grid() {
    // Set game grid size (player movable range)
    if (level == 1) {
      playableRows = 3;
      playableCols = 3;
      gridImage = loadImage("data/3x3 Grid.png");
    } else if (level == 2) {
      playableRows = 4;
      playableCols = 4;
      gridImage = loadImage("data/4x4 Grid.png");
    } else if (level == 3) {
      playableRows = 5;
      playableCols = 5;
      gridImage = loadImage("data/5x5 Grid.png");
    } else {
      // Default fallback
      playableRows = 3;
      playableCols = 3;
      gridImage = loadImage("data/3x3 Grid.png");
    }

    // Expand grid range, extend outward by one ring for placing gridIndicator
    rows = playableRows + 2; // Add one row top and bottom
    cols = playableCols + 2; // Add one column left and right

    // Dynamically calculate grid size to fit screen and maintain reasonable proportions
    calculateOptimalGridSize();
  }
  
  void calculateOptimalGridSize() {
    // Calculate available screen space (leave UI and border space)
    float availableWidth = width - 400;  // Leave left-right borders and UI space
    float availableHeight = height - 200; // Leave top-bottom borders
    
    // Calculate most suitable cell size based on expanded grid dimensions
    float maxCellWidth = availableWidth / cols;
    float maxCellHeight = availableHeight / rows;
    
    // Take smaller value to ensure grid is square and doesn't exceed screen
    cellSize = (int)min(maxCellWidth, maxCellHeight);
    
    // Set reasonable cell size range
    cellSize = constrain(cellSize, 60, 100);
    
    // Calculate grid start position (center display, but slightly right to avoid UI)
    float totalGridWidth = cols * cellSize;
    float totalGridHeight = rows * cellSize;
    
    originX = (width - totalGridWidth) / 2 + 50; // Slightly right to avoid left UI
    originY = (height - totalGridHeight) / 2;
    
    // Ensure grid doesn't get too close to edges
    originX = max(originX, 150); // Leave more space on left for UI
    originY = max(originY, 50);
    originX = min(originX, width - totalGridWidth - 50);
    originY = min(originY, height - totalGridHeight - 50);
  }

  void show() {
    if (gridImage != null) {
      // Calculate playable area size (excluding outer ring)
      float playableGridWidth = playableCols * cellSize;
      float playableGridHeight = playableRows * cellSize;
      
      // Calculate playable area start position (excluding outer ring)
      float playableOriginX = originX + cellSize; // Skip left gridIndicator column
      float playableOriginY = originY + cellSize; // Skip top gridIndicator row
      
      // Show game grid image, only display playable area
      imageMode(CORNER);
      image(gridImage, playableOriginX, playableOriginY, playableGridWidth, playableGridHeight);
      
      // Add beautiful border around playable area
      stroke(255, 220);
      strokeWeight(3);
      noFill();
      rectMode(CORNER);
      rect(playableOriginX - 3, playableOriginY - 3, playableGridWidth + 6, playableGridHeight + 6);
      
      // Optional: add semi-transparent grid lines to help player identify cells (only in playable area)
      stroke(255, 80);
      strokeWeight(1);
      
      // Vertical grid lines
      for (int c = 1; c < playableCols; c++) {
        float x = playableOriginX + c * cellSize;
        line(x, playableOriginY, x, playableOriginY + playableGridHeight);
      }
      
      // Horizontal grid lines
      for (int r = 1; r < playableRows; r++) {
        float y = playableOriginY + r * cellSize;
        line(playableOriginX, y, playableOriginX + playableGridWidth, y);
      }
      
      // Debug: show grid row-column labels
      if (keyPressed && key == 'd') {
        showDebugGrid();
      }
      
    } else {
      // Fallback: if image loading failed, draw grid lines
      rectMode(CORNER);
      stroke(255);
      strokeWeight(2);
      noFill();
      
      // Only draw playable area grid lines
      for (int r = 1; r <= playableRows; r++) {
        for (int c = 1; c <= playableCols; c++) {
          float x = originX + c * cellSize;
          float y = originY + r * cellSize;
          rect(x, y, cellSize, cellSize);
        }
      }
      
      // Add label showing this is fallback display
      fill(255, 100);
      textAlign(CENTER, CENTER);
      textSize(16);
      text("Grid Image Not Found", originX + (cols * cellSize)/2, originY + (rows * cellSize)/2);
    }
  }

  // Check if playable cell (keep only one definition)
  boolean isPlayableCell(int row, int col) {
    return row >= 1 && row <= playableRows && 
           col >= 1 && col <= playableCols;
  }

  // Check if gridIndicator position
  boolean isGridIndicatorCell(int row, int col) {
    // Check if on grid border
    boolean isOnBorder = (row == 0 || row == rows - 1 || col == 0 || col == cols - 1);
    boolean isValidPosition = (row >= 0 && row < rows && col >= 0 && col < cols);
    
    return isOnBorder && isValidPosition;
  }

  // Debug: show grid coordinates
  void showDebugGrid() {
    fill(255, 200);
    textAlign(CENTER, CENTER);
    textSize(10);
    
    // Show all cell coordinates
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        float cellCenterX = originX + c * cellSize + cellSize/2;
        float cellCenterY = originY + r * cellSize + cellSize/2;
        
        // Distinguish playable area and gridIndicator area
        if (isPlayableCell(r, c)) {
          // Playable area - white background
          fill(255, 255, 255, 100);
          noStroke();
          rectMode(CENTER);
          rect(cellCenterX, cellCenterY, cellSize-2, cellSize-2);
          
          // Show absolute coordinates
          fill(0, 0, 0, 200);
          textSize(10);
          text("(" + r + "," + c + ")", cellCenterX, cellCenterY - 8);
          
          // Show playable area relative coordinates
          int playableRow = r - 1;
          int playableCol = c - 1;
          fill(0, 150, 0, 200);
          text("[" + playableRow + "," + playableCol + "]", cellCenterX, cellCenterY + 8);
        } else if (isGridIndicatorCell(r, c)) {
          // gridIndicator area - cyan background
          fill(0, 255, 255, 100);
          noStroke();
          rectMode(CENTER);
          rect(cellCenterX, cellCenterY, cellSize-2, cellSize-2);
          
          fill(0, 0, 0, 200);
          textSize(10);
          text("GI(" + r + "," + c + ")", cellCenterX, cellCenterY);
        } else {
          // Other areas - gray background
          fill(128, 128, 128, 50);
          noStroke();
          rectMode(CENTER);
          rect(cellCenterX, cellCenterY, cellSize-2, cellSize-2);
          
          fill(128, 128, 128, 200);
          textSize(8);
          text("(" + r + "," + c + ")", cellCenterX, cellCenterY);
        }
      }
    }
    
    // Show GridIndicator actual positions
    for (GridIndicator indicator : gridIndicators) {
      fill(255, 0, 0);
      textAlign(CENTER, CENTER);
      textSize(8);
      text("REAL", indicator.x + indicator.w/2, indicator.y + indicator.h + 15);
      
      // Draw actual GridIndicator boundaries
      stroke(255, 0, 0);
      strokeWeight(1);
      noFill();
      rectMode(CORNER);
      rect(indicator.x, indicator.y, indicator.w, indicator.h);
    }
    noStroke();
    
    // Show player current position
    if (p != null) {
      PVector playerPlayablePos = p.getCurrentGridPosition();
      PVector playerAbsPos = p.getAbsoluteGridPosition();
      
      // Highlight player position
      float playerCellX = originX + (int)playerAbsPos.y * cellSize + cellSize/2;
      float playerCellY = originY + (int)playerAbsPos.x * cellSize + cellSize/2;
      
      fill(255, 0, 0, 150);
      noStroke();
      rectMode(CENTER);
      rect(playerCellX, playerCellY, cellSize-4, cellSize-4);
      
      // Show detailed information
      fill(255, 0, 0);
      textAlign(LEFT, TOP);
      textSize(14);
      text("=== Player Position ===", 10, height - 200);
      text("Playable: (" + (int)playerPlayablePos.x + ", " + (int)playerPlayablePos.y + ")", 10, height - 180);
      text("Absolute: (" + (int)playerAbsPos.x + ", " + (int)playerAbsPos.y + ")", 10, height - 160);
      text("Pixel: (" + (int)p.x + ", " + (int)p.y + ")", 10, height - 140);
      text("Grid: " + cols + "x" + rows + " (Play: " + playableCols + "x" + playableRows + ")", 10, height - 120);
      text("Cell Size: " + cellSize, 10, height - 100);
      text("Origin: (" + (int)originX + ", " + (int)originY + ")", 10, height - 80);
      text("GridIndicators: " + gridIndicators.size(), 10, height - 60);
    }
  }

  // Modify boundary methods, return playable area boundaries (absolute coordinates)
  float leftBound() {
    return originX + cellSize; // Skip left gridIndicator column
  }

  float rightBound() {
    return originX + (cols - 1) * cellSize; // Exclude right gridIndicator column
  }

  float topBound() {
    return originY + cellSize; // Skip top gridIndicator row
  }

  float bottomBound() {
    return originY + (rows - 1) * cellSize; // Exclude bottom gridIndicator row
  }
  
  // New methods: get extended grid boundaries (including gridIndicator area)
  float fullLeftBound() {
    return originX;
  }

  float fullRightBound() {
    return originX + cols * cellSize;
  }

  float fullTopBound() {
    return originY;
  }

  float fullBottomBound() {
    return originY + rows * cellSize;
  }
  
  // Helper method to get grid cell coordinates
  PVector getGridCell(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      return new PVector(originX + col * cellSize, originY + row * cellSize);
    }
    return null;
  }
  
  // Helper method to snap position to grid
  PVector snapToGrid(float x, float y) {
    int col = (int)((x - originX) / cellSize);
    int row = (int)((y - originY) / cellSize);
    col = constrain(col, 1, cols - 2); // Limit to playable area
    row = constrain(row, 1, rows - 2);
    return new PVector(originX + col * cellSize, originY + row * cellSize);
  }
  
  // Debug: show grid information
  void showDebugInfo() {
    fill(255);
    textAlign(LEFT, TOP);
    textSize(16);
    text("Grid Info:", 10, height - 140);
    text("Total Size: " + cols + "x" + rows, 10, height - 120);
    text("Playable: " + playableCols + "x" + playableRows, 10, height - 100);
    text("Cell Size: " + cellSize, 10, height - 80);
    text("Origin: (" + (int)originX + ", " + (int)originY + ")", 10, height - 60);
    text("Playable Bounds: " + (int)leftBound() + " to " + (int)rightBound(), 10, height - 40);
  }

  // New method: get grid cell center position
  PVector getGridCellCenter(int row, int col) {
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      float centerX = originX + col * cellSize + cellSize / 2;
      float centerY = originY + row * cellSize + cellSize / 2;
      return new PVector(centerX, centerY);
    }
    return null;
  }

  // New method: check which grid cell position belongs to
  PVector getGridPosition(float x, float y) {
    int col = (int)((x - originX) / cellSize);
    int row = (int)((y - originY) / cellSize);
    
    if (row >= 0 && row < rows && col >= 0 && col < cols) {
      return new PVector(row, col);
    }
    return null;
  }

  // New method: check if grid cell is within boundaries
  boolean isValidGridPosition(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }
}
