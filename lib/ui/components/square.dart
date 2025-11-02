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

  const Square({
    super.key,
    required this.isWhite,
    required this.piece,
    required this.isSelected,
    required this.onTap,
    required this.isValidMove,
  });

  @override
  Widget build(BuildContext context) {
    Color? squareColor;

    // if selected, square is blue-grey
    if (isSelected) {
      squareColor = AppTheme.selectedSquare;
    } else if (isValidMove) {
      squareColor = AppTheme.candidateSquare;
    } else {
      squareColor = isWhite ? AppTheme.foregroundColor : AppTheme.backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        child: piece != null ? SvgPicture.asset(piece!.imagePath) : null,
      ),
    );
  }
}

