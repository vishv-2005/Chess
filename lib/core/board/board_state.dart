import 'package:chess/ui/components/piece.dart';

/// Manages the complete state of the chess game board
class BoardState {
  // The 8x8 chess board
  List<List<ChessPiece?>> board;

  // Currently selected piece on the chess board
  // if no piece is selected, this is null
  ChessPiece? selectedPiece;

  // The row and col index of the selected piece
  // default value -1 indicates no piece is currently selected
  int selectedRow = -1;
  int selectedCol = -1;

  // A list of valid moves for the currently selected piece
  // each move is represented with rows and cols
  List<List<int>> validMoves = [];

  // A list of white pieces that have been taken by the black player
  List<ChessPiece> whitePiecesTaken = [];

  // A list of black pieces that have been taken by the white player
  List<ChessPiece> blackPiecesTaken = [];

  // A boolean to indicate whose turn it is
  bool isWhiteTurn = true;

  // Initial position of kings (keep track of this to make it easier later to see if king is in check)
  List<int> whiteKingPosition = [7, 4];
  List<int> blackKingPosition = [0, 4];
  bool checkStatus = false;

  // Game over state
  bool gameOver = false;
  bool? winnerIsWhite; // null if game not over, true if white won, false if black won

  // Castling conditions
  bool whiteKingMoved = false;
  bool blackKingMoved = false;
  bool whiteLeftRookMoved = false;
  bool whiteRightRookMoved = false;
  bool blackLeftRookMoved = false;
  bool blackRightRookMoved = false;

  BoardState({required this.board});

  /// Reset all state to initial values (keeps board structure)
  void resetToInitialState() {
    selectedPiece = null;
    selectedRow = -1;
    selectedCol = -1;
    validMoves = [];
    whitePiecesTaken.clear();
    blackPiecesTaken.clear();
    isWhiteTurn = true;
    whiteKingPosition = [7, 4];
    blackKingPosition = [0, 4];
    checkStatus = false;
    gameOver = false;
    winnerIsWhite = null;
    whiteKingMoved = false;
    blackKingMoved = false;
    whiteLeftRookMoved = false;
    whiteRightRookMoved = false;
    blackLeftRookMoved = false;
    blackRightRookMoved = false;
  }
}

