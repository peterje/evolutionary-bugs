import java.util.*;
import org.apache.commons.lang3.*;

ArrayList < Tile > tiles = new ArrayList < Tile > ();
ArrayList < Body > bodies = new ArrayList < Body > ();
ArrayList < Body > deadBodies = new ArrayList < Body > ();
ArrayList < PVector > oldDna = new ArrayList < PVector > ();
ArrayList < PVector > newDna = new ArrayList < PVector > ();
ArrayList < Integer > favors = new ArrayList < Integer > ();
int tileSize = 32; // should be a factor of width and height
int bodyCount = 30;
boolean gamePause = false;
int generation = 0;
int freqR = 0;
int freqG = 0;
int freqB = 0;
int[] ages = new int[bodyCount];
int avgAge = 0;

void setup() {
    frameRate(10);
    size(1280, 1024);
    tiles = generateWorld();
    for (int i = 0; i < bodyCount; i++) { // dont use SetAll or Fill because random wont re generate
        newDna.add(PVector.random3D());
    }

    bodies = generateBodies(newDna);
}

void draw() {
    if(!gamePause)
    {

        for (Tile t: tiles) {
            t.draw();
            t.update();
        }

        for (Body b: bodies) {
            b.update();
            b.draw();
            
        }
        if(deadBodies.size() == bodyCount)
        {   

            for(int i = 0; i < bodyCount; i++)
            {
                ages[i] = bodies.get(i).age;
            }
            avgAge = sum(ages) / bodyCount;
            
            freqR = Collections.frequency(favors, 0);
            freqG = Collections.frequency(favors, 1);
            freqB = Collections.frequency(favors, 2);
            println("GENERATION: " + generation);
            println("R%: " + freqR / (float)bodyCount * 100);
            println("G%: " + freqG / (float)bodyCount * 100);
            println("B%: " + freqB / (float)bodyCount * 100);
            
            println("avgAge = " + avgAge);
            favors.clear();
            bodies.clear();
            deadBodies.clear();
            // newDna = mutate(new ArrayList<PVector>(oldDna.subList(0, oldDna.size()/2 + 1)));
            newDna = mutate(new ArrayList<PVector>(oldDna.subList(oldDna.size()/2 - 1, oldDna.size()-1)));
            tiles = generateWorld();
            bodies = generateBodies(newDna);
            generation +=1;


        }

    }
}

class Tile {
    int id;
    int r, g, b;
    int x, y;
    int size = tileSize;
    ArrayList < Tile > neighbors = new ArrayList < Tile > (); // contains all adjacent tiles

    Tile(int _r, int _g, int _b, int _x, int _y, int _id) {
        r = _r;
        g = _g;
        b = _b;
        x = _x;
        y = _y;
        id = _id;
    }

    ArrayList < Tile > getNeighbors() {
        ArrayList < Tile > neighbors = new ArrayList < Tile > ();
        int[] neighborCols = {
            x,
            x + 1,
            x - 1
        };
        int[] neighborRows = {
            y,
            y + 1,
            y - 1
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
        return (neighbors);
    }

    void draw() {
        fill(r, g, b);
        rect(x * tileSize, y * tileSize, size, size);
    }

    void update() {
        neighbors = getNeighbors();
        if (neighbors.size() < 8) { // makes the border solid red
            r = 100000000;
            g = -1000000;
            b = -1000000;
        }
        for (Tile n: neighbors) {
            if (n.r > 240 || n.b > 240) {
                if (random(100) < 15) {
                    if (r < 205) {
                        r += 50;}
                    if (b < 205) {
                        b += 50;}
                }
                if (g > 20) {
                    g -= 20;
                }
            }


            if (n.g == 255) {
                if (random(100) < 30) {
                    if (r > 200) {
                        r -= 75;

                    }
                }
                if (g < 100) {
                    g = n.g / 2;
                }
            }
            if (n.g > 100) {
                g = n.g / 2;
            }

        }
        if (random(100) < 1) {
            if (g < 255) {
                g += 20;
            }
        }
    }        
}

class Body {
    boolean isDead;
    int age;
    int health;
    int size = tileSize;
    int x, y;
    int prevX, prevY;
    int id;
    float favor;
    PVector dna = new PVector(); // <r,g,b> sensitivities
    ArrayList < Tile > neighbors = new ArrayList < Tile > ();
    Tile lastStanding = new Tile(0, 0, 0, 0, 0, 0);
    Tile standing = new Tile(0, 0, 0, 0, 0, 0);

    Body(int _x, int _y, int _id, PVector _dna) {
        age = 0;
        isDead = false;
        health = 20;
        x = _x;
        y = _y;
        id = _id;
        dna = _dna;
        ArrayList < Tile > neighbors = new ArrayList < Tile > ();
        List dnaList = Arrays.asList(ArrayUtils.toObject(dna.array())); // allows for collection operations on dna
        favor = dnaList.indexOf(Collections.max(dnaList)); // get index of most preferred color in dna r=0, g=1, b=2
        favors.add(int(favor));
    }

    void draw() {
        if(!isDead)
        {
            fill(255, 255, 255);
            rect(x * tileSize, y * tileSize, tileSize, tileSize);
        }
    }

    void update() {
        if(!isDead)
        {
            age += 1;
            lastStanding = standing;
            standing = getCurrentTile();
            neighbors = getNeighbors();
            if (standing.g - standing.r <= 10) {
                health -= 1;
            }

            if (health == 0) {
                isDead = true;
                deadBodies.add(this);
                oldDna.add(dna);
            }

            Tile destination = think(neighbors);
            x = destination.x;
            y = destination.y;
        }
    }

    ArrayList < Tile > getNeighbors() {
        ArrayList < Tile > neighbors = new ArrayList < Tile > ();
        int[] neighborCols = {
            x,
            x + 1,
            x - 1
        };
        int[] neighborRows = {
            y,
            y + 1,
            y - 1
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
        return (neighbors);
    }

    Tile getCurrentTile() {
        Tile tile = new Tile(0, 0, 0, 0, 0, 0);
        for (Tile t: tiles)
            if (x == t.x && y == t.y) {
                tile = t;
            }
        return (tile);
    }

    Tile think(ArrayList < Tile > nbors) {
        int[][] a = new int[nbors.size()][3];
        for (int i = 0; i < nbors.size(); i++) {
            a[i][0] = nbors.get(i).r;
            a[i][1] = nbors.get(i).g;
            a[i][2] = nbors.get(i).b;

        }

        float[][] b = new float[nbors.size()][3];
        Arrays.fill(b, dna.array());

        Float[][] c = new Float[nbors.size()][3];

        for (int j = 0; j < nbors.size(); j++) {
            c[j][0] = a[j][0] * b[j][0];
            c[j][1] = a[j][1] * b[j][1];
            c[j][2] = a[j][2] * b[j][2];

        }

        Float[] d = new Float[nbors.size()];

        for (int i = 0; i < nbors.size(); i++) {
            d[i] = Collections.max(Arrays.asList(c[i]));
        }
        textSize(12);
        // for(int i = 0; i<nbors.size();i++)
        // {   
        //     fill(0,0,0);
        //     text("S=" + int(d[i]), nbors.get(i).x * tileSize, nbors.get(i).y * tileSize + 24);
        //     text("ID = " + i, nbors.get(i).x * tileSize, nbors.get(i).y * tileSize + 12);
        // }
        Float[] backup = Arrays.copyOf(d, d.length);
        Arrays.sort(d);
        Tile bestNeighbor = nbors.get(ArrayUtils.indexOf(backup, d[d.length - 1]));
        if (bestNeighbor == lastStanding) {
            bestNeighbor = nbors.get(ArrayUtils.indexOf(backup, d[d.length - 2]));
        }
        return (bestNeighbor);
    }
}


ArrayList < Tile > generateWorld() {
    ArrayList < Tile > tiles = new ArrayList < Tile > ();

    for (int i = 0; i < width / tileSize; i++) {
        for (int j = 0; j < height / tileSize; j++) {
            Tile t = new Tile(int(random(0, 10)), int(random(25, 255)), int(random(0, 10)), i, j, tiles.size());
            tiles.add(t);
        }
    }
    return (tiles);
}

ArrayList < Body > generateBodies(ArrayList< PVector > dna) {
    ArrayList < Body > bodies = new ArrayList < Body > ();
    for (int i = 0; i < bodyCount; i++) {
        bodies.add(new Body(int(random(0, width / tileSize)), int(random(0, height / tileSize)), bodies.size(), dna.get(i)));
    }
    return (bodies);
}

void mouseClicked() {
    println("clicked");
    for (Tile t: tiles) {
        if ((t.x * tileSize <= mouseX && t.x * tileSize + t.size >= mouseX) && (t.y * tileSize <= mouseY && t.y * tileSize + t.size >= mouseY)) {
            if (mouseButton == LEFT) {
                println(t.r, t.g, t.b);
            }

        }
    }
    for (Body b: bodies) {

        if ((b.x * tileSize <= mouseX && b.x * tileSize + b.size >= mouseX) && (b.y * tileSize <= mouseY && b.y * tileSize + b.size >= mouseY)) {
            if (mouseButton == RIGHT) {
                println("ID=" + b.id);
                println("DNA=" + b.dna);
                println("X=" + b.x);
                println("Y=" + b.y);
                println("HEALTH=" + b.health);
                println("NBORS=" + b.neighbors.size());
                println();
                println();
            }

        }
    }
}

void keyPressed() {
  if (key == CODED) {
    if (keyCode == SHIFT) {
        println("pause");
       gamePause = !gamePause;
        }
    }
}

ArrayList< PVector > mutate(ArrayList< PVector > dnaList) {
    ArrayList< PVector > newDna = new ArrayList< PVector >(dnaList.size());

    for(PVector dna : dnaList)
    {
        newDna.add(dna);
        dna.x += random(-.01,.01);
        dna.y += random(-.01,.01);
        dna.z += random(-.01,.01);
        newDna.add(dna);
    }
    return(newDna);
}
public int sum(int[] nums){

    int result = 0;
    for(int i = 0 ; i < nums.length; i++) {
        result += nums[i];
    } 
    return result;
}
