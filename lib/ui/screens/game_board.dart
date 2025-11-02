import 'package:flutter/material.dart';
import 'package:chess/ui/components/dead_piece.dart';
import 'package:chess/ui/components/square.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/board/board_initializer.dart';
import 'package:chess/core/moves/move_executor.dart';
import 'package:chess/core/game_state/game_state_manager.dart';
import 'package:chess/utils/board_utils.dart';
import 'package:chess/ui/themes/app_theme.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  late BoardState boardState;

  @override
  void initState() {
    super.initState();
    final initialBoard = BoardInitializer.initializeBoard();
    boardState = BoardState(board: initialBoard);
  }

  // USER SELECTED PIECE
  void pieceSelected(int row, int col) {
    setState(() {
      // No piece has been selected yet, this is the first selection
      if (boardState.selectedPiece == null && boardState.board[row][col] != null) {
        if (boardState.board[row][col]!.isWhite == boardState.isWhiteTurn) {
          boardState.selectedPiece = boardState.board[row][col];
          boardState.selectedRow = row;
          boardState.selectedCol = col;
        }
      }
      // There is a piece already selected, but user can select another one of their pieces
      else if (boardState.board[row][col] != null &&
          boardState.board[row][col]!.isWhite == boardState.selectedPiece?.isWhite) {
        boardState.selectedPiece = boardState.board[row][col];
        boardState.selectedRow = row;
        boardState.selectedCol = col;
      }
      // if there is a piece that is selected and user taps on a square that is a valid move, move there
      else if (boardState.selectedPiece != null &&
          boardState.validMoves.any((element) => element[0] == row && element[1] == col)) {
        movePiece(row, col);
      }

      // if a piece is selected, calculate its valid moves
      GameStateManager.calculateValidMoves(boardState);
    });
  }

  // MOVE PIECE
  void movePiece(int newRow, int newCol) {
    MoveExecutor.executeMove(
      boardState.selectedRow,
      boardState.selectedCol,
      newRow,
      newCol,
      boardState,
    );

    // see if any kings are under attack
    GameStateManager.updateCheckStatus(boardState);

    setState(() {});

    // check if it's checkmate
    if (GameStateManager.isCheckmate(boardState)) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("CHECK MATE"),
          actions: [
            // play the game again
            TextButton(
              onPressed: resetGame,
              child: const Text("Play again"),
            ),
          ],
        ),
      );
    }
  }

  // RESET THE GAME
  void resetGame() {
    Navigator.pop(context);
    final initialBoard = BoardInitializer.initializeBoard();
    boardState = BoardState(board: initialBoard);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Chess"), centerTitle: true),
      backgroundColor: AppTheme.foregroundColor,
      body: Column(
        children: [
          // WHITE PIECE TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: boardState.whitePiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: boardState.whitePiecesTaken[index].imagePath,
                isWhite: true,
              ),
            ),
          ),

          // GAME STATUS
          Text(boardState.checkStatus ? "CHECK!" : ""),

          // CHESS BOARD
          Expanded(
            flex: 3,
            child: GridView.builder(
              itemCount: 8 * 8,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) {
                // get the row and col position of this square
                int row = index ~/ 8;
                int col = index % 8;

                bool isSelected = boardState.selectedRow == row && boardState.selectedCol == col;

                // check if this square is a valid move
                bool isValidMove = false;
                for (var position in boardState.validMoves) {
                  // compare row and col
                  if (position[0] == row && position[1] == col) {
                    isValidMove = true;
                  }
                }
                return Square(
                  isWhite: isWhite(index),
                  piece: boardState.board[row][col],
                  isSelected: isSelected,
                  isValidMove: isValidMove,
                  onTap: () {
                    pieceSelected(row, col);
                  },
                );
              },
            ),
          ),

          // BLACK PIECE TAKEN
          Expanded(
            child: GridView.builder(
              itemCount: boardState.blackPiecesTaken.length,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 8,
              ),
              itemBuilder: (context, index) => DeadPiece(
                imagePath: boardState.blackPiecesTaken[index].imagePath,
                isWhite: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

