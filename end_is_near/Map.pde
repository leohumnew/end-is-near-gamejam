public class Map {
    int[][] map;
    int[] upLoc, downLoc;
    private ArrayList<NPC> npcList;
    private ArrayList<Pickup> itemList;

    public Map (int[][] map, ArrayList<NPC> npcList, ArrayList<Pickup> itemList, int[] upLoc, int[] downLoc) {
        this.map = map;
        this.npcList = npcList;
        this.itemList = itemList;
        this.upLoc = upLoc;
        this.downLoc = downLoc;
    }

    public void updateNpcs() {
        for (int i = 0; i < npcList.size(); i++) {
            npcList.get(i).update();
        }
    }

    public void updateItems() {
        for (int i = 0; i < itemList.size(); i++) {
            itemList.get(i).update();
        }
    }

}
