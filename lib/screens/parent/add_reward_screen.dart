import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/reward_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class AddRewardScreen extends StatefulWidget {
  @override
  _AddRewardScreenState createState() => _AddRewardScreenState();
}

class _AddRewardScreenState extends State<AddRewardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _pointsController = TextEditingController();
  
  String _selectedCategory = 'toy';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _addReward() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final rewardsCollection = FirebaseFirestore.instance.collection('rewards');
      final newRewardDoc = rewardsCollection.doc();

      Reward reward = Reward(
        id: newRewardDoc.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        pointsRequired: int.parse(_pointsController.text),
        imageUrl: '',
        parentId: AuthService.currentUser!.uid,
        createdAt: DateTime.now(),
        isActive: _isActive,
        category: _selectedCategory,
      );

      await newRewardDoc.set(reward.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('เพิ่มรางวัลสำเร็จ!'),
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
        title: Text('เพิ่มรางวัล'),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomTextField(
                    controller: _titleController,
                    labelText: 'ชื่อรางวัล',
                    prefixIcon: Icons.card_giftcard,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกชื่อรางวัล';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _descriptionController,
                    labelText: 'รายละเอียด',
                    prefixIcon: Icons.description,
                    maxLines: 3,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'กรุณากรอกรายละเอียด';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  CustomTextField(
                    controller: _pointsController,
                    labelText: 'คะแนนที่ต้องใช้',
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
                  DropdownButtonFormField<String>(
                    value: _selectedCategory,
                    decoration: InputDecoration(
                      labelText: 'หมวดหมู่',
                      prefixIcon: Icon(Icons.category),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    items: [
                      DropdownMenuItem(value: 'toy', child: Text('ของเล่น')),
                      DropdownMenuItem(value: 'gift', child: Text('ของขวัญ')),
                      DropdownMenuItem(value: 'activity', child: Text('กิจกรรม')),
                      DropdownMenuItem(value: 'privilege', child: Text('สิทธิพิเศษ')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value!;
                      });
                    },
                  ),
                  SizedBox(height: 24),
                  CustomButton(
                    text: 'เพิ่มรางวัล',
                    onPressed: _isLoading ? null : _addReward,
                    isLoading: _isLoading,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}



