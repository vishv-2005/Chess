import 'package:flutter/material.dart';
import 'package:chess/ui/components/piece.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess/ui/themes/app_theme.dart';

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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppTheme.primaryGradient,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Choose Promotion Piece',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColorLight,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Queen
                Expanded(
                  child: _buildPromotionOption(
                    context,
                    ChessPieceType.queen,
                    'lib/assets/${colorPrefix}Q.svg',
                    'Queen',
                  ),
                ),
                const SizedBox(width: 8),
                // Rook
                Expanded(
                  child: _buildPromotionOption(
                    context,
                    ChessPieceType.rook,
                    'lib/assets/${colorPrefix}R.svg',
                    'Rook',
                  ),
                ),
                const SizedBox(width: 8),
                // Bishop
                Expanded(
                  child: _buildPromotionOption(
                    context,
                    ChessPieceType.bishop,
                    'lib/assets/${colorPrefix}B.svg',
                    'Bishop',
                  ),
                ),
                const SizedBox(width: 8),
                // Knight
                Expanded(
                  child: _buildPromotionOption(
                    context,
                    ChessPieceType.knight,
                    'lib/assets/${colorPrefix}N.svg',
                    'Knight',
                  ),
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
    String label,
  ) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop(pieceType);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: AppTheme.accentColor.withOpacity(0.2),
          border: Border.all(
            color: AppTheme.accentColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SvgPicture.asset(
                imagePath,
                width: 50,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 6),
            Flexible(
              child: Text(
                label,
                style: const TextStyle(
                  color: AppTheme.textColorLight,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

