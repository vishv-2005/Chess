import 'package:chess/core/board/board_state.dart';
import 'package:chess/ui/components/piece.dart';

class Fen {
  /// Encode current board state into a FEN string suitable for UCI
  static String encode(BoardState state) {
    final board = state.board;

    // Piece placement
    List<String> ranks = [];
    for (int r = 0; r < 8; r++) {
      int empty = 0;
      String rank = '';
      for (int c = 0; c < 8; c++) {
        final piece = board[r][c];
        if (piece == null) {
          empty++;
        } else {
          if (empty > 0) {
            rank += empty.toString();
            empty = 0;
          }
          rank += _pieceToChar(piece);
        }
      }
      if (empty > 0) rank += empty.toString();
      ranks.add(rank);
    }
    final placement = ranks.join('/');

    // Active color
    final active = state.isWhiteTurn ? 'w' : 'b';

    // Castling rights
    final StringBuffer castling = StringBuffer();
    if (!state.whiteKingMoved) {
      if (!state.whiteRightRookMoved) castling.write('K');
      if (!state.whiteLeftRookMoved) castling.write('Q');
    }
    if (!state.blackKingMoved) {
      if (!state.blackRightRookMoved) castling.write('k');
      if (!state.blackLeftRookMoved) castling.write('q');
    }
    final castle = castling.isEmpty ? '-' : castling.toString();

    // En-passant target square
    final ep = state.enPassantTarget == null
        ? '-'
        : _toAlgebraic(state.enPassantTarget![0], state.enPassantTarget![1]);

    // Halfmove clock and fullmove number (simplified)
    final halfmove = '0';
    final fullmove = '1';

    return '$placement $active $castle $ep $halfmove $fullmove';
  }

  static String _pieceToChar(ChessPiece p) {
    String ch;
    switch (p.type) {
      case ChessPieceType.king:
        ch = 'k';
        break;
      case ChessPieceType.queen:
        ch = 'q';
        break;
      case ChessPieceType.rook:
        ch = 'r';
        break;
      case ChessPieceType.bishop:
        ch = 'b';
        break;
      case ChessPieceType.knight:
        ch = 'n';
        break;
      case ChessPieceType.pawn:
        ch = 'p';
        break;
    }
    return p.isWhite ? ch.toUpperCase() : ch;
  }

  static String _toAlgebraic(int row, int col) {
    final file = String.fromCharCode('a'.codeUnitAt(0) + col);
    final rank = (8 - row).toString();
    return '$file$rank';
  }
}


