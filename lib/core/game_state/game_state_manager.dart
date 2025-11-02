import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/game_state/check_detector.dart';
import 'package:chess/core/game_state/checkmate_detector.dart';
import 'package:chess/core/moves/move_validator.dart';
import 'package:chess/core/special_moves/castling.dart';

/// Manages overall game state and coordinates game flow
class GameStateManager {
  /// Update check status after a move
  static void updateCheckStatus(BoardState boardState) {
    boardState.checkStatus = CheckDetector.isKingInCheck(
      !boardState.isWhiteTurn,
      boardState.board,
      boardState.whiteKingPosition,
      boardState.blackKingPosition,
    );
  }

  /// Calculate valid moves for a selected piece
  static void calculateValidMoves(BoardState boardState) {
    if (boardState.selectedPiece == null) {
      boardState.validMoves = [];
      return;
    }

    // Get basic moves (already filtered by check)
    List<List<int>> validMoves = MoveValidator.calculateRealValidMoves(
      boardState.selectedRow,
      boardState.selectedCol,
      boardState.selectedPiece,
      true, // with check simulation
      boardState.board,
      boardState.whiteKingPosition,
      boardState.blackKingPosition,
    );

    // Add castling moves if it's a king (castling is already handled in move_validator)
    // But we need to check castling eligibility separately
    if (boardState.selectedPiece!.type == ChessPieceType.king) {
      List<List<int>> castlingMoves = Castling.getCastlingMoves(
        boardState.selectedRow,
        boardState.selectedCol,
        boardState.selectedPiece!,
        boardState.board,
        boardState,
      );
      
      // Filter castling moves for safety (path must be safe)
      for (var castlingMove in castlingMoves) {
        int direction = castlingMove[1] == 6 ? 1 : -1;
        bool pathSafe = true;
        
        for (int i = boardState.selectedCol; i != castlingMove[1] + direction; i += direction) {
          if (!MoveValidator.simulatedMoveIsSafe(
            boardState.selectedPiece!,
            boardState.selectedRow,
            boardState.selectedCol,
            boardState.selectedRow,
            i,
            boardState.board,
            boardState.whiteKingPosition,
            boardState.blackKingPosition,
          )) {
            pathSafe = false;
            break;
          }
        }
        
        if (pathSafe) {
          validMoves.add(castlingMove);
        }
      }
    }

    boardState.validMoves = validMoves;
  }

  /// Check if game is in checkmate
  static bool isCheckmate(BoardState boardState) {
    return CheckmateDetector.isCheckmate(
      !boardState.isWhiteTurn,
      boardState.board,
      boardState.whiteKingPosition,
      boardState.blackKingPosition,
    );
  }
}

