import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/moves/move_calculator.dart';
import 'package:chess/core/board/board_state.dart';

/// Detects whether a player's king is in check
class CheckDetector {
  /// Returns true if the king of `isWhiteKing` is currently in check.
  static bool isKingInCheck(bool isWhiteKing, BoardState boardState) {
    List<List<ChessPiece?>> board = boardState.board;
    List<int> kingPos =
    isWhiteKing ? boardState.whiteKingPosition : boardState.blackKingPosition;

    // If king is missing (corrupted board)
    if (kingPos[0] < 0 || kingPos[1] < 0) return false;

    // Loop through all squares and find enemy pieces
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = board[row][col];
        if (piece == null) continue;
        // Skip friendly pieces
        if (piece.isWhite == isWhiteKing) continue;

        // Get raw moves for that enemy piece
        List<List<int>> moves = MoveCalculator.calculateRawValidMoves(
          row,
          col,
          piece,
          board,
        );

        // If any of those moves attacks the king position, it’s check
        for (var move in moves) {
          if (move[0] == kingPos[0] && move[1] == kingPos[1]) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
