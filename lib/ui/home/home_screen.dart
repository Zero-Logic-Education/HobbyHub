import 'package:flutter/material.dart';
// Импортируем экран профиля. 
// '../' означает выйти из папки home, затем зайти в profile
import '../profile/profile_screen.dart'; 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Главная')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Переход на страницу профиля
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          child: const Text('Открыть профиль'),
        ),
      ),
    );
  }
}