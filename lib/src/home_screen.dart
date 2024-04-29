import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_of_life/src/game_cubit.dart';
import 'package:game_of_life/src/game_of_life_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: MediaQuery.sizeOf(context).width * 0.2,
            child: const SettingsBar(),
          ),
          const Expanded(child: GameOfLifeScreen()),
        ],
      ),
    );
  }
}

class SettingsBar extends StatelessWidget {
  const SettingsBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.orange,
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Text("Refresh"),
              Expanded(
                child: TextFormField(
                  initialValue:
                      context.read<GameCubit>().state.frequency.toString(),
                  onChanged: (value) {
                    context.read<GameCubit>().updateFramerate(int.parse(value));
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    suffix: Text("ms"),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Rows"),
              Expanded(
                child: TextFormField(
                  initialValue:
                      context.read<GameCubit>().state.dimensions.$1.toString(),
                  onChanged: (value) {
                    context.read<GameCubit>().updateRows(int.parse(value));
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              const Text("Column"),
              Expanded(
                child: TextFormField(
                  initialValue:
                      context.read<GameCubit>().state.dimensions.$2.toString(),
                  onChanged: (value) {
                    context.read<GameCubit>().updateCols(int.parse(value));
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ],
          ),
          OutlinedButton(
            onPressed: () {
              context.read<GameCubit>().restart();
            },
            child: const Text("Reset"),
          ),
        ],
      ),
    );
  }
}
