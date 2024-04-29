import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_of_life/src/game_cubit.dart';

class GameOfLifeScreen extends StatefulWidget {
  const GameOfLifeScreen({super.key});

  @override
  State<GameOfLifeScreen> createState() => _GameOfLifeScreenState();
}

typedef Cell = (double, double);
typedef Cells = List<bool>;

class _GameOfLifeScreenState extends State<GameOfLifeScreen> {
  /// game loop
  Timer? _timer;

  /// scale factor for the scene
  double _scale = 1;

  /// Used during a scaling to comput the final scale factor
  double _tmpScale = 1;

  Offset _offset = Offset.zero;

  /// cells of the game. A big 1D array of booleans
  Cells _cells = [];

  @override
  void initState() {
    super.initState();

    setGrid();
    initialize();
  }

  /// Get the data from the confug and generate a grid (1D bool array)
  void setGrid() {
    final a = context.read<GameCubit>().state;
    final cells = <bool>[];

    for (var i = 0; i < a.dimensions.$1 * a.dimensions.$2; i++) {
      cells.add(Random().nextBool());
    }

    setState(() {
      _cells = cells;
    });
  }

  /// Start the game loop
  /// Run every X ms the reload() function
  Future<void> initialize() async {
    _timer?.cancel();
    _timer = Timer.periodic(
        Duration(
          milliseconds: (context.read<GameCubit>().state.frequency).toInt(),
        ), (timer) {
      reload();
    });
  }

  /// update the game model
  /// apply the rules of the game
  void reload() {
    final cellsLength = _cells.length;
    final newCells = <bool>[];
    final rowSize = context.read<GameCubit>().state.dimensions.$1;

    for (var i = 0; i < cellsLength; i++) {
      int neighbors = 0;

      // count before central cell
      if (i - 1 >= 0) {
        if (_cells[i - 1]) {
          neighbors++; // center left
        }

        final q = i - rowSize + 1;
        if (q >= 0) {
          if (_cells[q]) {
            neighbors++; // top-right
          }
          if (q - 1 >= 0) {
            if (_cells[q - 1]) {
              neighbors++; // top center
            }

            if (q - 2 >= 0) {
              if (_cells[q - 2]) {
                neighbors++; // top left
              }
            }
          }
        }
      }

      // count after central cell
      if (i + 1 < cellsLength) {
        if (_cells[i + 1]) {
          neighbors++; // center right
        }
        final q = i + rowSize - 1;
        if (q < cellsLength) {
          if (_cells[q]) {
            neighbors++; // center right
          }
          if (q + 1 < cellsLength) {
            if (_cells[q + 1]) {
              neighbors++; // bottom center
            }

            if (q + 2 < cellsLength) {
              if (_cells[q + 2]) {
                neighbors++; // center right
              }
            }
          }
        }
      }

      /// rules of the game
      /// if alive and less than 2 neighbors or more than 3 -> kill cell
      /// if dead and 3 neighbors -> revive cell
      /// else do nothing
      if (neighbors < 2 || neighbors > 3) {
        newCells.add(false);
      } else if (!_cells[i] && neighbors == 3) {
        newCells.add(true);
      } else {
        newCells.add(_cells[i]);
      }
    }

    setState(() {
      _cells = newCells;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameCubit, GameCubitState>(
      listenWhen: (previous, current) {
        // dirty code because I was lazy

        // reinitialize the gameloop frequency / framerate
        if (previous.frequency != current.frequency) {
          initialize();
        }

        // regenerate the grid
        if (previous.reset != current.reset) {
          setGrid();
        }

        return false;
      },
      listener: (BuildContext context, GameCubitState state) {},
      builder: (context, state) => GestureDetector(
        onScaleStart: (details) {
          _tmpScale = _scale;
        },
        onScaleUpdate: (details) {
          setState(() {
            _scale = _tmpScale * details.scale;
            _offset += details.focalPointDelta;
          });
        },
        child: ClipRRect(
          child: CustomPaint(
            painter: GameOfLifePainter(
              cells: _cells,
              scale: _scale,
              offset: _offset,
              dimensions: state.dimensions,
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }
}

class GameOfLifePainter extends CustomPainter {
  GameOfLifePainter({
    super.repaint,
    required this.cells,
    required this.scale,
    required this.offset,
    required this.dimensions,
  });

  /// the grid of cells
  final Cells cells;

  /// scale. 1 = nothing ; scale < 1 -> zoom out ; scale > 1 -> zoom in
  final double scale;

  /// the origin of the plan
  final Offset offset;

  /// grid dimension (rows, cols)
  final (int, int) dimensions;

  @override
  void paint(Canvas canvas, Size size) {
    /// the default dimension of a cell
    final dimension = 5.0 * scale;
    final rowSize = dimensions.$1;

    /// paint the backgound in black
    canvas.drawPaint(
      Paint()..color = Colors.black,
    );

    /// painter for the cell
    final cellPainter = Paint()
      ..color = Colors.red
      ..strokeWidth = dimension;

    // it's a 1D list containing the coordinates of every alive cells
    final pointsList = Float32List(cells.length * 2);

    for (var (i, isAlive) in cells.indexed) {
      if (isAlive) {
        pointsList[i * 2] = (i % rowSize) * dimension + offset.dx;
        pointsList[i * 2 + 1] = i ~/ rowSize * dimension + offset.dy;
      }
    }

    canvas.drawRawPoints(PointMode.points, pointsList, cellPainter);
  }

  @override
  bool shouldRepaint(covariant GameOfLifePainter oldDelegate) {
    return true;
  }
}
