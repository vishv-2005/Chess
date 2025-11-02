import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/board/board_state.dart';

/// Handles castling logic for both kingside and queenside
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

    if (piece.isWhite) {
      if (!boardState.whiteKingMoved && row == 7 && col == 4) {
        // King side castle
        if (!boardState.whiteRightRookMoved &&
            board[7][7] != null &&
            board[7][7]!.type == ChessPieceType.rook &&
            board[7][7]!.isWhite &&
            board[7][6] == null &&
            board[7][5] == null) {
          castlingMoves.add([7, 6]);
        }

        // Queen side castle
        if (!boardState.whiteLeftRookMoved &&
            board[7][0] != null &&
            board[7][0]!.type == ChessPieceType.rook &&
            board[7][0]!.isWhite &&
            board[7][3] == null &&
            board[7][2] == null &&
            board[7][1] == null) {
          castlingMoves.add([7, 2]);
        }
      }
    } else {
      if (!boardState.blackKingMoved && row == 0 && col == 4) {
        // Kingside castling (to [0,6])
        if (!boardState.blackRightRookMoved &&
            board[0][7] != null &&
            board[0][7]!.type == ChessPieceType.rook &&
            !board[0][7]!.isWhite &&
            board[0][5] == null &&
            board[0][6] == null) {
          castlingMoves.add([0, 6]);
        }
        // Queenside castling (to [0,2])
        if (!boardState.blackLeftRookMoved &&
            board[0][0] != null &&
            board[0][0]!.type == ChessPieceType.rook &&
            !board[0][0]!.isWhite &&
            board[0][1] == null &&
            board[0][2] == null &&
            board[0][3] == null) {
          castlingMoves.add([0, 2]);
        }
      }
    }

    return castlingMoves;
  }

  /// Check if a move is a castling move
  static bool isCastlingMove(int startRow, int startCol, int endRow, int endCol) {
    // White kingside: [7,4] -> [7,6]
    if (startRow == 7 && startCol == 4 && endRow == 7 && endCol == 6) {
      return true;
    }
    // White queenside: [7,4] -> [7,2]
    if (startRow == 7 && startCol == 4 && endRow == 7 && endCol == 2) {
      return true;
    }
    // Black kingside: [0,4] -> [0,6]
    if (startRow == 0 && startCol == 4 && endRow == 0 && endCol == 6) {
      return true;
    }
    // Black queenside: [0,4] -> [0,2]
    if (startRow == 0 && startCol == 4 && endRow == 0 && endCol == 2) {
      return true;
    }
    return false;
  }

  /// Execute castling move
  static void executeCastling(
    int startRow,
    int startCol,
    int endRow,
    int endCol,
    List<List<ChessPiece?>> board,
    BoardState boardState,
  ) {
    if (boardState.selectedPiece!.isWhite) {
      // White kingside: move rook from [7,7] to [7,5]
      if (endRow == 7 && endCol == 6) {
        board[7][5] = board[7][7];
        board[7][7] = null;
        boardState.whiteRightRookMoved = true;
      }
      // White queenside: move rook from [7,0] to [7,3]
      else if (endRow == 7 && endCol == 2) {
        board[7][3] = board[7][0];
        board[7][0] = null;
        boardState.whiteLeftRookMoved = true;
      }
    } else {
      // Black kingside: move rook from [0,7] to [0,5]
      if (endRow == 0 && endCol == 6) {
        board[0][5] = board[0][7];
        board[0][7] = null;
        boardState.blackRightRookMoved = true;
      }
      // Black queenside: move rook from [0,0] to [0,3]
      else if (endRow == 0 && endCol == 2) {
        board[0][3] = board[0][0];
        board[0][0] = null;
        boardState.blackLeftRookMoved = true;
      }
    }
  }
}

