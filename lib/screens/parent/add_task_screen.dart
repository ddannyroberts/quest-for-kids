import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddTaskScreen extends StatefulWidget {
  @override
  _AddTaskScreenState createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now().add(Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedCategory = 'housework';
  String? _selectedChildId;
  bool _isLoading = false;
  
  List<Map<String, dynamic>> _children = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _loadChildren() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('families')
          .doc(AuthService.currentUser!.uid)
          .collection('children')
          .get();

      setState(() {
        _children = snapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'name': data['name'],
            'email': data['email'],
          };
        }).toList();
      });
    } catch (e) {
      print('Error loading children: $e');
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(Duration(days: 365)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _createTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('กรุณาเลือกเด็กที่จะมอบหมายภารกิจ'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      DateTime dueDateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      Task newTask = Task(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        points: int.parse(_pointsController.text),
        dueDate: dueDateTime,
        status: 'pending',
        childId: _selectedChildId!,
        parentId: AuthService.currentUser!.uid,
        createdAt: DateTime.now(),
        category: _selectedCategory,
      );

      await FirebaseFirestore.instance
          .collection('tasks')
          .add(newTask.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('สร้างภารกิจสำเร็จ!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เกิดข้อผิดพลาด: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('เพิ่มภารกิจ'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Task Title
              CustomTextField(
                controller: _titleController,
                labelText: 'ชื่อภารกิจ',
                hintText: 'เช่น ทำความสะอาดห้องนอน',
                prefixIcon: Icons.assignment,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อภารกิจ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Task Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'รายละเอียดภารกิจ',
                hintText: 'อธิบายรายละเอียดของภารกิจ',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรายละเอียดภารกิจ';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Points
              CustomTextField(
                controller: _pointsController,
                labelText: 'คะแนนที่ได้รับ',
                hintText: 'เช่น 10',
                prefixIcon: Icons.star,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกคะแนน';
                  }
                  if (int.tryParse(value) == null) {
                    return 'กรุณากรอกตัวเลข';
                  }
                  if (int.parse(value) <= 0) {
                    return 'คะแนนต้องมากกว่า 0';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Category
              Text(
                'หมวดหมู่',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: [
                  DropdownMenuItem(
                    value: 'housework',
                    child: Text('งานบ้าน'),
                  ),
                  DropdownMenuItem(
                    value: 'study',
                    child: Text('การเรียน'),
                  ),
                  DropdownMenuItem(
                    value: 'exercise',
                    child: Text('การออกกำลังกาย'),
                  ),
                  DropdownMenuItem(
                    value: 'other',
                    child: Text('อื่นๆ'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),

              // Select Child
              Text(
                'มอบหมายให้',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedChildId,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: Text('เลือกเด็ก'),
                items: _children.map((child) {
                  return DropdownMenuItem<String>(
                    value: child['id'] as String,
                    child: Text(child['name'] as String),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedChildId = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'กรุณาเลือกเด็ก';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Due Date and Time
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'วันที่กำหนด',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: _selectDate,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.grey[600]),
                                SizedBox(width: 8),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'เวลา',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        InkWell(
                          onTap: _selectTime,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.grey[600]),
                                SizedBox(width: 8),
                                Text(_selectedTime.format(context)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 32),

              // Create Task Button
              CustomButton(
                text: 'สร้างภารกิจ',
                onPressed: _isLoading ? null : _createTask,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

