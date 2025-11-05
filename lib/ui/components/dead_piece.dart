import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const DeadPiece({super.key, required this.imagePath, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      child: Opacity(
        opacity: 0.6,
        child: SvgPicture.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}

