import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/moves/move_calculator.dart';
import 'package:chess/core/game_state/check_detector.dart';

/// Validates moves by checking if they would leave the king in check
class MoveValidator {
  /// Calculate real valid moves (filtered by check validation)
  static List<List<int>> calculateRealValidMoves(
    int row,
    int col,
    ChessPiece? piece,
    bool checkSimulation,
    List<List<ChessPiece?>> board,
    List<int> whiteKingPosition,
    List<int> blackKingPosition,
  ) {
    List<List<int>> realValidMoves = [];
    List<List<int>> candidateMoves = MoveCalculator.calculateRawValidMoves(
      row,
      col,
      piece,
      board,
    );

    // after generating all candidate moves, filter out any that would result in a check
    if (checkSimulation) {
      for (var move in candidateMoves) {
        int endRow = move[0];
        int endCol = move[1];

        // this will simulate the future move to see if it's safe
        if (simulatedMoveIsSafe(
          piece!,
          row,
          col,
          endRow,
          endCol,
          board,
          whiteKingPosition,
          blackKingPosition,
        )) {
          // check if the move is castling
          if (piece.type == ChessPieceType.king &&
              col == 4 &&
              (endCol == 6 || endCol == 2)) {
            int direction = endCol == 6 ? 1 : -1;

            bool pathSafe = true;

            for (int i = col; i != endCol + direction; i += direction) {
              if (!simulatedMoveIsSafe(
                piece,
                row,
                col,
                endRow,
                i,
                board,
                whiteKingPosition,
                blackKingPosition,
              )) {
                pathSafe = false;
              }
            }

            if (pathSafe) realValidMoves.add(move);
          } else {
            realValidMoves.add(move);
          }
        }
      }
    } else {
      realValidMoves = candidateMoves;
    }

    return realValidMoves;
  }

  /// Simulate a future move to see if it's safe (doesn't put your own king under attack)
  static bool simulatedMoveIsSafe(
    ChessPiece piece,
    int startRow,
    int startCol,
    int endRow,
    int endCol,
    List<List<ChessPiece?>> board,
    List<int> whiteKingPosition,
    List<int> blackKingPosition,
  ) {
    // save the current board state
    ChessPiece? originalDestinationPiece = board[endRow][endCol];

    // if the piece is the king, save its current position and update to the new one
    List<int> simulatedWhiteKingPosition = List.from(whiteKingPosition);
    List<int> simulatedBlackKingPosition = List.from(blackKingPosition);
    
    if (piece.type == ChessPieceType.king) {
      // update the king position (create a copy for simulation)
      if (piece.isWhite) {
        simulatedWhiteKingPosition = [endRow, endCol];
      } else {
        simulatedBlackKingPosition = [endRow, endCol];
      }
    }

    // simulate the move
    board[endRow][endCol] = piece;
    board[startRow][startCol] = null;

    // check if our own king is under attack
    bool kingInCheck = CheckDetector.isKingInCheck(
      piece.isWhite,
      board,
      simulatedWhiteKingPosition,
      simulatedBlackKingPosition,
    );

    // restore board to original state
    board[startRow][startCol] = piece;
    board[endRow][endCol] = originalDestinationPiece;

    // if king is in check = true, means it's not safe. safe move = false
    return !kingInCheck;
  }
}

