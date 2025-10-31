import 'package:flutter/material.dart';
import 'package:passant/game_board.dart';
import 'package:flutter/services.dart';
// import 'package:passant/values/colors.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton(
              onPressed: () {
                // TODO: later hook up to "vs computer" logic
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameBoard()),
                );
              },
              child: const Text("Play Against Computer"),
            ),
            const SizedBox(height: 16),
            FilledButton(
              // style: FilledButton.styleFrom(backgroundColor: backgroundColor),
              onPressed: () {
                // for now reuse same GameBoard
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GameBoard()),
                );
              },
              child: const Text("Over the Board"),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () {
                SystemNavigator.pop();
              },
              child: const Text("Exit"),
            ),
          ],
        ),
      ),
    );
  }
}
