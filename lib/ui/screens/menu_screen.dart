import 'package:flutter/material.dart';
import 'package:chess/ui/screens/game_board.dart';
import 'package:flutter/services.dart';

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

