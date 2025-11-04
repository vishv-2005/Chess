import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/special_moves/castling.dart';
import 'package:chess/core/special_moves/pawn_promotion.dart';

/// Executes moves on the chess board
class MoveExecutor {
  /// Execute a move on the board
  /// Returns true if pawn promotion is needed, false otherwise
  static bool executeMove(
    int startRow,
    int startCol,
    int endRow,
    int endCol,
    BoardState boardState,
  ) {
    // if the new spot has an enemy piece, add it to captured pieces
    if (boardState.board[endRow][endCol] != null) {
      var capturedPiece = boardState.board[endRow][endCol];
      if (capturedPiece!.isWhite) {
        boardState.whitePiecesTaken.add(capturedPiece);
      } else {
        boardState.blackPiecesTaken.add(capturedPiece);
      }
    }

    // check if the piece being moved is the king
    if (boardState.selectedPiece!.type == ChessPieceType.king) {
      // update the appropriate king position
      if (boardState.selectedPiece!.isWhite) {
        boardState.whiteKingMoved = true;

        // Check for castling
        if (Castling.isCastlingMove(startRow, startCol, endRow, endCol)) {
          Castling.executeCastling(
            startRow,
            startCol,
            endRow,
            endCol,
            boardState.board,
            boardState,
          );
        }

        boardState.whiteKingPosition = [endRow, endCol];
      } else {
        boardState.blackKingMoved = true;

        // Check for castling
        if (Castling.isCastlingMove(startRow, startCol, endRow, endCol)) {
          Castling.executeCastling(
            startRow,
            startCol,
            endRow,
            endCol,
            boardState.board,
            boardState,
          );
        }

        boardState.blackKingPosition = [endRow, endCol];
      }
    }

    // Track rook movements for castling eligibility
    if (boardState.selectedPiece!.type == ChessPieceType.rook) {
      if (boardState.selectedPiece!.isWhite) {
        if (startRow == 7 && startCol == 0) boardState.whiteLeftRookMoved = true;
        if (startRow == 7 && startCol == 7) boardState.whiteRightRookMoved = true;
      } else {
        if (startRow == 0 && startCol == 0) boardState.blackLeftRookMoved = true;
        if (startRow == 0 && startCol == 7) boardState.blackRightRookMoved = true;
      }
    }

    // move the piece and clear the old spot
    boardState.board[endRow][endCol] = boardState.selectedPiece;
    boardState.board[startRow][startCol] = null;

    // Check for pawn promotion (before clearing selection)
    bool needsPromotion = PawnPromotion.shouldPromote(endRow, boardState.selectedPiece!);
    
    // clear selection
    boardState.selectedPiece = null;
    boardState.selectedRow = -1;
    boardState.selectedCol = -1;
    boardState.validMoves = [];

    // change turns (only if not promoting, promotion will handle turn change)
    if (!needsPromotion) {
      boardState.isWhiteTurn = !boardState.isWhiteTurn;
    }
    
    // Return whether promotion is needed
    return needsPromotion;
  }

  /// Apply promotion to a pawn at the given position
  static void applyPromotion(
    int row,
    int col,
    ChessPieceType promotionType,
    BoardState boardState,
  ) {
    if (boardState.board[row][col] == null) return;
    
    ChessPiece? pawn = boardState.board[row][col];
    if (pawn == null || pawn.type != ChessPieceType.pawn) return;
    
    // Replace pawn with promoted piece
    boardState.board[row][col] = PawnPromotion.promotePawn(pawn, promotionType);
    
    // Change turns after promotion
    boardState.isWhiteTurn = !boardState.isWhiteTurn;
  }
}

