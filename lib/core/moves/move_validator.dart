import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/moves/move_calculator.dart';
import 'package:chess/core/game_state/check_detector.dart';
import 'package:chess/core/board/board_state.dart';
import 'package:chess/core/special_moves/en_passant.dart';
import 'package:chess/core/special_moves/castling.dart';

/// Validates moves by checking if they would leave the king in check
class MoveValidator {
  /// Calculate real valid moves (filtered by check validation)
  ///
  /// NOTE: Now accepts BoardState so we can consider en-passant state.
  static List<List<int>> calculateRealValidMoves(
      int row,
      int col,
      ChessPiece? piece,
      bool checkSimulation,
      BoardState boardState,
      ) {
    List<List<int>> candidateMoves = MoveCalculator.calculateRawValidMoves(
      row,
      col,
      piece,
      boardState.board,
    );

    // Add castling candidates for king
    if (piece != null && piece.type == ChessPieceType.king && !checkSimulation) {
      candidateMoves.addAll(
        Castling.getCastlingMoves(row, col, piece, boardState.board, boardState),
      );
    }

    // Add en-passant candidate if applicable:
    if (piece != null && piece.type == ChessPieceType.pawn) {
      int direction = piece.isWhite ? -1 : 1;
      // potential en-passant captures are to diagonally adjacent columns
      for (int dc in [-1, 1]) {
        int targetRow = row + direction;
        int targetCol = col + dc;
        // Make sure target is in board bounds
        if (targetRow < 0 || targetRow > 7 || targetCol < 0 || targetCol > 7) {
          continue;
        }
        // If enPassantTarget matches this square, allow it as a candidate
        if (boardState.enPassantTarget != null &&
            boardState.enPassantTarget![0] == targetRow &&
            boardState.enPassantTarget![1] == targetCol) {
          // ensure square is empty (it should be for en-passant)
          if (boardState.board[targetRow][targetCol] == null) {
            candidateMoves.add([targetRow, targetCol]);
          }
        }
      }
    }

    // Filter out moves that would leave player's king in check (if not checkSimulation)
    List<List<int>> realValidMoves = [];
    for (var move in candidateMoves) {
      int endRow = move[0];
      int endCol = move[1];

      if (checkSimulation) {
        // If we are just generating without check simulation
        realValidMoves.add(move);
        continue;
      }

      if (_isMoveSafe(row, col, endRow, endCol, piece, boardState)) {
        realValidMoves.add(move);
      }
    }

    return realValidMoves;
  }

  /// Returns true if the move (startRow,startCol -> endRow,endCol) would not leave
  /// the player's king in check.
  static bool _isMoveSafe(
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      ChessPiece? piece,
      BoardState boardState,
      ) {
    // Save original pieces
    ChessPiece? originalStartPiece = boardState.board[startRow][startCol];
    ChessPiece? originalEndPiece = boardState.board[endRow][endCol];

    // Also save en-passant state (because we may simulate en-passant capture)
    List<int>? savedEnPassantTarget = boardState.enPassantTarget == null
        ? null
        : List<int>.from(boardState.enPassantTarget!);
    List<int>? savedEnPassantPawn = boardState.enPassantPawn == null
        ? null
        : List<int>.from(boardState.enPassantPawn!);

    // Simulate the move
    bool simulatedEnPassantCapture = EnPassant.isEnPassantCapture(
      startRow,
      startCol,
      endRow,
      endCol,
      boardState,
    );

    // If en-passant capture, remove the captured pawn from its square for the simulation
    ChessPiece? capturedPawnBackup;
    List<int>? capturedPawnPos;
    if (simulatedEnPassantCapture) {
      capturedPawnPos = List<int>.from(boardState.enPassantPawn!);
      capturedPawnBackup = boardState.board[capturedPawnPos[0]][capturedPawnPos[1]];
      boardState.board[capturedPawnPos[0]][capturedPawnPos[1]] = null;
    }

    // Move piece on the board
    boardState.board[endRow][endCol] = boardState.board[startRow][startCol];
    boardState.board[startRow][startCol] = null;

    // Update king position if king moved (for check evaluation)
    List<int> savedWhiteKing = List<int>.from(boardState.whiteKingPosition);
    List<int> savedBlackKing = List<int>.from(boardState.blackKingPosition);
    if (boardState.board[endRow][endCol]?.type == ChessPieceType.king) {
      if (boardState.board[endRow][endCol]!.isWhite) {
        boardState.whiteKingPosition = [endRow, endCol];
      } else {
        boardState.blackKingPosition = [endRow, endCol];
      }
    }

    // Run check detection for the player who moved (we need to know which king to test)
    bool kingInCheck = CheckDetector.isKingInCheck(
      boardState.board[endRow][endCol]?.isWhite ?? false,
      boardState,
    );

    // Restore board and en-passant state
    boardState.board[startRow][startCol] = originalStartPiece;
    boardState.board[endRow][endCol] = originalEndPiece;

    // restore captured pawn if simulation removed it
    if (simulatedEnPassantCapture && capturedPawnPos != null) {
      boardState.board[capturedPawnPos[0]][capturedPawnPos[1]] = capturedPawnBackup;
    }

    // restore king positions
    boardState.whiteKingPosition = savedWhiteKing;
    boardState.blackKingPosition = savedBlackKing;

    // restore en-passant
    boardState.enPassantTarget = savedEnPassantTarget;
    boardState.enPassantPawn = savedEnPassantPawn;

    // if king is in check = true, the move is unsafe
    return !kingInCheck;
  }
}
