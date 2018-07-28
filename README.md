# evolutionary-bugs
An implementation of an evolutionary algorithm where creatures run from environmental factors.


# Tiles
A random 'world' is generated with a grid of tiles of random RGB values. An original tile has only a green value, no red or blue.

Exception:
  At the beginning of the world, the edge tiles are all maximum RED.

Every frame, each tile has the change to undergo an event depending on the tile's RGB value and its 8 surrounding tiles.

Possible events:
  - Decrease in RED if neighbor is maximum GREEN
  - Increase in RED if neighnor is maxmum RED
  - Decrease in GREEN if neighnor is maxmum RED
  - GREEN = neighbor GREEN * 0.5 if neighbor is maximum GREEN
  - BLUE = neighbor BLUE * 0.25 if neighbor is maximum BLUE 
  - 1% chance for ANY tile to increase in GREEN
  - 0.8% chance for ANY tile to decrease in RED

As a result of these factors, a border of red begins and slowly dominates the world.


# Bugs

On the tiles live a colony of bugs. Ever frame, bugs decide to move to any of their 8 neighbors depending on their respective RGB values. This decision is made using their 'dna', a 1x3 matrix where each value corresponds to how much that bug prefers a certain RGB value.

For example:

  A bug with a dna of [0.7, 0.3, 0.1] will favor a RED tile more than a GREEN tile but a GREEN tile more than a BLUE tile.

Every frame, the RGB data of all adjacent tiles is passed to a given bug. This bug will perform the cross product between a neighbor tile and its dna. After this operation is complete for all possible neighbors, the bug moves to the neighbor that produced the largest value when crossed with its dna.

A bug loses health when it is on a tile that is more red than green. A bug dies when its health reaches 0.
