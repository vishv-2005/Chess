import 'package:flutter/material.dart';
import 'package:chess/ui/components/piece.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Dialog for selecting a piece to promote a pawn to
class PromotionDialog extends StatelessWidget {
  final bool isWhite;

  const PromotionDialog({
    super.key,
    required this.isWhite,
  });

  @override
  Widget build(BuildContext context) {
    String colorPrefix = isWhite ? 'w' : 'b';
    
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Promotion Piece',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Queen
                _buildPromotionOption(
                  context,
                  ChessPieceType.queen,
                  'lib/assets/${colorPrefix}Q.svg',
                ),
                // Rook
                _buildPromotionOption(
                  context,
                  ChessPieceType.rook,
                  'lib/assets/${colorPrefix}R.svg',
                ),
                // Bishop
                _buildPromotionOption(
                  context,
                  ChessPieceType.bishop,
                  'lib/assets/${colorPrefix}B.svg',
                ),
                // Knight
                _buildPromotionOption(
                  context,
                  ChessPieceType.knight,
                  'lib/assets/${colorPrefix}N.svg',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromotionOption(
    BuildContext context,
    ChessPieceType pieceType,
    String imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(pieceType);
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SvgPicture.asset(
          imagePath,
          width: 50,
          height: 50,
        ),
      ),
    );
  }
}

