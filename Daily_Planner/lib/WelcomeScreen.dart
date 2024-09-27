import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image.asset('assets/logo.png', height: 150), // Logo
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/login'); // Chuyển sang màn hình đăng nhập
              },
              child: Text('Đăng nhập'),
            ),
          ],
        ),
      ),
    );
  }
}
