import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class DeadPiece extends StatelessWidget {
  final String imagePath;
  final bool isWhite;
  const DeadPiece({super.key, required this.imagePath, required this.isWhite});

  @override
  Widget build(BuildContext context) {
    return Opacity(opacity: 0.7, child: SvgPicture.asset(imagePath));
  }
}
