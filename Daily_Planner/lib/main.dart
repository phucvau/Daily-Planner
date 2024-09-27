import 'package:daily_planner/first_screen.dart';
import 'package:daily_planner/test.dart';
import 'package:daily_planner/test2.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart'; // Thêm import cho provider

import 'AddTaskScreen.dart';
import 'DarkMode.dart';
import 'LoginScreen.dart';
import 'RegisterScreen.dart';
import 'TaskListScreen.dart';
import 'TaskStatisticsScreen.dart';
import 'WelcomeScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('vi', null);

  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeProvider(), // Khởi tạo ThemeProvider
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context); // Lấy trạng thái từ ThemeProvider

    return MaterialApp(
      title: 'Task Manager',
      debugShowCheckedModeBanner: false,
      theme: themeProvider.isDarkMode ? ThemeData.dark() : ThemeData.light(), // Chọn theme
      home: FirstScreen(),
      routes: {
        '/taskList': (context) => TaskListScreen(uid: ''),
        '/addTask': (context) => AddTaskScreen(),
      },
    );
  }
}
