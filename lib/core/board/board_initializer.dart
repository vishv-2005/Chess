import 'package:chess/ui/components/piece.dart';

/// Handles initialization of the chess board with starting positions
class BoardInitializer {
  /// Initializes the board with all pieces in their starting positions
  static List<List<ChessPiece?>> initializeBoard() {
    // Initialize the board with nulls, meaning no pieces in those positions
    List<List<ChessPiece?>> newBoard = List.generate(
      8,
      (index) => List.generate(8, (index) => null),
    );

    // Place pawns
    for (int i = 0; i < 8; i++) {
      newBoard[1][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: false,
        imagePath: 'lib/assets/bP.svg',
      );

      newBoard[6][i] = ChessPiece(
        type: ChessPieceType.pawn,
        isWhite: true,
        imagePath: 'lib/assets/wP.svg',
      );
    }

    // Place rooks
    newBoard[0][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/assets/bR.svg',
    );
    newBoard[0][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: false,
      imagePath: 'lib/assets/bR.svg',
    );

    newBoard[7][0] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/assets/wR.svg',
    );
    newBoard[7][7] = ChessPiece(
      type: ChessPieceType.rook,
      isWhite: true,
      imagePath: 'lib/assets/wR.svg',
    );

    // Place knights
    newBoard[0][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/assets/bN.svg',
    );
    newBoard[0][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: false,
      imagePath: 'lib/assets/bN.svg',
    );

    newBoard[7][1] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/assets/wN.svg',
    );
    newBoard[7][6] = ChessPiece(
      type: ChessPieceType.knight,
      isWhite: true,
      imagePath: 'lib/assets/wN.svg',
    );

    // Place bishops
    newBoard[0][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/assets/bB.svg',
    );
    newBoard[0][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: false,
      imagePath: 'lib/assets/bB.svg',
    );

    newBoard[7][2] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/assets/wB.svg',
    );
    newBoard[7][5] = ChessPiece(
      type: ChessPieceType.bishop,
      isWhite: true,
      imagePath: 'lib/assets/wB.svg',
    );

    // Place queens
    newBoard[0][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: false,
      imagePath: 'lib/assets/bQ.svg',
    );
    newBoard[7][3] = ChessPiece(
      type: ChessPieceType.queen,
      isWhite: true,
      imagePath: 'lib/assets/wQ.svg',
    );

    // Place kings
    newBoard[0][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: false,
      imagePath: 'lib/assets/bK.svg',
    );
    newBoard[7][4] = ChessPiece(
      type: ChessPieceType.king,
      isWhite: true,
      imagePath: 'lib/assets/wK.svg',
    );

    return newBoard;
  }
}

