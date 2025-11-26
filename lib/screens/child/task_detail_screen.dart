import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/task_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class TaskDetailScreen extends StatefulWidget {
  final Task task;

  const TaskDetailScreen({Key? key, required this.task}) : super(key: key);

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  bool _isLoading = false;

  Future<void> _updateTaskStatus(String newStatus) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('tasks')
          .doc(widget.task.id)
          .update({
        'status': newStatus,
        if (newStatus == 'completed') 'completedAt': FieldValue.serverTimestamp(),
      });

      // Update kid points if task is completed
      if (newStatus == 'completed') {
        await _updateKidPoints(widget.task.points);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'completed' 
                ? 'ยินดีด้วย! คุณได้รับ ${widget.task.points} คะแนน'
                : 'อัปเดตสถานะภารกิจแล้ว',
          ),
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

  Future<void> _updateKidPoints(int points) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser!.uid)
          .update({
        'kidPoints': FieldValue.increment(points),
      });
    } catch (e) {
      print('Error updating kid points: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('รายละเอียดภารกิจ'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Header Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getStatusColor(widget.task.status),
                          child: Icon(
                            _getStatusIcon(widget.task.status),
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.task.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.task.statusDisplayText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: _getStatusColor(widget.task.status),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.task.description,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Task Details
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'รายละเอียดภารกิจ',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    _buildDetailRow(
                      Icons.star,
                      'คะแนนที่ได้รับ',
                      '${widget.task.points} คะแนน',
                      Colors.amber,
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.category,
                      'หมวดหมู่',
                      widget.task.categoryDisplayText,
                      Colors.blue,
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.schedule,
                      'วันที่กำหนด',
                      '${widget.task.dueDate.day}/${widget.task.dueDate.month}/${widget.task.dueDate.year}',
                      Colors.green,
                    ),
                    SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.access_time,
                      'เวลาที่กำหนด',
                      '${widget.task.dueDate.hour.toString().padLeft(2, '0')}:${widget.task.dueDate.minute.toString().padLeft(2, '0')}',
                      Colors.orange,
                    ),
                    if (widget.task.completedAt != null) ...[
                      SizedBox(height: 12),
                      _buildDetailRow(
                        Icons.check_circle,
                        'เสร็จสิ้นเมื่อ',
                        '${widget.task.completedAt!.day}/${widget.task.completedAt!.month}/${widget.task.completedAt!.year} ${widget.task.completedAt!.hour.toString().padLeft(2, '0')}:${widget.task.completedAt!.minute.toString().padLeft(2, '0')}',
                        Colors.green,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Action Buttons
            if (widget.task.status == 'pending') ...[
              CustomButton(
                text: 'เริ่มทำภารกิจ',
                onPressed: _isLoading ? null : () => _updateTaskStatus('in_progress'),
                isLoading: _isLoading,
                backgroundColor: Colors.blue[600],
              ),
              SizedBox(height: 12),
            ],
            
            if (widget.task.status == 'in_progress') ...[
              CustomButton(
                text: 'เสร็จสิ้นภารกิจ',
                onPressed: _isLoading ? null : () => _updateTaskStatus('completed'),
                isLoading: _isLoading,
                backgroundColor: Colors.green[600],
              ),
              SizedBox(height: 12),
              CustomButton(
                text: 'หยุดทำชั่วคราว',
                onPressed: _isLoading ? null : () => _updateTaskStatus('pending'),
                backgroundColor: Colors.orange[600],
              ),
            ],

            if (widget.task.status == 'completed') ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green[600],
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ยินดีด้วย! คุณทำภารกิจนี้เสร็จแล้วและได้รับ ${widget.task.points} คะแนน',
                        style: TextStyle(
                          color: Colors.green[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (widget.task.isOverdue && widget.task.status != 'completed') ...[
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.red[600],
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'ภารกิจนี้เกินกำหนดแล้ว กรุณาทำให้เสร็จโดยเร็ว',
                        style: TextStyle(
                          color: Colors.red[800],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 20,
        ),
        SizedBox(width: 12),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'in_progress':
        return Icons.play_arrow;
      case 'completed':
        return Icons.check;
      case 'overdue':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }
}

