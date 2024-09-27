import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

class TaskStatisticsScreen extends StatefulWidget {
  final String uid;

  TaskStatisticsScreen({required this.uid});

  @override
  _TaskStatisticsScreenState createState() => _TaskStatisticsScreenState();
}

class _TaskStatisticsScreenState extends State<TaskStatisticsScreen> {
  final CollectionReference _tasksCollection =
  FirebaseFirestore.instance.collection('tasks');
  int completedTasksCount = 0;
  int pendingTasksCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTaskStatistics();
  }

  Future<void> fetchTaskStatistics() async {
    try {
      // In ra uid để đảm bảo nó chính xác
      print('Fetching tasks for UID: ${widget.uid}');

      // Lấy dữ liệu từ Firestore
      final snapshot = await _tasksCollection.where('uid', isEqualTo: widget.uid).get();

      print('Fetched ${snapshot.docs.length} tasks'); // In ra số lượng task nhận được

      int completed = 0;
      int pending = 0;

      for (var task in snapshot.docs) {
        print(task.data()); // In ra dữ liệu của từng task

        if (task['status'] == 'completed') {
          completed++;
        } else if (task['status'] == 'pending') {
          pending++;
        }
      }

      // Cập nhật số lượng task hoàn thành và đang tiến hành
      setState(() {
        completedTasksCount = completed;
        pendingTasksCount = pending;
        isLoading = false; // Đã tải xong dữ liệu
      });

      print('Completed tasks: $completed, Pending tasks: $pending');
    } catch (e) {
      print('Error fetching task statistics: $e');
      setState(() {
        isLoading = false; // Nếu có lỗi, cũng đặt isLoading thành false
      });
    }
  }

  List<PieChartSectionData> getPieChartSections() {
    return [
      if (completedTasksCount > 0)
        PieChartSectionData(
          value: completedTasksCount.toDouble(),
          color: Colors.green,
          title: 'Hoàn thành',
          radius: 60, // Radius for the section
        ),
      if (pendingTasksCount > 0)
        PieChartSectionData(
          value: pendingTasksCount.toDouble(),
          color: Colors.orange,
          title: 'Đang tiến hành',
          radius: 60, // Radius for the section
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thống kê công việc'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Hiển thị loading khi dữ liệu đang tải
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Số lượng công việc:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              completedTasksCount == 0 && pendingTasksCount == 0
                  ? Text('Không có công việc nào được tìm thấy.') // Hiển thị nếu không có công việc
                  : Container(
                height: 250, // Set a fixed height for the pie chart
                child: PieChart(
                  PieChartData(
                    sections: getPieChartSections(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                    startDegreeOffset: 180, // Start angle for the pie chart
                  ),
                ),
              ),
              SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildTaskCountCard('Hoàn thành', completedTasksCount, Colors.green),
                  _buildTaskCountCard('Đang tiến hành', pendingTasksCount, Colors.orange),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskCountCard(String title, int count, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            SizedBox(height: 8),
            Text(
              count.toString(),
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
