public class Pickup {
  int x, y, item;

  public Pickup (int x, int y, int item) {
      this.x = x;
      this.y = y;
      this.item = item;
  }

  public void update() {
      checkPickup();
      if(item >= 0)image(items[item], x*tileSize-posX*tileSize+width/2, y*tileSize-posY*tileSize+height/2, tileSize, tileSize);
  }

  void checkPickup() {
    if (dist(x, y, posX, posY) < 0.8) {
      if (item >= 0) {
        inventory[0] = 0;
        itemList.remove(this);
      } else {
        teleport(4);
      }
    }
  }
}
