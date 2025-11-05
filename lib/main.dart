import 'package:flutter/material.dart';
import 'package:chess/ui/screens/menu_screen.dart';
import 'package:chess/ui/themes/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Chess',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primaryColor,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const MenuScreen(),
    );
  }
}
