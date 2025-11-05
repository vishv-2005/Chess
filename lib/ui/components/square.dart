import 'package:flutter/material.dart';
import 'package:chess/ui/components/piece.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:chess/ui/themes/app_theme.dart';

class Square extends StatelessWidget {
  final bool isWhite;
  final ChessPiece? piece;
  final bool isSelected;
  final bool isValidMove;
  final void Function()? onTap;
  final String? coordinateLabel;
  final bool isInCheck;

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.isValidMove,
    required this.onTap,
    this.coordinateLabel,
    this.isInCheck = false,
  });

  @override
  Widget build(BuildContext context) {
    Color squareColor;
    
    // Determine base square color
    if (isSelected) {
      squareColor = AppTheme.selectedSquare;
    } else {
      squareColor = isWhite ? AppTheme.lightSquare : AppTheme.darkSquare;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: squareColor,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : null,
        ),
        child: Stack(
          children: [
            // Valid move indicator
            if (isValidMove && !isSelected)
              Center(
                child: Container(
                  width: piece != null ? 40 : 20,
                  height: piece != null ? 40 : 20,
                  decoration: BoxDecoration(
                    shape: piece != null ? BoxShape.rectangle : BoxShape.circle,
                    color: piece != null
                        ? Colors.red.withOpacity(0.5)
                        : AppTheme.candidateSquare.withOpacity(0.6),
                    borderRadius: piece != null
                        ? BorderRadius.circular(8)
                        : null,
                  ),
                ),
              ),
            
            // Piece
            if (piece != null)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: SvgPicture.asset(
                    piece!.imagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

