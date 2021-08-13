// Size of cells
int cellSize = 8;

// How likely for a cell to be alive at start (in percentage)
float probabilityOfAliveAtStart = 18;

// Variables for timer
int interval = 0;
int lastRecordedTime = 0;

int cantColores = 360;

// Colors for active/inactive cells
color bgColor = color(0);
color alive = color(255,255,255);
color dead = bgColor;

int totalYElements = 1;
int totalXElements = 1;


// Array of cells
cell[][] cells; 
// Buffer to record the state of the cells and use this while changing the others in the interations
cell[][] cellsBuffer; 

// Pause
boolean pause = false;

class cell{
  int alive = 0;
  int intervalsAlive = 0;
  
  cell(int alive){
    this.alive = alive;
  }
  
  void incrementInterval(){
    this.intervalsAlive ++;
  }
 
 void kill(){
   this.alive = 0;
 }
 
 boolean isAlive(){
   return alive == 1;
 }
 
 void makeAlive(){
   if(!this.isAlive()){
     this.alive = 1;
     this.intervalsAlive ++;
   }
 }
  
  color getColor(){
    color miColor = color(intervalsAlive % cantColores, 100, 100);
    return miColor;
  }
  
  
}

void setup() {
  //  size (640, 360);
  fullScreen();
  colorMode(HSB, cantColores, 100, 100);
  frameRate(60);
  // Instantiate arrays 

  totalYElements = height/cellSize;
  totalXElements = width/cellSize;
  
  cells = new cell[totalXElements][totalYElements];
  cellsBuffer = new cell[totalXElements][totalYElements];

  // This stroke will draw the background grid
  //stroke(1);

  noSmooth();

  // Initialization of cells
  for (int x=0; x<totalXElements; x++) {
    for (int y=0; y<totalYElements; y++) {
      float state = random (100);
      if (state > probabilityOfAliveAtStart) { 
        state = 0;
      }
      else {
        state = 1;
      }
      
      int auxState = int(state);
      cells[x][y] = new cell(auxState); // Save state of each cell
    }
  }
  background(0); // Fill in black in case cells don't cover all the windows
}


void draw() {

  //Draw grid
  
  for (int x=0; x<totalXElements; x++) {
    for (int y=0; y<totalYElements; y++) {
        fill(cells[x][y].getColor()); // If alive
        rect (x*cellSize, y*cellSize, cellSize, cellSize);
    }
  }
  // Iterate if timer ticks
  if (millis()-lastRecordedTime>interval) {
    if (!pause) {
      iteration();
      lastRecordedTime = millis();
    }
  }

  // Create  new cells manually 
  if (mousePressed | pause) {
    // Map and avoid out of bound errors
    int xCellOver = int(map(mouseX, 0, width, 0, totalXElements));
    xCellOver = constrain(xCellOver, 0, totalXElements-1);
    int yCellOver = int(map(mouseY, 0, height, 0, totalYElements));
    yCellOver = constrain(yCellOver, 0, totalYElements-1);

    // Check against cells in buffer
    if (cellsBuffer[xCellOver][yCellOver].alive == 1) { // Cell is alive
      cells[xCellOver][yCellOver].kill(); // Kill
      fill(dead); // Fill with kill color
    }
    else { // Cell is dead
      cells[xCellOver][yCellOver].makeAlive(); // Make alive
      fill(cells[xCellOver][yCellOver].getColor()); // Fill alive color
    }
  } 
  else if (pause && !mousePressed) { // And then save to buffer once mouse goes up
    // Save cells to buffer (so we opeate with one array keeping the other intact)
    for (int x=0; x<totalXElements; x++) {
      for (int y=0; y<totalYElements; y++) {
        cellsBuffer[x][y] = cells[x][y];
      }
    }
  }
}



void iteration() { // When the clock ticks
  // Save cells to buffer (so we opeate with one array keeping the other intact)
  for (int x=0; x<totalXElements; x++) {
    for (int y=0; y<totalYElements; y++) {
      cellsBuffer[x][y] = cells[x][y];
    }
  }

  // Visit each cell:
  for (int x=0; x<totalXElements; x++) {
    for (int y=0; y<totalYElements; y++) {
      // And visit all the neighbours of each cell
      int neighbours = 0; // We'll count the neighbours
      for (int xx=x-1; xx<=x+1;xx++) {
        for (int yy=y-1; yy<=y+1;yy++) {  
            if (!((xx==x)&&(yy==y))) { // Make sure to to check against self
              if (cellsBuffer[(xx + totalXElements) % totalXElements][(yy + totalYElements) % totalYElements].isAlive()){
                neighbours ++; // Check alive neighbours and count them
            } // End of if
          } // End of if
        } // End of yy loop
      } //End of xx loop
      // We've checked the neigbours: apply rules!
      if (cellsBuffer[x][y].isAlive()) { // The cell is alive: kill it if necessary
        if (neighbours < 2 || neighbours > 3) {
          cells[x][y].kill(); // Die unless it has 2 or 3 neighbours
        }else{
          cells[x][y].incrementInterval();
        }
      } 
      else { // The cell is dead: make it live if necessary      
        if (neighbours == 3 ) {
          cells[x][y].makeAlive(); // Only if it has 3 neighbours
        }
      } // End of if
    } // End of y loop
  } // End of x loop
} // End of function

void keyPressed() {
  if (key=='r' || key == 'R') {
    // Restart: reinitialization of cells
    for (int x=0; x<totalXElements; x++) {
      for (int y=0; y<totalYElements; y++) {
        float state = random (100);
        if (state > probabilityOfAliveAtStart) {
          state = 0;
        }
        else {
          state = 1;
        }
        cells[x][y].alive = int(state); // Save state of each cell
      }
    }
  }
  if (key==' ') { // On/off of pause
    pause = !pause;
  }
  if (key=='c' || key == 'C') { // Clear all
    for (int x=0; x<totalXElements; x++) {
      for (int y=0; y<totalYElements; y++) {
        cells[x][y].kill(); // Save all to zero
      }
    }
  }
}
