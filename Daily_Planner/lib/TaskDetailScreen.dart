import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import để format ngày và giờ

class TaskDetailScreen extends StatefulWidget {
  final String taskId;

  TaskDetailScreen({required this.taskId});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final CollectionReference _tasksCollection = FirebaseFirestore.instance.collection('tasks');
  final _formKey = GlobalKey<FormState>();
  TextEditingController _contentController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _personInChargeController = TextEditingController();
  TextEditingController _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _startTime = TimeOfDay.now();
  TimeOfDay _endTime = TimeOfDay.now();

  Map<String, dynamic>? taskData;

  @override
  void initState() {
    super.initState();
    _loadTaskDetails();
  }

  void _loadTaskDetails() async {
    DocumentSnapshot taskSnapshot = await _tasksCollection.doc(widget.taskId).get();
    if (taskSnapshot.exists) {
      setState(() {
        taskData = taskSnapshot.data() as Map<String, dynamic>;
        _contentController.text = taskData?['content'] ?? '';
        _locationController.text = taskData?['location'] ?? '';
        _personInChargeController.text = taskData?['personInCharge'] ?? '';
        _notesController.text = taskData?['notes'] ?? '';
        _selectedDate = (taskData?['date'] as Timestamp).toDate();
        _startTime = _parseTimeOfDay(taskData?['startTime']);
        _endTime = _parseTimeOfDay(taskData?['endTime']);
      });
    }
  }

  TimeOfDay _parseTimeOfDay(String? time) {
    if (time == null) return TimeOfDay.now();
    final timeParts = time.split(' ');
    final hourMinute = timeParts[0].split(':');
    int hour = int.parse(hourMinute[0]);
    int minute = int.parse(hourMinute[1]);
    if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'PM' && hour < 12) {
      hour += 12;
    } else if (timeParts.length > 1 && timeParts[1].toUpperCase() == 'AM' && hour == 12) {
      hour = 0;
    }
    return TimeOfDay(hour: hour, minute: minute);
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

  _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2025),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _updateTask() {
    _tasksCollection.doc(widget.taskId).update({
      'content': _contentController.text,
      'date': Timestamp.fromDate(_selectedDate),
      'startTime': _startTime.format(context),
      'endTime': _endTime.format(context),
      'location': _locationController.text,
      'personInCharge': _personInChargeController.text,
      'notes': _notesController.text,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Cập nhật thành công')));
      Navigator.pop(context);
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Có lỗi xảy ra!')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Chi tiết công việc',
          style: TextStyle(color: Colors.white), // Text color
        ),
        backgroundColor: Colors.blueAccent,
      ),
      body: taskData == null
          ? Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ngày công việc
                    ListTile(
                      title: Text(
                        'Ngày: ${DateFormat('EEEE, dd/MM/yyyy').format(_selectedDate)}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    _buildTextFormField(
                      controller: _contentController,
                      label: 'Nội dung công việc',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập nội dung công việc';
                        }
                        return null;
                      },
                    ),
                    _buildTimeListTile(
                      context,
                      title: 'Thời gian bắt đầu: ${_startTime.format(context)}',
                      isStartTime: true,
                    ),
                    _buildTimeListTile(
                      context,
                      title: 'Thời gian kết thúc: ${_endTime.format(context)}',
                      isStartTime: false,
                    ),
                    _buildTextFormField(controller: _locationController, label: 'Địa điểm'),
                    _buildTextFormField(controller: _personInChargeController, label: 'Chủ trì'),
                    _buildTextFormField(controller: _notesController, label: 'Ghi chú'),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _updateTask,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 15.0),
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        minimumSize: Size(100, 20)
                      ),
                      child: Text(
                        'Cập nhật',
                        style: TextStyle(fontSize: 16,color: Colors.white),

                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to build a TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    FormFieldValidator<String>? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.blueAccent, width: 2),
          ),
        ),
        validator: validator,
      ),
    );
  }

  // Helper method to build a ListTile for time selection
  Widget _buildTimeListTile(BuildContext context, {required String title, required bool isStartTime}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: ListTile(
        title: Text(
          title,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        trailing: Icon(Icons.access_time),
        onTap: () => _selectTime(context, isStartTime),
      ),
    );
  }
}
