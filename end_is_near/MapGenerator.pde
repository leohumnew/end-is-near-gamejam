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
      {1,1,1,2,0,0},
      {1,1,2,0,0,0},
      {2,0,0,0,0,0},
      {2,0,3,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0},
      {2,0,0,0,0,0}
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
      {1,1,2,0,0,0,1,1},
      {1,2,3}
    },
    {
      {2,0,0,0,0,0,4,0,0,0,4,0,0,0,0,0},
      {2,0,3,3,0,0,4,0,0,0,4,0,0,3,3,0},
      {2,0,3,0,6,6,4,0,0,0,4,6,6,0,3,0},
      {2,0,0,6,0,0,3,0,0,0,3,0,0,6,0,0},
      {2,0,0,6,0,0,3,0,0,0,3,0,0,6,0,0},
      {1,1,1,2,3,3,4,6,0,6,4,3,3,1,1,1},
      {2,0,0,0,0,0,6,4,0,4,6,0,0,0,0,0},
      {2,0,0,0,0,0,0,0,7,0,0,0,0,0,0,0},
      {2,0,0,0,0,0,6,4,0,4,6,0,0,0,0,0},
      {1,1,1,2,3,3,4,6,0,6,4,3,3,1,1,1},
      {2,0,0,6,0,0,3,0,0,0,3,0,0,6,0,0},
      {2,0,0,6,0,0,3,0,0,0,3,0,0,6,0,0},
      {2,0,3,0,6,6,4,0,0,0,4,6,6,0,3,0},
      {2,0,3,3,0,0,4,0,0,0,4,0,0,3,3,0},
      {2,0,0,0,0,0,4,0,0,0,4,0,0,0,0,0},
      {3}
    },
    {
      {2,0,0,0},
      {8,0,0,0},
      {2,0,0,0},
      {3}
    },
    {
      {1,2,0,0,1},
      {2,0,0,0,0},
      {2,0,10,10,0},
      {2,0,10,10,0},
      {2,0,0,0,0},
      {1,2,0,0,1},
      {1,2}
    },
    {
      {2,0,0,0,0,0,0,0,0,0,0,0,0},
      {2,0,0,1,1,1,1,1,1,1,1,0,0},
      {2,0,1,1,0,0,0,0,0,0,0,0,0},
      {2,0,1,0,0,0,0,0,0,0,0,0,0},
      {2,0,1,0,0,0,0,0,0,0,0,0,0},
      {2,0,1,1,0,0,0,0,0,0,0,0,0},
      {2,0,0,1,1,1,1,1,1,1,9,0,0},
      {2,0,0,0,0,0,0,0,0,0,0,0,0},
      {4}
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

  int[][] mapGenerate(int roomNum, int mapWidth, int mapHeight, int startX, int startY, int mapType) { //Map type 0 = normal, 1 = spaceship
    rooms.clear();
    npcs.clear();
    itemList.clear();
    map = new int[mapWidth][mapHeight];

    //Fill map with 1's
    for (int i = 0; i < mapWidth; i++) {
      for (int j = 0; j < mapHeight; j++) {
        map[i][j] = 1;
      }
    }

    //Generate special rooms
    if (mapType != 4) {
      for (int i = 0; i < specialRoomTemplates.length-1; i++) {
        if (contains(specialRoomTemplates[i][specialRoomTemplates[i].length-1], mapType)) {
          int room = i;
          int x, y;

          if (room == 0) {
            x = startX;
            y = startY;
          } else {
            do {
              x = int(random(1, mapWidth-specialRoomTemplates[room].length-1));
              y = int(random(1, mapHeight-specialRoomTemplates[room][0].length));
            } while (overlapsOldRoom(x, y, specialRoomTemplates[room].length-1, specialRoomTemplates[room][0].length));
          }

          rooms.add(new int[] {x, y, x+specialRoomTemplates[room].length-1, y+specialRoomTemplates[room][0].length});

          for (int j = x; j < x+specialRoomTemplates[room].length-1; j++) {
            for (int k = y; k < y+specialRoomTemplates[room][0].length; k++) {
              if(k < 0)println(k+" "+y+" "+room);
              if(specialRoomTemplates[room][j-x][k-y] == 6) {
                map[j][k] = 0;
                npcs.add(new NPC(true, j, k));
              } else if (specialRoomTemplates[room][j-x][k-y] == 7) {
                map[j][k] = 0;
                itemList.add(new Pickup(j, k, 0));
              } else map[j][k] = specialRoomTemplates[room][j-x][k-y];
              if (map[j][k] == 8) {
                itemList.add(new Pickup(j, k+1, -1));
              }
            }
          }
        }
      }

      //Generate rooms
      for (int i = 0; i < roomNum; i++) {
        int room, x, y;

        do {
          room = int(random(0, roomTemplates.length));
          x = int(random(1, mapWidth-roomTemplates[room].length));
          y = int(random(1, mapHeight-roomTemplates[room][0].length));
        } while (overlapsOldRoom(x, y, roomTemplates[room].length, roomTemplates[room][0].length));

        rooms.add(new int[] {x, y, x+roomTemplates[room].length, y+roomTemplates[room][0].length});

        for (int j = x; j < x+roomTemplates[room].length; j++) {
          for (int k = y; k < y+roomTemplates[room][0].length; k++) {
            if(roomTemplates[room][j-x][k-y] == 6) {
              map[j][k] = 0;
              npcs.add(new NPC(true, j, k));
            } else map[j][k] = roomTemplates[room][j-x][k-y];
          }
        }
      }
    } else if (mapType == 1) {
      for (int j = 11; j < 11+specialRoomTemplates[specialRoomTemplates.length-1].length; j++) {
        for (int k = 3; k < 3+specialRoomTemplates[specialRoomTemplates.length-1][0].length; k++) {
          map[j][k] = specialRoomTemplates[specialRoomTemplates.length-1][j-11][k-3];
        }
      }
    }
    return map;
  }

  public ArrayList<NPC> getNPCs() {
    return npcs;
  }
}
