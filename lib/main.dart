import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:game_of_life/src/game_cubit.dart';
import 'package:game_of_life/src/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameCubit(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Game of Life',
        theme: ThemeData(),
        home: const HomeScreen(),
      ),
    );
  }
}
