import 'package:daily_planner/LoginScreen.dart';
import 'package:flutter/material.dart';

class FirstScreen extends StatelessWidget {
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const SizedBox.shrink(), // Ẩn nút "Back"
      ),
      body: Container(
        color: Colors.white,
        child: Center(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Image.asset(
              'assets/images/img_1.png',
              width: 300,
              height: 250,
            ),
          ),
        ),
      ),
    );
  }
}
