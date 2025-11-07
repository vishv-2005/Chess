import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/game_state/check_detector.dart';
import 'package:chess/core/game_state/checkmate_detector.dart';
import 'package:chess/core/moves/move_validator.dart';

/// Manages overall game state and coordinates game flow.
class GameStateManager {
  /// Updates whether the current player is in check after a move.
  static void updateCheckStatus(BoardState boardState) {
    boardState.checkStatus = CheckDetector.isKingInCheck(
      boardState.isWhiteTurn,
      boardState,
    );
  }

  /// Returns all valid moves for a given piece at (row, col).
  static List<List<int>> getValidMoves(
      int row,
      int col,
      ChessPiece? piece,
      BoardState boardState,
      ) {
    if (piece == null) return [];
    return MoveValidator.calculateRealValidMoves(
      row,
      col,
      piece,
      false, // no check simulation flag
      boardState,
    );
  }

  /// Checks if the current player is in checkmate.
  static bool isCheckmate(BoardState boardState) {
    return CheckmateDetector.isCheckmate(boardState);
  }

  /// Checks if the current player is in stalemate.
  static bool isStalemate(BoardState boardState) {
    return CheckmateDetector.isStalemate(boardState);
  }
}
