public class NPC {
  boolean meelee, playerInRadius = false;
  int death = 0, randomSeed = int(random(14));
  float xPos, yPos;
  float npcSpeedX = 0.03, npcSpeedY = 0.03;

  public NPC (boolean meelee, int xPos, int yPos) {
    this.meelee = meelee;
    this.xPos = xPos;
    this.yPos = yPos;
  }

  void updatePos() {
    if (playerInRadius && dist(xPos, yPos, posX, posY) > 0.5) {
      if (xPos > posX && contains(new int[]{0,5}, getMapPos(floor(xPos-0.4-npcSpeedX),floor(yPos+0.45))) && !contains(new int[]{1,2}, getMapPos(floor(xPos-0.4-npcSpeedX),floor(yPos-0.2)))) xPos -= npcSpeedX;
      else if (xPos < posX && contains(new int[]{0,5}, getMapPos(floor(xPos+0.4+npcSpeedX),floor(yPos+0.45))) && !contains(new int[]{1,2}, getMapPos(floor(xPos+0.4+npcSpeedX),floor(yPos-0.2)))) xPos += npcSpeedX;
      if (yPos > posY && contains(new int[]{0,5}, getMapPos(floor(xPos+0.4),floor(yPos-npcSpeedY))) && contains(new int[]{0,5}, getMapPos(floor(xPos-0.4),floor(yPos-0.45-npcSpeedY)))) yPos -= npcSpeedY;
      else if (yPos < posY && contains(new int[]{0,5}, getMapPos(floor(xPos+0.4),floor(yPos+0.45+npcSpeedY))) && contains(new int[]{0,5}, getMapPos(floor(xPos-0.4),floor(yPos+npcSpeedY)))) yPos += npcSpeedY;
      if (xPos < 0) xPos = mapWidth-0.05;
      else if (xPos >= mapWidth) xPos = 0;
      if (yPos < 0) yPos = mapHeight-0.05;
      else if (yPos >= mapHeight) yPos = 0;
    }
    if (dist(xPos, yPos, posX, posY) < 1 && frameCount%16 == int(randomSeed)) {
      health -= 34;
      if (health <= 0) {
        health = 0;
        ending = 0;
        changeScene(-3);
      }
    }
  }

  public void drawNPC() {
    float x, y;
    if (death == 0) {
      checkPlayerInRadius();
      updatePos();
      x = xPos*tileSize-posX*tileSize+width/2-tileSize/2;
      y = yPos*tileSize-posY*tileSize+height/2-tileSize/2;
      if (meelee) {
          //draw meelee NPC
          if(frameCount%16 > 7)image(npcMeelee[0], x, y, tileSize, tileSize);
          else image(npcMeelee[1], x, y, tileSize, tileSize);
      } else {
          //draw ranged NPC
      }
    } else {
      x = xPos*tileSize-posX*tileSize+width/2-tileSize/2;
      y = yPos*tileSize-posY*tileSize+height/2-tileSize/2;
      if (millis()-death < 200) image(npcMeelee[2], x, y, tileSize, tileSize);
      else if (millis()-death < 600) image(npcMeelee[3], x, y, tileSize, tileSize);
      else npcList.remove(this);
    }
  }

  void checkPlayerInRadius() {
    if (dist(xPos, yPos, xPos, yPos) < 10) {
      playerInRadius = true;
    } else {
      playerInRadius = false;
    }
  }
}
