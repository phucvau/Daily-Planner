import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now();
  String _taskContent = '';
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();
  String _location = '';
  String _personInCharge = '';
  String _notes = '';

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Colors.blue,
            hintColor: Colors.blueAccent,
            colorScheme: ColorScheme.light(primary: Colors.blue),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate)
      setState(() {
        _selectedDate = picked;
      });
  }

  _selectTime(BuildContext context, bool isStartTime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isStartTime ? _startTime : _endTime,
    );
    if (picked != null) {
      setState(() {
        if (isStartTime) {
          _startTime = picked;
        } else {
          _endTime = picked;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Thêm Công Việc Mới',
          style: TextStyle(color: Colors.white), // Text color
        ),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Ngày công việc
              ListTile(
                title: Text(
                  'Ngày: ${DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.calendar_today, color: Colors.blue),
                onTap: () => _selectDate(context),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nội dung công việc',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) => _taskContent = value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập nội dung công việc';
                  }
                  return null;
                },
              ),
              SizedBox(height: 10),
              ListTile(
                title: Text(
                  'Thời gian bắt đầu: ${_startTime.format(context)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.access_time, color: Colors.blue),
                onTap: () => _selectTime(context, true),
              ),
              ListTile(
                title: Text(
                  'Thời gian kết thúc: ${_endTime.format(context)}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(Icons.access_time, color: Colors.blue),
                onTap: () => _selectTime(context, false),
              ),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Địa điểm',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) => _location = value,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Chủ trì',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) => _personInCharge = value,
              ),
              SizedBox(height: 10),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Ghi chú',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey[200],
                ),
                onChanged: (value) => _notes = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // Background color
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Lấy UID của người dùng đã đăng nhập
                    String? uid = FirebaseAuth.instance.currentUser?.uid;

                    // Thêm công việc mới vào Firestore
                    FirebaseFirestore.instance.collection('tasks').add({
                      'content': _taskContent,
                      'date': _selectedDate,
                      'startTime': _startTime.format(context),
                      'endTime': _endTime.format(context),
                      'location': _location,
                      'personInCharge': _personInCharge,
                      'notes': _notes,
                      'uid': uid, // Lưu UID của người dùng
                      'status': 'pending', // Thêm trường status với giá trị mặc định
                      'order': 0, // Thêm trường order với giá trị mặc định (có thể điều chỉnh sau này)
                    });
                    Navigator.pop(context); // Quay lại màn hình danh sách công việc
                  }
                },
                child: Text('Thêm công việc',
                    style: TextStyle(color: Colors.white) // Text color
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
