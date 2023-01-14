import processing.javafx.*;

//Save variables
final String fileName = "saveInfo.txt";
String[] saveData = new String [1];

//Map
int mapWidth = 60, mapHeight = 40;
int map[][] = new int[mapWidth][mapHeight];
MapGenerator mapGenerator = new MapGenerator();
int tileSize = 128;
int visTilesX, visTilesY;

//Player variables
float posX = 20, posY = 20;

//SETTINGS FUNCTION -----------------
void settings() {
  loadSave();
  if (int(saveData[0])==1)fullScreen(FX2D);
  else size(1280, 720, FX2D);
}

void setup() {
  visTilesX = ceil(width/tileSize);
  visTilesY = ceil(height/tileSize);
  map = mapGenerator.mapGenerate(5, mapWidth, mapHeight);
  printMap();
}

void draw() {
  background(0);
  drawMap();
  //drawPlayer();
}

//DRAW FUNCTIONS --------------------
void drawMap() {
  for (int i = floor(posX)-visTilesX; i < floor(posX)+visTilesX; i++) {
    for (int j = floor(posY)-visTilesY; j < floor(posY)+visTilesY; j++) {
      if (i>=0 && i<mapWidth && j>=0 && j<mapHeight) {
        if (map[i][j]==1) {
          fill(255);
          rect(i*tileSize-posX*tileSize, j*tileSize-posY*tileSize, tileSize, tileSize);
        } else if (map[i][j]==2) {
          fill(255, 0, 0);
          rect(i*tileSize-posX*tileSize, j*tileSize-posY*tileSize, tileSize, tileSize);
        } else if (map[i][j]==3) {
          fill(0, 255, 0);
          rect(i*tileSize-posX*tileSize, j*tileSize-posY*tileSize, tileSize, tileSize);
        }
      }
    }
  }
}

//print 2d array to console with 0 as space and 1 as #
void printMap() {
  for (int i=0; i<mapWidth; i++) {
    for (int j=0; j<mapHeight; j++) {
      if (map[i][j]==0)print(" ");
      else if (map[i][j]==2)print("=");
      else if (map[i][j]==3)print("o");
      else print("#");
    }
    println();
  }
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
