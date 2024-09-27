import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'CalendarScreen.dart';
import 'DarkMode.dart';
import 'SettingScreen.dart';
import 'TaskDetailScreen.dart';

class TaskListScreen extends StatefulWidget {
  final String uid;

  TaskListScreen({required this.uid});

  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');
  DateTime _selectedDate = DateTime.now(); // Current selected date

  int _currentIndex = 0; // Current tab index

  // List of screens
  final List<Widget> _pages = [];

  List<String> completedTasks = [];

  @override
  void initState() {
    super.initState();
    // Initialize list of screens
    _pages.add(this.widget); // TaskListScreen
    _pages.add(CalendarScreen(uid: widget.uid,));
    _pages.add(SettingScreen(uid: widget.uid,));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: _currentIndex == 0 ? _buildTaskList() : _pages[_currentIndex], // Show task list if _currentIndex is 0

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          Navigator.pushNamed(context, '/addTask'); // Navigate to add task screen
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Công việc',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Lịch',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Cài đặt',
          ),
        ],
        currentIndex: _currentIndex,
        selectedItemColor: Colors.white,
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update current tab index
          });
        },
      ),
    );
  }

  // Build task list method
  Widget _buildTaskList() {
    return Column(
      children: [
        // Header
        Container(
          height: 100,
          width: double.infinity,
          color: Colors.blue,
          padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Padding(
            padding: const EdgeInsets.only(top: 40), // Khoảng cách 20 đơn vị phía trên
            child: Text(
              'Danh sách công việc',
              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.left,
            ),
          ),
        ),

        // Horizontal date selector
        Container(
          color: Colors.white,
          height: 80,
          padding: EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 7, // Show 7 days
            itemBuilder: (context, index) {
              final DateTime currentDate = DateTime.now().add(Duration(days: index));
              final bool isSelected = currentDate.day == _selectedDate.day &&
                  currentDate.month == _selectedDate.month &&
                  currentDate.year == _selectedDate.year;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDate = currentDate; // Update selected date
                  });
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 8),
                  width: 60,
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue : Colors.grey[200],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        DateFormat.E('vi').format(currentDate), // Display day
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                      Text(
                        currentDate.day.toString(), // Display date
                        style: TextStyle(
                          fontSize: 16,
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),

        // Task list
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _tasksCollection
                .where('uid', isEqualTo: widget.uid) // Check user UID
                .where('status', isNotEqualTo: 'completed')  // Exclude completed tasks
                .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(
                DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day)))
                .where('date', isLessThan: Timestamp.fromDate(
                DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day + 1)))
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Có lỗi xảy ra: ${snapshot.error}'));
              }

              // Retrieve tasks from snapshot
              final tasks = snapshot.data?.docs ?? [];
              if (tasks.isEmpty) {
                return Center(child: Text('Không có công việc nào.')); // Show when there are no tasks
              }

              // Thay thế ListView.builder bằng ReorderableListView.builder
              return ReorderableListView.builder(
                itemCount: tasks.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    // Điều chỉnh newIndex nếu cần thiết
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }

                    // Lưu trữ task hiện tại và xóa nó ra khỏi vị trí cũ
                    final taskToMove = tasks.removeAt(oldIndex);
                    // Chèn task vào vị trí mới
                    tasks.insert(newIndex, taskToMove);

                    // Cập nhật thứ tự của các task trong Firestore
                    for (int i = 0; i < tasks.length; i++) {
                      _tasksCollection.doc(tasks[i].id).update({'order': i}).catchError((error) {
                        // Xử lý lỗi nếu có
                        print('Error updating order: $error');
                      });
                    }
                  });
                },
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  bool isCompleted = task['status'] == 'completed'; // Check task status

                  return Dismissible(
                    key: Key(task.id),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      color: Colors.greenAccent,
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 20),
                        child: Icon(Icons.check, color: Colors.white),
                      ),
                    ),
                    onDismissed: (direction) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Đang hoàn thành công việc...")),
                      );

                      Future.delayed(Duration(milliseconds: 200), () {
                        _tasksCollection.doc(task.id).update({'status': 'completed'}).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Công việc đã hoàn thành")),
                          );
                        });

                        // _tasksCollection.doc(task.id).delete();
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TaskDetailScreen(taskId: task.id),
                            ),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['content'] ?? 'N/A',
                                      style: TextStyle(color: Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Thời gian: ${task['startTime'] ?? 'N/A'} - ${task['endTime'] ?? 'N/A'}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Ngày: ${DateFormat('dd/MM/yyyy').format((task['date'] as Timestamp?)?.toDate() ?? DateTime.now())}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TaskDetailScreen(taskId: task.id),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      _tasksCollection.doc(task.id).delete();
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );


            },
          ),
        ),
      ],
    );
  }
}
