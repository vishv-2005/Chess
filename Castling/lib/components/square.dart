import 'package:flutter/material.dart';
import 'package:passant/components/piece.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:passant/values/colors.dart';

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

    // if selected, square is yellow
    if (isSelected) {
      squareColor = selectedSquare;
    } else if (isValidMove) {
      squareColor = candidateSquare;
    } else {
      squareColor = isWhite ? foregroundColor : backgroundColor;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: squareColor,
        // margin: EdgeInsets.all(isValidMove ? 3 : 0),
        child: piece != null ? SvgPicture.asset(piece!.imagePath) : null,
      ),
    );
  }
}
