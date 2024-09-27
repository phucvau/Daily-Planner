import 'package:daily_planner/TaskStatisticsScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'DarkMode.dart';

class SettingScreen extends StatelessWidget {
  final String uid; // Thêm thuộc tính uid

  SettingScreen({required this.uid}); // Constructor nhận uid

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(
          'Cài đặt',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                themeProvider.toggleTheme();
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Chủ đề tối/sáng',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                    Switch(
                      value: themeProvider.isDarkMode,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskStatisticsScreen(uid: uid), // Sử dụng uid từ constructor
                  ),
                );
              },
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: themeProvider.isDarkMode ? Colors.grey[850] : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  'Thống kê công việc',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),
            // Các phần tử khác trong danh sách...
          ],
        ),
      ),
    );
  }
}
