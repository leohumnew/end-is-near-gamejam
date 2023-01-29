public class Map {
    int[][] map;
    private ArrayList<NPC> npcList;
    private ArrayList<Pickup> itemList;

    public Map (int[][] map, ArrayList<NPC> npcList, ArrayList<Pickup> itemList) {
        this.map = map;
        this.npcList = npcList;
        this.itemList = itemList;
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
