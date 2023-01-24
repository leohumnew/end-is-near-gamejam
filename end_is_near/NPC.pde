public class NPC {
  boolean meelee, playerInRadius = false;
  int death = 0, randomSeed = int(random(14));
  float xPos, yPos, npcSpeedX, npcSpeedY;
  final float SPEED_X = random(1.2, 2), SPEED_Y = random(1.2, 2);
  float x, y;

  public NPC (boolean meelee, int xPos, int yPos) {
    this.meelee = meelee;
    this.xPos = xPos;
    this.yPos = yPos;
  }

  void updatePos() {
    if (playerInRadius && dist(xPos, yPos, posX, posY) > 0.05*randomSeed) {
      npcSpeedX = SPEED_X/frameRate;
      npcSpeedY = SPEED_Y/frameRate;
      if (isPlayerRight()) {
        if (contains(WALKABLE, getMapPos(xPos+0.4+npcSpeedX, yPos+0.45)) && !contains(new int[]{1,2}, getMapPos(xPos+0.4+npcSpeedX, yPos-0.3))) xPos += npcSpeedX;
      } else {
        if (contains(WALKABLE, getMapPos(xPos-0.4-npcSpeedX, yPos+0.45)) && !contains(new int[]{1,2}, getMapPos(xPos-0.4-npcSpeedX, yPos-0.3))) xPos -= npcSpeedX;
      }
      if (isPlayerBelow()) {
        if (contains(WALKABLE, getMapPos(xPos+0.4, yPos+0.45+npcSpeedY)) && contains(WALKABLE, getMapPos(xPos-0.4, yPos+0.45+npcSpeedY))) yPos += npcSpeedY;
      } else {
        if (contains(WALKABLE, getMapPos(xPos+0.4, yPos-npcSpeedY)) && contains(WALKABLE, getMapPos(xPos-0.4, yPos-npcSpeedY))) yPos -= npcSpeedY;
      }

      if (xPos < 0) xPos = mapWidth-0.05;
      else if (xPos >= mapWidth) xPos = 0;
      if (yPos < 0) yPos = mapHeight-0.05;
      else if (yPos >= mapHeight) yPos = 0;
    }
    if (dist(xPos, yPos, posX, posY) < 1 && frameCount%16 == int(randomSeed)) {
      health -= 34;
      vignetteCounter = millis();
      if (health <= 0) {
        health = 0;
        ending = 0;
        changeScene(-3);
      }
    }
  }

  boolean isPlayerRight() {
    if (((xPos < posX) ? mapWidth+xPos : xPos) - posX > posX - ((xPos > posX) ? xPos-mapWidth : xPos)) return true;
    return false;
  }
  boolean isPlayerBelow() {
    if (((yPos < posY) ? mapHeight+yPos : yPos) - posY > posY - ((yPos > posY) ? yPos-mapHeight : yPos)) return true;
    return false;
  }

  public void drawNPC() {
    if (abs(xPos+mapWidth-posX) < abs(xPos-posX)) x = tileSize*(xPos+mapWidth-posX) + width/2 - tileSize/2;
    else if (abs(xPos-mapWidth-posX) < abs(xPos-posX)) x = tileSize*(xPos-mapWidth-posX) + width/2 - tileSize/2;
    else x = tileSize*(xPos-posX) + width/2 - tileSize/2;

    if (abs(yPos+mapHeight-posY) < abs(yPos-posY)) y = tileSize*(yPos+mapHeight-posY) + height/2 - tileSize/2;
    else if (abs(yPos-mapHeight-posY) < abs(yPos-posY)) y = tileSize*(yPos-mapHeight-posY) + height/2 - tileSize/2;
    else y = tileSize*(yPos-posY) + height/2 - tileSize/2;

    if (x < -tileSize || x > width || y < -tileSize || y > height) return;

    if (death == 0) {
      checkPlayerInRadius();
      updatePos();
      if (meelee) {
          if(frameCount%16 > 7)image(npcMeelee[0], x, y);
          else image(npcMeelee[1], x, y);
      }
    } else {
      if (millis()-death < 150) image(npcMeelee[2], x, y);
      else if (millis()-death < 400) image(npcMeelee[3], x, y);
      else npcList.remove(this);
    }
  }

  void checkPlayerInRadius() {
    playerInRadius = (dist(xPos, yPos, xPos, yPos) < 8) ? true : false;
  }
}
