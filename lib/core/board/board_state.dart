import 'package:chess/ui/components/piece.dart';
import 'package:chess/core/board/board_initializer.dart';

/// Manages the complete state of the chess game board
class BoardState {
  // The 8x8 chess board
  List<List<ChessPiece?>> board;

  // Currently selected piece on the chess board
  ChessPiece? selectedPiece;

  // The row and col index of the selected piece
  int selectedRow = -1;
  int selectedCol = -1;

  // Valid moves for the currently selected piece
  List<List<int>> validMoves = [];

  // Who's turn it is
  bool isWhiteTurn = true;

  // King positions
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];

  // Game status
  bool checkStatus = false;
  bool gameOver = false;
  bool? winnerIsWhite;

  // Movement flags (useful for castling)
  bool whiteKingMoved = false;
  bool blackKingMoved = false;
  bool whiteLeftRookMoved = false;
  bool whiteRightRookMoved = false;
  bool blackLeftRookMoved = false;
  bool blackRightRookMoved = false;

  // --- En-passant support ---
  List<int>? enPassantTarget;
  List<int>? enPassantPawn;

  // Taken pieces (for UI)
  List<ChessPiece> whitePiecesTaken = [];
  List<ChessPiece> blackPiecesTaken = [];

  // Last move (for UI highlight)
  List<int>? lastMoveFrom;
  List<int>? lastMoveTo;

  // Play vs computer settings
  bool playVsComputer = false;
  bool computerIsWhite = false;

  // Constructor: accept named param 'board' for compatibility with callers
  BoardState({List<List<ChessPiece?>>? board})
      : board = board ?? BoardInitializer.initializeBoard();

  /// Reset en-passant availability (called after any move that removes the ability)
  void clearEnPassant() {
    enPassantTarget = null;
    enPassantPawn = null;
  }
}
