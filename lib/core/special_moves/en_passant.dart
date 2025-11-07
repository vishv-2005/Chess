import 'package:chess/core/board/board_state.dart';
import 'package:chess/ui/components/piece.dart';

class EnPassant {
  static List<int>? computeEnPassantTargetForTwoSquarePawnMove(
      int startRow, int endRow, int endCol, ChessPiece piece) {
    if (piece.type != ChessPieceType.pawn) return null;
    if ((startRow - endRow).abs() == 2) {
      int targetRow = (startRow + endRow) ~/ 2;
      return [targetRow, endCol];
    }
    return null;
  }

  static bool isEnPassantCapture(
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      BoardState boardState,
      ) {
    ChessPiece? mover = boardState.board[startRow][startCol];
    if (mover == null || mover.type != ChessPieceType.pawn) return false;
    if (boardState.enPassantTarget == null || boardState.enPassantPawn == null) return false;
    List<int> target = boardState.enPassantTarget!;
    return (endRow == target[0] && endCol == target[1] && boardState.board[endRow][endCol] == null);
  }

  static void performEnPassantCapture(
      int startRow,
      int startCol,
      int endRow,
      int endCol,
      BoardState boardState,
      ) {
    if (!isEnPassantCapture(startRow, startCol, endRow, endCol, boardState)) return;

    List<int> capturedPawnPos = boardState.enPassantPawn!;
    boardState.board[capturedPawnPos[0]][capturedPawnPos[1]] = null;

    ChessPiece? mover = boardState.board[startRow][startCol];
    boardState.board[endRow][endCol] = mover;
    boardState.board[startRow][startCol] = null;
    boardState.clearEnPassant();
  }
}
