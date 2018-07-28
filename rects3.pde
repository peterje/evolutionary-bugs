import java.util.*; //<>// //<>// //<>//

float frameRate = 30;
PVector ideal = new PVector(0.0, 1.0, 0.0);
ArrayList < Integer > favorTracker = new ArrayList < Integer > ();
float[] favorPCT = new float[3];
int tileSize = 8;
int tilesPerCol;
int tilesPerRow;
int bodyCount = 200;
ArrayList < Tile > tiles = new ArrayList < Tile > ();
ArrayList < Body > bodies = new ArrayList < Body > ();
ArrayList < PVector > dna = new ArrayList < PVector > ();
ArrayList < PVector > dnaMemory = new ArrayList < PVector > ();
boolean spotCreated = false;
int genTime = 0;
int initialBodyCount = 200;
void setup() {
 for (int i = 0; i < bodyCount; i++)
  dna.add(PVector.random3D());
 noStroke();
 frameRate(frameRate);
 size(800, 800);
 tilesPerCol = height / tileSize;
 tilesPerRow = width / tileSize;
 background(255);
 generation();
}


void draw() {
 genTime += 1;
 if (genTime == frameRate * 15) {
  println("newgen");
  println(dnaMemory);
  spotCreated = false;
  bodies.clear();
  tiles.clear();
  generation();
  genTime = 0;
 }



 //println(bodies.size());
 favorPCT[0] = 3.6 * (frequency(favorTracker, 0) / favorTracker.size() * 100);
 favorPCT[1] = 3.6 * (frequency(favorTracker, 1) / favorTracker.size() * 100);
 favorPCT[2] = 3.6 * (frequency(favorTracker, 2) / favorTracker.size() * 100);
 noStroke();
 for (int i = 0; i < tiles.size(); i++) {
  tiles.get(i).update();
 }
 stroke(0);
 favorTracker.clear();

 for (Body b: bodies) {
  if (!b.dead) {
   b.show();
   b.update();

   favorTracker.add(b.favor);
  }
 }

 for (Tile t: tiles) {
  if (t.neighbors.size() < 8) {
   t.r = 100000000;
   t.g = -1000000;
   t.b = -1000000;

  }
  for (Tile n: t.neighbors) {
   if (n.r > 240) {
    if (random(100) < 15) {
     if (t.r < 205) {

      t.r += 50;


     }
    }
    if (t.g > 20) {
     t.g -= 20;
    }
   }


   if (n.g == 255) {
    if (random(100) < 30) {
     if (t.r > 200) {
      t.r -= 75;
     }
    }
    if (t.g < 100) {
     t.g = n.g / 2;
    }
   }
   if (n.g > 100) {
    t.g = n.g / 2;
   }

   if (n.b == 255) {
    t.b = n.b / 4;
   }

  }
  if (random(100) < 1) {
   if (t.g < 255) {
    t.g += 20;
    //t.b-=20;
   }
  }
  if (random(100) < .8) {
   if (t.r > 0) {
    t.r -= 20;
   }
  }
 }
 pieChart(width / 2, height / 2, 100, favorPCT);
 textSize(24);
 fill(255);

 text(float(favorTracker.size()) / 200.0 * 100, 0, 20);
}

class Tile {
 int id;
 int r;
 int g;
 int b;
 int x, y;
 int size = tileSize;
 ArrayList < Tile > neighbors = new ArrayList < Tile > ();

 Tile(int _r, int _g, int _b, int _x, int _y, int _id) {
  r = _r;
  g = _g;
  b = _b;
  x = _x;
  y = _y;
  id = _id;
  fill(r, g, b);
  rect(x, y, size, size);
 }

 void update() {
  fill(r, g, b);
  rect(x, y, size, size);
 }

 void getNeighbors() {
  int[] neighborCols = {
   x,
   x + tileSize,
   x - tileSize
  };
  int[] neighborRows = {
   y,
   y + tileSize,
   y - tileSize
  };
  for (int row: neighborRows) {
   for (int col: neighborCols) {
    for (Tile t: tiles) {
     if (t.x == col && t.y == row) {
      if (!(t.x == x && t.y == y)) {
       neighbors.add(t);
      }
     }
    }
   }
  }
 }

 void print() {
  println("ID: ", id, "X,Y: ", x, y, ", COLOR: ", r, g, b, ", NEIGHBORS: ", neighbors.size());
 }
 void printNeighbors() {
  for (Tile n: neighbors) {
   println(n.id);
  }
 }
}

class Body {
 boolean dead;
 int health;
 int size = tileSize;
 int x;
 int y;
 int lastX;
 int lastY;
 int id;
 int favor;
 PVector dna = new PVector();
 Tile lastStanding = new Tile(0, 0, 0, 0, 0, 0);
 Tile standing = new Tile(0, 0, 0, 0, 0, 0);
 ArrayList < Tile > neighbors = new ArrayList < Tile > ();


 Body(int _x, int _y, int _id, PVector _dna) {
  dead = false;
  health = 10;
  x = _x;
  y = _y;
  id = _id;
  dna = _dna;
  float max = -1000;
  favor = 0;
  for (int i = 0; i < dna.array().length; i++) {
   if (dna.array()[i] > max) {
    max = dna.array()[i];
    favor = i;
   }
  }
  favorTracker.add(favor);
 }

 void show() {
  fill(255, 255, 255);
  rect(x, y, tileSize, tileSize);
 }
 void update() {
  lastStanding = standing;
  standing = getCurrentTile();
  if (standing.g - standing.r <= 10) {
   health -= 1;
  }
  if (health == 0) {
   dead = true;
   dnaMemory.add(dna);
  }
  getNeighbors();
  ArrayList < PVector > observations = new ArrayList < PVector > ();

  for (Tile t: neighbors) {
   observations.add(new PVector(t.r, t.g, t.b));
  }


  lastX = x;
  lastY = y;

  int[] cords = think(observations);
  x = cords[0];
  y = cords[1];

 }


 int[] think(ArrayList < PVector > adj) {
  ArrayList < PVector > decision = new ArrayList < PVector > ();
  for (PVector p: adj) {
   decision.add(p.cross(dna));
  }

  int mostActivated = 0;
  int secondMostActivated = 0;
  float maxVal = -1000;
  float secondBest = -1000;
  //println("DECISION MATRIX FOR BODY:", id,"    AT POS: (",x,", ", y, ")");
  //println("UNIQUE DNA: " , dna);
  //println("FAVORS: ", favor);
  for (int i = 0; i < decision.size(); i++) {
   float[] decision_a = decision.get(i).array();
   //print("NEIGHBOR: ", i);
   for (int j = 0; j < decision_a.length; j++) {
    //print("[" , decision_a[j], "]");
    if (decision_a[j] > maxVal) {
     secondBest = maxVal;
     maxVal = decision_a[j];
     secondMostActivated = mostActivated;
     mostActivated = i;
    }
   }
   //println("");
  }

  Tile bestNeighbor = neighbors.get(mostActivated);
  if (bestNeighbor == lastStanding) {
   bestNeighbor = neighbors.get(secondMostActivated);
  }




  int newX = bestNeighbor.x;
  int newY = bestNeighbor.y;

  int[] newCords = {
   newX,
   newY
  };

  return (newCords);
 }


 void getNeighbors() {
  neighbors.clear();
  int[] neighborCols = {
   x,
   x + tileSize,
   x - tileSize
  };
  int[] neighborRows = {
   y,
   y + tileSize,
   y - tileSize
  };
  for (int row: neighborRows) {
   for (int col: neighborCols) {
    for (Tile t: tiles) {
     if (t.x == col && t.y == row) {
      if (!(t.x == x && t.y == y)) {
       neighbors.add(t);
      }
     }
    }
   }
  }
 }

 Tile getCurrentTile() {
  Tile tile = new Tile(0, 0, 0, 0, 0, 0);
  for (Tile t: tiles) {
   if (x == t.x && y == t.y) {
    tile = t;
   }
  }
  return (tile);
 }

}

ArrayList < Body > createBodies(int bodyCount, ArrayList < Tile > tiles, float freq, ArrayList < PVector > dna) {
 ArrayList < Body > bodies = new ArrayList < Body > ();
 if (!(dna.size() == bodyCount)) {
  println("WARNING: AMOUNT OF DNA DOES NOT MATCH NUMBER OF BODIES TO CREATE");
 }
 for (int i = 0; i < tiles.size(); i++) {
  if (random(100) < freq) {
   if (bodies.size() < bodyCount) {
    bodies.add(new Body(tiles.get(i).x, tiles.get(i).x, i, dna.get(i)));
   }
  }
 }
 return (bodies);
}

void mouseClicked() {
 for (Tile t: tiles) {
  if ((t.x <= mouseX && t.x + t.size >= mouseX) && (t.y <= mouseY && t.y + t.size >= mouseY)) {
   if (mouseButton == LEFT) {
    t.print();
   }

  }
 }
 for (Body b: bodies) {
  if ((b.x <= mouseX && b.x + b.size >= mouseX) && (b.y <= mouseY && b.y + b.size >= mouseY)) {
   if (mouseButton == RIGHT) {
    println(b.dna);
    println("LASTSTANDING ID. ", b.lastStanding.id, " STANDING ID: ", b.standing.id);
   }

  }
 }
}
void pieChart(int x, int y, float diameter, float[] data) {
 float lastAngle = 0;
 for (int i = 0; i < data.length; i++) {
  switch (i) {
   case 0:
    fill(255, 0, 0);
    break;
   case 1:
    fill(0, 255, 0);
    break;
   case 2:
    fill(0, 0, 255);
    break;
  }

  arc(x, y, diameter, diameter, lastAngle, lastAngle + radians(data[i]));
  lastAngle += radians(data[i]);
 }
}

float frequency(ArrayList < Integer > data, int val) {
 float count = 0;
 for (Integer i: data) {
  if (i == Integer.valueOf(val)) {
   count++;
  }
 }
 return (count);
}
ArrayList < Tile > generateWorld() {
 ArrayList < Tile > tiles = new ArrayList < Tile > ();

 for (int i = 0; i < width / tileSize; i++) {
  for (int j = 0; j < height / tileSize; j++) {
   Tile t = new Tile(0, int(random(50, 255)), 0, i * tileSize, j * tileSize, tiles.size());
   tiles.add(t);
  }
 }
 for (Tile t: tiles) {
  if (random(100) < 1 && spotCreated == false) {
   t.r = 255;
   t.g = -100;
   t.b = 0;
   spotCreated = true;
  }
  if (random(100) < .5) {
   t.r = 0;
   t.g = int(random(255));
   t.b = 255;
  }
 }
 return (tiles);
}
void generateBodies() {
 for (int i = 0; i < tilesPerCol; i++) {
  for (int j = 0; j < tilesPerRow; j++) {
   if (bodies.size() < bodyCount && random(100) < 2) {
    bodies.add(new Body(i * tileSize, j * tileSize, bodies.size(), PVector.random3D()));
   }
  }
 }
 initialBodyCount = bodies.size();
}
void getNeighbors(ArrayList < Tile > tiles) {
 for (Tile t: tiles) {
  t.getNeighbors();
 }
}

void generation() {
 tiles = generateWorld();
 getNeighbors(tiles);
 generateBodies();
}
