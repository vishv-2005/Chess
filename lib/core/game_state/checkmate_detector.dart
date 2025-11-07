import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/moves/move_validator.dart';
import 'package:chess/core/game_state/check_detector.dart';
import 'package:chess/core/board/board_state.dart';

/// Detects checkmate and stalemate conditions
class CheckmateDetector {
  /// Returns true if the player with `isWhiteTurn` is in checkmate
  static bool isCheckmate(BoardState boardState) {
    bool isWhiteTurn = boardState.isWhiteTurn;

    // If the player isn't even in check, it's not checkmate
    if (!CheckDetector.isKingInCheck(isWhiteTurn, boardState)) return false;

    // Try every piece for the current player
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = boardState.board[row][col];
        if (piece == null || piece.isWhite != isWhiteTurn) continue;

        List<List<int>> validMoves = MoveValidator.calculateRealValidMoves(
          row,
          col,
          piece,
          false, // simulate for safety
          boardState,
        );

        if (validMoves.isNotEmpty) {
          // There exists at least one safe move → not checkmate
          return false;
        }
      }
    }

    return true; // no legal moves left and in check
  }

  /// Returns true if the player with `isWhiteTurn` is in stalemate
  static bool isStalemate(BoardState boardState) {
    bool isWhiteTurn = boardState.isWhiteTurn;

    // If the player is in check, not stalemate
    if (CheckDetector.isKingInCheck(isWhiteTurn, boardState)) return false;

    // Try every piece for the current player
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        ChessPiece? piece = boardState.board[row][col];
        if (piece == null || piece.isWhite != isWhiteTurn) continue;

        List<List<int>> validMoves = MoveValidator.calculateRealValidMoves(
          row,
          col,
          piece,
          false,
          boardState,
        );

        if (validMoves.isNotEmpty) {
          // There exists at least one safe move → not stalemate
          return false;
        }
      }
    }

    return true; // no legal moves and not in check
  }
}
