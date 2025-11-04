import 'package:chess/ui/components/piece.dart';

/// Pawn promotion logic
class PawnPromotion {
  /// Check if a pawn should be promoted (reached the 8th rank)
  static bool shouldPromote(int row, ChessPiece piece) {
    if (piece.type != ChessPieceType.pawn) return false;
    
    // White pawns promote on row 0, black pawns on row 7
    if (piece.isWhite && row == 0) return true;
    if (!piece.isWhite && row == 7) return true;
    
    return false;
  }

  /// Promote pawn to a chosen piece (Queen, Rook, Bishop, or Knight)
  static ChessPiece promotePawn(ChessPiece pawn, ChessPieceType promotionType) {
    String imagePath;
    String colorPrefix = pawn.isWhite ? 'w' : 'b';
    
    switch (promotionType) {
      case ChessPieceType.queen:
        imagePath = 'lib/assets/${colorPrefix}Q.svg';
        break;
      case ChessPieceType.rook:
        imagePath = 'lib/assets/${colorPrefix}R.svg';
        break;
      case ChessPieceType.bishop:
        imagePath = 'lib/assets/${colorPrefix}B.svg';
        break;
      case ChessPieceType.knight:
        imagePath = 'lib/assets/${colorPrefix}N.svg';
        break;
      default:
        imagePath = 'lib/assets/${colorPrefix}Q.svg'; // Default to queen
    }

    return ChessPiece(
      type: promotionType,
      isWhite: pawn.isWhite,
      imagePath: imagePath,
    );
  }
}

