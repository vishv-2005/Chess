import 'package:flutter/material.dart';

/// Theme constants and colors for the chess application
class AppTheme {
  // Board colors
  static const lightSquare = Color(0xFFF0D9B5);
  static const darkSquare = Color(0xFFB58863);
  static const backgroundColor = Color(0xFF2C3E50);
  static const foregroundColor = Color(0xFFECF0F1);
  
  // Square states
  static const selectedSquare = Color(0xFF3498DB);
  static const candidateSquare = Color(0xFF5DADE2);
  static const lastMoveSquare = Color(0xFFF39C12);
  static const checkSquare = Color(0xFFE74C3C);
  
  // UI elements
  static const primaryColor = Color(0xFF34495E);
  static const accentColor = Color(0xFF1ABC9C);
  static const textColor = Color(0xFF2C3E50);
  static const textColorLight = Color(0xFFECF0F1);
  
  // Gradients
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF34495E), Color(0xFF2C3E50)],
  );
  
  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1ABC9C), Color(0xFF16A085)],
  );
  
  // Text styles
  static const TextStyle titleStyle = TextStyle(
    fontSize: 48,
    fontWeight: FontWeight.bold,
    color: textColorLight,
    letterSpacing: 2,
  );
  
  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w300,
    color: textColorLight,
    letterSpacing: 1,
  );
  
  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    letterSpacing: 1,
  );
}

