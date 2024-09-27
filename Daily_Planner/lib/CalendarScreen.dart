import 'package:daily_planner/TaskListScreen.dart';
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

import 'SettingScreen.dart';
import 'TaskDetailScreen.dart';

class CalendarScreen extends StatefulWidget {

  final String uid;
  CalendarScreen({required this.uid});

  @override
  _CalendarScreenState createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _selectedDay = DateTime.now();
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');
  Set<DateTime> _markedDates = {};

  Map<DateTime, List<String>> _tasksForDay = {};


  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  void _fetchTasks() async {
    final snapshot = await _tasksCollection.get();
    final tasks = snapshot.docs;

    // Lấy các ngày có công việc và thêm vào _markedDates
    setState(() {
      _markedDates = tasks.map((task) {
        Timestamp timestamp = task['date'];
        return DateTime(timestamp.toDate().year, timestamp.toDate().month, timestamp.toDate().day);
      }).toSet();
    });

    QuerySnapshot tasksSnapshot = await FirebaseFirestore.instance.collection('tasks').get();

    // Ánh xạ dữ liệu công việc theo từng ngày
    Map<DateTime, List<String>> tasksForDay = {};

    for (var doc in tasksSnapshot.docs) {
      DateTime taskDate = (doc['date'] as Timestamp).toDate();
      String taskContent = doc['content'];

      // Làm tròn ngày về 00:00:00 để so sánh
      taskDate = DateTime(taskDate.year, taskDate.month, taskDate.day);

      // Kiểm tra xem ngày đã tồn tại chưa, nếu chưa thì thêm vào
      if (tasksForDay[taskDate] == null) {
        tasksForDay[taskDate] = [];
      }
      tasksForDay[taskDate]?.add(taskContent);
    }

    setState(() {
      _tasksForDay = tasksForDay;
    });
  }

  List<String> _getTasksForDay(DateTime day) {
    // Làm tròn ngày để so sánh
    day = DateTime(day.year, day.month, day.day);
    return _tasksForDay[day] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
          backgroundColor: Colors.blue,
        title: Text(
          'Lịch',
          style: TextStyle(color: Colors.white), // Text color
        ),      ),
      body: Column(
        children: [
          // Lịch hiển thị với các ngày có dấu hiệu của nhiệm vụ
          TableCalendar(
            focusedDay: _selectedDay,
            firstDay: DateTime(2020),
            lastDay: DateTime(2025),
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
              });
            },

            eventLoader: _getTasksForDay, // Cung cấp công việc cho ngày
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
          ),
          const SizedBox(height: 10),

          // Hiển thị công việc của ngày đã chọn
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _tasksCollection
                  .where('uid', isEqualTo: widget.uid) // Check user UID
                  .where('status', isNotEqualTo: 'completed')  // Exclude completed tasks
                  .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(
                  DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day)))
                  .where('date', isLessThan: Timestamp.fromDate(
                  DateTime(_selectedDay.year, _selectedDay.month, _selectedDay.day + 1)))
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Có lỗi xảy ra!'));
                }
                final tasks = snapshot.data?.docs ?? [];

                return ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    final task = tasks[index];

                    bool isCompleted = task['status'] == 'completed'; // Check task status

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16),
                      child: GestureDetector(
                        onTap: () {
                          // Khi nhấn vào công việc, mở màn hình chi tiết công việc
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
                              // Nội dung công việc
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      task['content'],
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      'Thời gian: ${task['startTime']} - ${task['endTime']}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    Text(
                                      'Ngày: ${DateFormat('dd/MM/yyyy').format((task['date'] as Timestamp).toDate())}',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                              // Nút sửa và xóa
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () {
                                      // Khi nhấn nút sửa, chuyển sang màn hình chi tiết để chỉnh sửa
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
                                  IconButton(
                                    icon: Icon(
                                      Icons.check,
                                      color: isCompleted ? Colors.green : Colors.green, // Change circle color
                                    ),
                                    onPressed: () {
                                      // Update task status
                                      _tasksCollection.doc(task.id).update({'status': 'completed'}).then((_) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text("Công việc đã hoàn thành")),
                                        );
                                        // Animate task removal
                                        setState(() {
                                          // Optional: Add additional logic if needed
                                        });
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
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
      ),
    );
  }
}
