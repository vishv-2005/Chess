import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/special_moves/castling.dart';
import 'package:chess/core/special_moves/pawn_promotion.dart';
import 'package:chess/core/special_moves/en_passant.dart';

class MoveExecutor {
  static bool executeMove(
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      BoardState boardState,
      ) {
    ChessPiece? movingPiece = boardState.board[startRow][startCol];
    if (movingPiece == null) return false;

    // Track capture (normal capture) before moving
    ChessPiece? targetPiece = boardState.board[endRow][endCol];

    bool wasEnPassant = EnPassant.isEnPassantCapture(
      startRow,
      startCol,
      endRow,
      endCol,
      boardState,
    );

    if (wasEnPassant) {
      // Collect captured pawn
      if (boardState.enPassantPawn != null) {
        final capPos = boardState.enPassantPawn!;
        final capturedPawn = boardState.board[capPos[0]][capPos[1]];
        if (capturedPawn != null) {
          if (capturedPawn.isWhite) {
            boardState.whitePiecesTaken.add(capturedPawn);
          } else {
            boardState.blackPiecesTaken.add(capturedPawn);
          }
        }
      }
      EnPassant.performEnPassantCapture(startRow, startCol, endRow, endCol, boardState);
    } else {
      // If target square had an opponent piece, collect it
      if (targetPiece != null && targetPiece.isWhite != movingPiece.isWhite) {
        if (targetPiece.isWhite) {
          boardState.whitePiecesTaken.add(targetPiece);
        } else {
          boardState.blackPiecesTaken.add(targetPiece);
        }
      }
      // Move the moving piece
      boardState.board[endRow][endCol] = movingPiece;
      boardState.board[startRow][startCol] = null;

      // If this was a king move, handle the rook shift now that king has landed
      if (movingPiece.type == ChessPieceType.king) {
        Castling.applyCastlingIfNeeded(startRow, startCol, endRow, endCol, boardState);
      }
    }

    // Update moved flags
    ChessPiece? placed = boardState.board[endRow][endCol];
    if (placed != null && placed.type == ChessPieceType.king) {
      if (placed.isWhite) {
        boardState.whiteKingPosition = [endRow, endCol];
        boardState.whiteKingMoved = true;
      } else {
        boardState.blackKingPosition = [endRow, endCol];
        boardState.blackKingMoved = true;
      }
    }

    // If a rook moved from its original corner, set rook-moved flags
    if (movingPiece.type == ChessPieceType.rook) {
      if (movingPiece.isWhite) {
        if (startRow == 7 && startCol == 0) boardState.whiteLeftRookMoved = true;
        if (startRow == 7 && startCol == 7) boardState.whiteRightRookMoved = true;
      } else {
        if (startRow == 0 && startCol == 0) boardState.blackLeftRookMoved = true;
        if (startRow == 0 && startCol == 7) boardState.blackRightRookMoved = true;
      }
    }

    // En-passant setup
    boardState.clearEnPassant();
    if (movingPiece.type == ChessPieceType.pawn && (startRow - endRow).abs() == 2) {
      var target = EnPassant.computeEnPassantTargetForTwoSquarePawnMove(
          startRow, endRow, endCol, movingPiece);
      if (target != null) {
        boardState.enPassantTarget = target;
        boardState.enPassantPawn = [endRow, endCol];
      }
    }

    // Record last move to enhance UX
    boardState.lastMoveFrom = [startRow, startCol];
    boardState.lastMoveTo = [endRow, endCol];

    bool needsPromotion = false;
    if (placed != null && placed.type == ChessPieceType.pawn) {
      if ((placed.isWhite && endRow == 0) || (!placed.isWhite && endRow == 7)) {
        needsPromotion = true;
      }
    }

    boardState.selectedPiece = null;
    boardState.validMoves = [];
    if (!needsPromotion) boardState.isWhiteTurn = !boardState.isWhiteTurn;

    return needsPromotion;
  }

  static void applyPromotion(
      int row,
      int col,
      ChessPieceType type,
      BoardState boardState,
      ) {
    var pawn = boardState.board[row][col];
    if (pawn == null || pawn.type != ChessPieceType.pawn) return;
    boardState.board[row][col] = PawnPromotion.promotePawn(pawn, type);
    boardState.isWhiteTurn = !boardState.isWhiteTurn;
  }
}
