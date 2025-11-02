import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/moves/move_validator.dart';

/// Detects if a king is in check
class CheckDetector {
  /// Check if the king of the given color is in check
  static bool isKingInCheck(
    bool isWhiteKing,
    List<List<ChessPiece?>> board,
    List<int> whiteKingPosition,
    List<int> blackKingPosition,
  ) {
    // get the position of the king
    List<int> kingPosition = isWhiteKing ? whiteKingPosition : blackKingPosition;

    // check if any enemy piece can attack the king
    for (int i = 0; i < 8; i++) {
      for (int j = 0; j < 8; j++) {
        // skip empty squares and pieces of the same color
        if (board[i][j] == null || board[i][j]!.isWhite == isWhiteKing) {
          continue;
        }

        List<List<int>> pieceValidMoves = MoveValidator.calculateRealValidMoves(
          i,
          j,
          board[i][j],
          false, // no check simulation needed here
          board,
          whiteKingPosition,
          blackKingPosition,
        );

        // check if the king's position is in this piece's valid moves
        if (pieceValidMoves.any(
          (move) => move[0] == kingPosition[0] && move[1] == kingPosition[1],
        )) {
          return true;
        }
      }
    }

    return false;
  }
}

