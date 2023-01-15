//import processing.javafx.*;

//Save variables
final String fileName = "saveInfo.txt";
String[] saveData = new String [1];

//Map
int mapWidth = 60, mapHeight = 40;
int map[][] = new int[mapWidth][mapHeight];
MapGenerator mapGenerator = new MapGenerator();
int tileSize = 64;
int visTilesX, visTilesY;

//Images
PImage stalagmite;
PImage[] player = new PImage[3];
PImage[] topWall = new PImage[2];
PImage[] ground = new PImage[3];
PImage[] wall = new PImage[3];
PImage[] topWallSide = new PImage[2];

//Player variables
float posX = 20, posY = 20, speedX = 0, speedY = 0;

//SETTINGS FUNCTION -----------------
void settings() {
  loadSave();
  if (int(saveData[0])==1)fullScreen(P2D);
  else size(1280, 720, P2D);
}

void setup() {
  ((PGraphicsOpenGL)g).textureSampling(2);
  visTilesX = ceil(width/tileSize);
  visTilesY = ceil(height/tileSize);
  map = mapGenerator.mapGenerate(5, mapWidth, mapHeight);

  //load images
  ground[0] = loadImage("Suelo0_0.png");
  ground[1] = loadImage("Suelo0_1.png");
  ground[2] = loadImage("Suelo0_2.png");
  wall[0] = loadImage("Pared0_0.png");
  wall[1] = loadImage("Pared0_1.png");
  wall[2] = loadImage("Pared0_2.png");
  topWall[0] = loadImage("Pared0_4.png");
  topWall[1] = loadImage("Pared0_5.png");
  topWallSide[0] = loadImage("Pared0_6.png");
  topWallSide[1] = loadImage("Pared0_7.png");
  stalagmite = loadImage("Estalagmita0.png");
  player[0] = loadImage("Char1.png");
  player[1] = loadImage("Char2.png");
  player[2] = loadImage("Char3.png");
}

void draw() {
  background(0);
  drawMap();
  drawPlayer();
  move();
}

//MAP FUNCTIONS ------------------
int getMapPos(int x, int y) {
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  return map[x][y];
}
void setMapPos(int x, int y, int value) {
  if (x < 0) x = mapWidth+x;
  else if (x >= mapWidth) x = x-mapWidth;
  if (y < 0) y = mapHeight+y;
  else if (y >= mapHeight) y = y-mapHeight;
  map[x][y] = value;
}

//PLAYER FUNCTIONS ------------------
void move() {
  //collision
  if (speedX > 0 && getMapPos(floor(posX+0.4+speedX),floor(posY+0.45)) == 0 && (getMapPos(floor(posX+0.4+speedX),floor(posY)) == 0 || getMapPos(floor(posX+0.4+speedX),floor(posY)) == 2 || getMapPos(floor(posX+0.4+speedX),floor(posY)) == 4)) posX += speedX;
  else if (speedX < 0 && getMapPos(floor(posX-0.4+speedX),floor(posY+0.45)) == 0 && (getMapPos(floor(posX-0.4+speedX),floor(posY)) == 0 || getMapPos(floor(posX-0.4+speedX),floor(posY)) == 2 || getMapPos(floor(posX-0.4+speedX),floor(posY)) == 4)) posX += speedX;
  if (speedY > 0 && getMapPos(floor(posX+0.4),floor(posY+0.45+speedY)) == 0 && getMapPos(floor(posX-0.4),floor(posY+0.45+speedY)) == 0) posY += speedY;
  else if (speedY < 0 && getMapPos(floor(posX+0.4),floor(posY+speedY)) == 0 && getMapPos(floor(posX-0.4),floor(posY+speedY)) == 0) posY += speedY;
  if (posX < 0) posX = mapWidth-0.05;
  else if (posX >= mapWidth) posX = 0;
  if (posY < 0) posY = mapHeight-0.05;
  else if (posY >= mapHeight) posY = 0;
}
void keyPressed() {
  if (key == 'w' || key == 'W' || keyCode == UP) {
    speedY = -0.1;
  } else if (key == 's' || key == 'S' || keyCode == DOWN) {
    speedY = 0.1;
  } else if (key == 'a' || key == 'A' || keyCode == LEFT) {
    speedX = -0.1;
  } else if (key == 'd' || key == 'D' || keyCode == RIGHT) {
    speedX = 0.1;
  // dig
  } else if (key == 'e') {
    if (speedX > 0) {
      setMapPos(floor(posX+1), floor(posY+0.4), 0);
      setMapPos(floor(posX+1), floor(posY-0.4), 0);
      if (getMapPos(floor(posX+1), floor(posY-0.4)-1) == 1) {
        if (getMapPos(floor(posX+1), floor(posY-0.4)-2) == 1) setMapPos(floor(posX+1), floor(posY-0.4)-1, 2);
        else setMapPos(floor(posX+1), floor(posY-0.4)-1, 4);
      }
      if (getMapPos(floor(posX+1), floor(posY+0.4)+1) == 2) setMapPos(floor(posX+1), floor(posY+0.4)+1, 4);
    } else if (speedX < 0) {
      setMapPos(floor(posX-1), floor(posY+0.4), 0);
      setMapPos(floor(posX-1), floor(posY-0.4), 0);
      if (getMapPos(floor(posX-1), floor(posY-0.4)-1) == 1) {
        if (getMapPos(floor(posX-1), floor(posY-0.4)-2) == 1) setMapPos(floor(posX-1), floor(posY-0.4)-1, 2);
        else setMapPos(floor(posX-1), floor(posY-0.4)-1, 4);
      }
      if (getMapPos(floor(posX-1), floor(posY+0.4)+1) == 2) setMapPos(floor(posX-1), floor(posY+0.4)+1, 4);
    } else if (speedY > 0) {
      setMapPos(floor(posX+0.4), floor(posY+1), 0);
      if (getMapPos(floor(posX+0.4), floor(posY+1)+1) == 1 && (getMapPos(floor(posX+0.4), floor(posY+1)+2) != 1 && getMapPos(floor(posX+0.4), floor(posY+1)+2) != 2)) setMapPos(floor(posX+0.4), floor(posY+1)+1, 4);
      else if (getMapPos(floor(posX+0.4), floor(posY+1)+1) == 2) setMapPos(floor(posX+0.4), floor(posY+1)+1, 4);
      setMapPos(floor(posX-0.4), floor(posY+1), 0);
      if (getMapPos(floor(posX-0.4), floor(posY+1)+1) == 1 && (getMapPos(floor(posX-0.4), floor(posY+1)+2) != 1 && getMapPos(floor(posX-0.4), floor(posY+1)+2) != 2)) setMapPos(floor(posX-0.4), floor(posY+1)+1, 4);
      else if (getMapPos(floor(posX-0.4), floor(posY+1)+1) == 2) setMapPos(floor(posX-0.4), floor(posY+1)+1, 4);
    } else if (speedY < 0) {
      setMapPos(floor(posX+0.4), floor(posY-1), 0);
      setMapPos(floor(posX-0.4), floor(posY-1), 0);
      if (getMapPos(floor(posX+0.4), floor(posY-1)-1) == 1) {
        if (getMapPos(floor(posX+0.4), floor(posY-1)-2) == 1) setMapPos(floor(posX+0.4), floor(posY-1)-1, 2);
        else setMapPos(floor(posX+0.4), floor(posY-1)-1, 4);
      }
      if (getMapPos(floor(posX-0.4), floor(posY-1)-1) == 1) {
        if (getMapPos(floor(posX-0.4), floor(posY-1)-2) == 1) setMapPos(floor(posX-0.4), floor(posY-1)-1, 2);
        else setMapPos(floor(posX-0.4), floor(posY-1)-1, 4);
      }
    }
  }
}
void keyReleased() {
  if (key == 'w' || key == 'W' || keyCode == UP || key == 's' || key == 'S' || keyCode == DOWN) {
    speedY = 0;
  } else if (key == 'a' || key == 'A' || keyCode == LEFT || key == 'd' || key == 'D' || keyCode == RIGHT) {
    speedX = 0;
  }
}

void drawPlayer() {
  if (speedX == 0 && speedY == 0) {
    image(player[0], width/2-tileSize/2, height/2-tileSize/2, tileSize, tileSize);
  } else {
    if (frameCount%10 < 5) image(player[1], width/2-tileSize/2, height/2-tileSize/2, tileSize, tileSize);
    else image(player[2], width/2-tileSize/2, height/2-tileSize/2, tileSize, tileSize);
  }
}

//DRAW FUNCTIONS --------------------
float tilePosX, tilePosY;
int jOriginal, iOriginal;
void drawMap() {
  for (int i = floor(posX)-visTilesX; i < floor(posX)+visTilesX; i++) {
    for (int j = floor(posY)-visTilesY; j < floor(posY)+visTilesY; j++) {
      tilePosX = i*tileSize-posX*tileSize+width/2;
      tilePosY = j*tileSize-posY*tileSize+height/2;
      iOriginal = i;
      jOriginal = j;
      if (i < 0) i = mapWidth+i;
      else if (i >= mapWidth) i = i-mapWidth;
      if (j < 0) j = mapHeight+j;
      else if (j >= mapHeight) j = j-mapHeight;

      if (map[i][j]==1 && (getMapPos(i+1,j) != 1 || getMapPos(i,j+1) != 1 || getMapPos(i-1,j) != 1 || getMapPos(i,j-1) != 1 || getMapPos(i+1,j+1) != 1 || getMapPos(i-1,j-1) != 1 || getMapPos(i+1,j-1) != 1 || getMapPos(i-1,j+1) != 1)) {
        image(wall[floor(posSeed(3, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==2) {
        image(topWall[floor(posSeed(2, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==3) {
        image(stalagmite, tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==4) {
        image(topWallSide[floor(posSeed(2, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      } else if (map[i][j]==0) {
        image(ground[floor(posSeed(3, i+j))], tilePosX, tilePosY, tileSize, tileSize);
      }
      
      i = iOriginal;
      j = jOriginal;
    }
  }
}

int posSeed(int num, int pos) {
  return pos % num;
}

//SAVE INFO -------------------------
void createSave() {
  saveData[0] = "1";
}

void loadSave() {
  if (dataFile(fileName).isFile()) {
    saveData=loadStrings(dataPath(fileName));
  } else {
    createSave();
    saveSave();
  }
}

void saveSave() {
  saveStrings(dataPath(fileName), saveData);
}
