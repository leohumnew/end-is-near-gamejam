public class Pickup {
  int x, y, item;

  public Pickup (int x, int y, int item) {
      this.x = x;
      this.y = y;
      this.item = item;
  }

  public void update() {
      checkPickup();
      if(item >= 0)image(items[item], x*tileSize-posX*tileSize+width/2, y*tileSize-posY*tileSize+height/2);
  }

  void checkPickup() {
    if (dist(x, y, posX, posY) < 1) {
      if (item >= 0) {
        if (item == 0) inventory[2] = 0;
        else if (item == 3) health += 34;
        itemGet.play();
        maps[level].itemList.remove(this);
      } else if (item == -1) {
        if (inventory[2] == 0) changeScene(4);
        else {
          banner(textUI[1]);
        }
      } else if (item == -2) {
        banner(textUI[10]);
      } else if (item == -3) {
        banner(textUI[11]);
      }
    }
  }
}
