import 'dart:async';

import 'package:flappy_bird_clone_v2/barrier.dart';
import 'package:flappy_bird_clone_v2/bird.dart';
import 'package:flappy_bird_clone_v2/coverscreen.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // bird variables
  static double birdY = 0;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -4.9; // how strong the gravity is
  double velocity = 3.5; // how strong the jump is
  double birdWidth = 0.1; // out of 2, 2 being the entire width of the screen
  double birdHeight = 0.1; // out of 2, 2 being the entire height of the screen

  // game settings
  bool gameHasStarted = false;

  // barrier variables
  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierWidth = 0.5; // out of 2
  List<List<double>> barrierHeight = [
    // out of 2, where 2 is the entire height of the screen
    // [topHeight, bottomHeight]
    [0.6, 0.4],
    [0.4, 0.6],
  ];

  void startGame() {
    gameHasStarted = true;
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      // a real physical jump is the same as an upside down parabola
      // so this is a simple quadratic equation
      height = gravity * time * time + velocity * time;
      setState(() {
        birdY = initialPos - height;
      });
      // check if bird is dead
      if (birdIsDead()) {
        timer.cancel();
        _showDialog();
      }
      // keep the map moving (move barriers)
      moveMap();
      // keep the time going!
      time += 0.01;
    });
  }

  void moveMap() {
    for (int i = 0; i < barrierX.length; i++) {
      // keep barriers moving
      setState(() {
        barrierX[i] -= 0.005;
      });
      // if barrier exits the left part of the screen, keep it looping
      if (barrierX[i] < -1.5) {
        barrierX[i] += 3;
      }
    }
  }

  void resetGame() {
    Navigator.pop(context); // dismisses the alert dialog
    setState(() {
      birdY = 0;
      gameHasStarted = false;
      time = 0;
      initialPos = birdY;
    });
  }

  void _showDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.brown,
            title: const Center(
              child: Text(
                "G A M E  O V E R",
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                onTap: resetGame,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    color: Colors.white,
                    child: const Text(
                      "PLAY AGAIN",
                      style: TextStyle(color: Colors.brown),
                    ),
                  ),
                ),
              ),
            ],
          );
        });
  }

  void jump() {
    setState(() {
      time = 0;
      initialPos = birdY;
    });
  }

  bool birdIsDead() {
    // check if the bird is hitting the top or the bottom of the screen
    if (birdY < -1 || birdY > 1) {
      return true;
    }
    // hit barriers
    // check if bird is within x coordinates and y coordinates of barriers
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierWidth >= -birdWidth &&
          (birdY <= -1 + barrierHeight[i][0] ||
              birdY + birdHeight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Stack(
                    children: [
                      // bird
                      MyBird(
                        birdY: birdY,
                        birdWidth: birdWidth,
                        birdHeight: birdHeight,
                      ),
                      // tap to play
                      MyCoverScreen(gameHasStarted: gameHasStarted),
                      // Top barrier 0
                      MyBarrier(
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][0],
                        barrierX: barrierX[0],
                        isThisBottomBarrier: false,
                      ),
                      // Bottom barrier 0
                      MyBarrier(
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][1],
                        barrierX: barrierX[0],
                        isThisBottomBarrier: true,
                      ),
                      // Top barrier 1
                      MyBarrier(
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][0],
                        barrierX: barrierX[1],
                        isThisBottomBarrier: false,
                      ),
                      // Bottom barrier 0
                      MyBarrier(
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][1],
                        barrierX: barrierX[1],
                        isThisBottomBarrier: true,
                      ),
                      Container(
                        alignment: const Alignment(0, -0.5),
                        child: Text(
                          gameHasStarted ? "" : "T A P  T O  P L A Y",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
