import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/game_state/check_detector.dart';

/// Handles castling logic for both kings
class Castling {
  /// Get available castling moves for a king
  static List<List<int>> getCastlingMoves(
      int row,
      int col,
      ChessPiece piece,
      List<List<ChessPiece?>> board,
      BoardState boardState,
      ) {
    List<List<int>> castlingMoves = [];
    if (piece.type != ChessPieceType.king) return castlingMoves;

    bool isWhite = piece.isWhite;
    int kingRow = isWhite ? 7 : 0;

    // Ensure king hasn't moved
    if ((isWhite && boardState.whiteKingMoved) ||
        (!isWhite && boardState.blackKingMoved)) {
      return castlingMoves;
    }

    // King must be on original file e column
    if (row != kingRow || col != 4) {
      return castlingMoves;
    }

    // Helper to test if moving king to an intermediate/destination square is safe
    bool squaresSafe(List<List<int>> kingSquares) {
      // Save current king position
      final savedWhiteKing = List<int>.from(boardState.whiteKingPosition);
      final savedBlackKing = List<int>.from(boardState.blackKingPosition);

      try {
        for (final sq in kingSquares) {
          if (isWhite) {
            boardState.whiteKingPosition = [sq[0], sq[1]];
          } else {
            boardState.blackKingPosition = [sq[0], sq[1]];
          }
          if (CheckDetector.isKingInCheck(isWhite, boardState)) {
            return false;
          }
        }
        return true;
      } finally {
        boardState.whiteKingPosition = savedWhiteKing;
        boardState.blackKingPosition = savedBlackKing;
      }
    }

    // Current position cannot be in check
    if (CheckDetector.isKingInCheck(isWhite, boardState)) {
      return castlingMoves;
    }

    // Kingside castling
    if (board[kingRow][7] != null &&
        board[kingRow][7]!.type == ChessPieceType.rook &&
        board[kingRow][7]!.isWhite == isWhite) {
      // Rook must not have moved
      bool rookNotMoved = isWhite ? !boardState.whiteRightRookMoved : !boardState.blackRightRookMoved;
      bool empty = board[kingRow][5] == null && board[kingRow][6] == null;
      if (rookNotMoved && empty) {
        // Squares the king passes through must be safe: f and g files
        if (squaresSafe([
          [kingRow, 5],
          [kingRow, 6],
        ])) {
          castlingMoves.add([kingRow, 6]);
        }
      }
    }

    // Queenside castling
    if (board[kingRow][0] != null &&
        board[kingRow][0]!.type == ChessPieceType.rook &&
        board[kingRow][0]!.isWhite == isWhite) {
      // Rook must not have moved
      bool rookNotMoved = isWhite ? !boardState.whiteLeftRookMoved : !boardState.blackLeftRookMoved;
      bool empty =
          board[kingRow][1] == null && board[kingRow][2] == null && board[kingRow][3] == null;
      if (rookNotMoved && empty) {
        // Squares the king passes through must be safe: d and c files
        if (squaresSafe([
          [kingRow, 3],
          [kingRow, 2],
        ])) {
          castlingMoves.add([kingRow, 2]);
        }
      }
    }

    return castlingMoves;
  }

  /// Apply castling rook moves if the king move corresponds to a castling move.
  static void applyCastlingIfNeeded(
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      BoardState boardState,
      ) {
    ChessPiece? moved = boardState.board[endRow][endCol];
    if (moved == null || moved.type != ChessPieceType.king) return;
    bool isWhite = moved.isWhite;

    // White kingside
    if (isWhite && startRow == 7 && startCol == 4 && endRow == 7 && endCol == 6) {
      boardState.board[7][5] = boardState.board[7][7];
      boardState.board[7][7] = null;
      boardState.whiteRightRookMoved = true;
    }
    // White queenside
    else if (isWhite && startRow == 7 && startCol == 4 && endRow == 7 && endCol == 2) {
      boardState.board[7][3] = boardState.board[7][0];
      boardState.board[7][0] = null;
      boardState.whiteLeftRookMoved = true;
    }
    // Black kingside
    else if (!isWhite && startRow == 0 && startCol == 4 && endRow == 0 && endCol == 6) {
      boardState.board[0][5] = boardState.board[0][7];
      boardState.board[0][7] = null;
      boardState.blackRightRookMoved = true;
    }
    // Black queenside
    else if (!isWhite && startRow == 0 && startCol == 4 && endRow == 0 && endCol == 2) {
      boardState.board[0][3] = boardState.board[0][0];
      boardState.board[0][0] = null;
      boardState.blackLeftRookMoved = true;
    }
  }
}
