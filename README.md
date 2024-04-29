# Game of Life

A simple but very efficient and powerful and wonderful **Conway's Game of Life** in **Flutter**.

## Demo

[Demo](https://flutter-game-of-life.pages.dev/)

It's slower in the browser.

## How does it work

The simulation has a 1D-array containing booleans. The game loop is updating and rendering the scene every X ms. It applies the game rules for each cell.  
Then, a `CustomPainter` draw all the alive cells.