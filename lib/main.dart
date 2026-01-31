import 'package:flutter/material.dart';
import 'ui/home/home_screen.dart'; // Импортируем главный экран

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Убирает надпись Debug в углу
      title: 'My App',
      home: const HomeScreen(), // Указываем, что стартуем с Home
    );
  }
}