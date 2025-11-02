import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/game_state/check_detector.dart';
import 'package:chess/core/moves/move_validator.dart';

/// Detects checkmate condition
class CheckmateDetector {
  /// Check if the king of the given color is in checkmate
  static bool isCheckmate(
    bool isWhiteKing,
    List<List<ChessPiece?>> board,
    List<int> whiteKingPosition,
    List<int> blackKingPosition,
  ) {
    // if the king is not in check, then it's not checkmate
    if (!CheckDetector.isKingInCheck(
      isWhiteKing,
      board,
      whiteKingPosition,
      blackKingPosition,
    )) {
      return false;
    }

    // if there is at least one legal move for any of the player's pieces, then it's not checkmate
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the opposite color
        if (board[i][j] == null || board[i][j]!.isWhite != isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = MoveValidator.calculateRealValidMoves(
          i,
          j,
          board[i][j],
          true, // check simulation needed
          board,
          whiteKingPosition,
          blackKingPosition,
        );

        // if this piece has any valid moves, then it's not checkmate
        if (pieceValidMoves.isNotEmpty) {
          return false;
        }
      }
    }

    // if none of the above conditions are met, then there are no legal moves left
    // it's checkmate!
    return true;
  }
}

