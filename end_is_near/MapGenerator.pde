public class MapGenerator {
  //Already generated rooms + function to check if room overlaps with any old rooms
  ArrayList<int[]> rooms = new ArrayList<int[]>();
  ArrayList<NPC> npcs = new ArrayList<NPC>();
  int[][] map;

  // create array of 2d arrays of ints to store room templates
  final int[][][] roomTemplates =
  {
    {
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,6,1,1},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,6,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,3,3,3,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0}
    },
    {
      {2,0,0,0,0,0,0,0,0,0},
      {2,0,0,0,0,0,0,0,0,0},
      {2,0,0,0,1,1,2,0,0,0},
      {2,0,0,0,1,1,2,0,0,0},
      {2,0,0,0,1,1,2,0,0,0},
      {2,0,0,0,0,6,0,0,0,0},
      {2,0,0,0,0,6,0,0,0,0},
      {2,0,0,0,1,1,2,0,0,0},
      {2,0,0,0,1,1,2,0,6,0},
      {2,0,0,0,1,1,2,0,0,0},
      {2,0,0,0,0,0,0,0,0,0},
      {2,0,0,0,0,0,0,0,0,0}
    },
    {
      {2,0,0,0,0,0},
      {2,0,3,0,0,0},
      {2,0,0,0,6,1},
      {2,0,0,0,1,1},
      {2,0,0,1,1,1},
      {2,0,0,0,1,1},
      {2,0,0,0,6,1},
      {2,0,3,0,0,0},
      {2,0,0,0,0,0}
    },
    {
      {2,0,0,0,1,2,0,0,0,0},
      {2,0,0,0,1,2,0,0,0,0},
      {2,0,1,2,0,0,1,2,0,0},
      {2,0,4,0,0,0,0,4,0,0},
      {1,2,0,0,6,6,0,0,1,1},
      {1,2,0,0,6,6,0,0,1,1},
      {2,0,4,0,0,0,0,4,0,0},
      {2,0,1,2,0,0,1,2,0,0},
      {2,0,0,0,1,2,0,0,0,0},
      {2,0,0,0,1,2,0,0,0,0}    
    },
    {
      {2,0,0,0,0,0,0,0,1,1},
      {2,0,0,6,0,0,0,1,1,1},
      {2,0,0,0,0,1,1,1,1,1},
      {2,3,3,3,1,2,0,0,6,1},
      {2,0,0,0,1,2,0,6,0,0},
      {2,3,3,3,1,2,0,0,6,1},
      {2,0,0,0,0,1,1,1,1,1},
      {2,0,0,6,0,0,0,1,1,1},
      {2,0,0,0,0,0,0,0,1,1}
    },
    {
      {2,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1},
      {2,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1},
      {2,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1},
      {1,2,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,2,0},
      {1,1,2,0,0,0,6,0,0,1,1,1,1,1,1,2,0,0,0},
      {1,1,1,1,2,0,0,0,0,0,0,1,1,2,0,0,0,0,0},
      {1,1,1,1,1,2,0,0,0,6,0,3,0,0,6,0,0,0,0},
      {1,1,1,1,1,2,0,0,0,0,3,0,0,0,0,0,6,0,0},
      {1,1,1,1,1,1,2,0,0,3,0,0,0,0,0,0,0,0,0},
      {1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0,0}
    },
    {
      {2,0,0,0,0,0},
      {2,0,6,0,3,0},
      {2,0,3,6,0,0},
      {2,0,3,0,0,0},
      {2,0,0,0,0,0}
    }
  };
  final int[][][] specialRoomTemplates = {
    {
      {1,1,2,0,0,0,1,1},
      {1,2,0,0,0,0,0,1},
      {2,0,0,5,5,5,0,0},
      {2,0,0,5,5,5,0,0},
      {2,0,0,5,5,5,0,0},
      {1,2,0,0,0,0,0,1},
      {1,1,2,0,0,0,1,1}
    }
  };

  boolean overlapsOldRoom(int x, int y, int w, int h) {
    for (int i = 0; i < rooms.size(); i++) {
      if (!(x > rooms.get(i)[2] || x+w < rooms.get(i)[0] || y > rooms.get(i)[3] || y+h < rooms.get(i)[1])) {
          return true;
      }
    }
    return false;
  };

  int[][] mapGenerate(int roomNum, int mapWidth, int mapHeight, int startX, int startY) {
    rooms.clear();
    npcs.clear();
    map = new int[mapWidth][mapHeight];

    //Fill map with 1's
    for (int i = 0; i < mapWidth; i++) {
      for (int j = 0; j < mapHeight; j++) {
        map[i][j] = 1;
      }
    }

    //Generate special rooms
    for (int i = 0; i < specialRoomTemplates.length; i++) {
      int room = i;
      int x, y;

      if (room == 0) {
        x = startX;
        y = startY;
      } else {
        do {
          x = int(random(1, mapWidth-specialRoomTemplates[room].length));
          y = int(random(1, mapHeight-specialRoomTemplates[room][0].length));
        } while (overlapsOldRoom(x, y, specialRoomTemplates[room].length, specialRoomTemplates[room][0].length));
      }

      rooms.add(new int[] {x, y, x+specialRoomTemplates[room].length, y+specialRoomTemplates[room][0].length});

      for (int j = x; j < x+specialRoomTemplates[room].length; j++) {
        for (int k = y; k < y+specialRoomTemplates[room][0].length; k++) {
          map[j][k] = specialRoomTemplates[room][j-x][k-y];
        }
      }
    }

    //Generate rooms
    for (int i = 0; i < roomNum; i++) {
      int room = int(random(0, roomTemplates.length));
      int x, y;

      do {
        x = int(random(1, mapWidth-roomTemplates[room].length));
        y = int(random(1, mapHeight-roomTemplates[room][0].length));
      } while (overlapsOldRoom(x, y, roomTemplates[room].length, roomTemplates[room][0].length));

      rooms.add(new int[] {x, y, x+roomTemplates[room].length, y+roomTemplates[room][0].length});

      for (int j = x; j < x+roomTemplates[room].length; j++) {
        for (int k = y; k < y+roomTemplates[room][0].length; k++) {
          if(roomTemplates[room][j-x][k-y] == 6) {
            map[j][k] = 0;
            npcs.add(new NPC(true, j, k));
          }
          else map[j][k] = roomTemplates[room][j-x][k-y];
        }
      }
    }

    return map;
  }

  public ArrayList<NPC> getNPCs() {
    return npcs;
  }
}
