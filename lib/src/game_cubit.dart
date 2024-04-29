import 'dart:math';

import 'package:flutter_bloc/flutter_bloc.dart';

class GameCubitState {
  /// we refresh every X ms
  final int frequency;

  /// (nb cols, nb rows)
  final (int, int) dimensions;

  /// -1 -> must reset
  final double reset;

  GameCubitState({
    required this.frequency,
    required this.dimensions,
    required this.reset,
  });

  GameCubitState copyWith({
    int? frequency,
    (int, int)? dimensions,
    double? reset,
  }) {
    return GameCubitState(
      frequency: frequency ?? this.frequency,
      dimensions: dimensions ?? this.dimensions,
      reset: reset ?? this.reset,
    );
  }
}

class GameCubit extends Cubit<GameCubitState> {
  GameCubit()
      : super(
          GameCubitState(
            frequency: (1 / 20 * 1000).toInt(),
            dimensions: (500, 500),
            reset: -1,
          ),
        );

  /// Dirty way to notify that the
  void restart() {
    emit(
      state.copyWith(
        reset: Random().nextDouble(),
      ),
    );
  }

  void updateFramerate(int frequency) {
    emit(state.copyWith(frequency: frequency));
  }

  void updateCols(int cols) {
    emit(state.copyWith(
      dimensions: (state.dimensions.$1, cols),
    ));
  }

  void updateRows(int rows) {
    emit(state.copyWith(
      dimensions: (rows, state.dimensions.$2),
    ));
  }
}
