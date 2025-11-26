import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';

class FamilyManagementScreen extends StatefulWidget {
  @override
  _FamilyManagementScreenState createState() => _FamilyManagementScreenState();
}

class _FamilyManagementScreenState extends State<FamilyManagementScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('จัดการครอบครัว'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              _showAddChildDialog();
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: AuthService.getChildren(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.family_restroom_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ยังไม่มีเด็กในครอบครัว',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'เพิ่มเด็กเข้าระบบเพื่อเริ่มใช้งาน',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'เพิ่มเด็ก',
                    onPressed: () {
                      _showAddChildDialog();
                    },
                    backgroundColor: Colors.purple[600],
                  ),
                ],
              ),
            );
          }

          List<DocumentSnapshot> children = snapshot.data!.docs;

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: children.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> childData = children[index].data() as Map<String, dynamic>;
              int kidPoints = childData['kidPoints'] ?? 0;

              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(
                      Icons.child_care,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    childData['name'] ?? 'ไม่ระบุชื่อ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(childData['email'] ?? 'ไม่ระบุอีเมล'),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4),
                          Text('$kidPoints คะแนน'),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'remove') {
                        await _removeChild(children[index].id, childData['name']);
                      } else if (value == 'reset_points') {
                        await _resetChildPoints(children[index].id, childData['name']);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'reset_points',
                        child: Row(
                          children: [
                            Icon(
                              Icons.refresh,
                              color: Colors.orange,
                            ),
                            SizedBox(width: 8),
                            Text('รีเซ็ตคะแนน'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: 'remove',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text('ลบออกจากครอบครัว'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddChildDialog();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.purple[800],
      ),
    );
  }

  void _showAddChildDialog() {
    showDialog(
      context: context,
      builder: (context) => AddChildDialog(),
    );
  }

  Future<void> _removeChild(String childId, String childName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบ $childName ออกจากครอบครัวหรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('ลบ'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('families')
            .doc(AuthService.currentUser!.uid)
            .collection('children')
            .doc(childId)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบเด็กออกจากครอบครัวแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _resetChildPoints(String childId, String childName) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการรีเซ็ตคะแนน'),
        content: Text('คุณต้องการรีเซ็ตคะแนนของ $childName เป็น 0 หรือไม่?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('ยกเลิก'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('รีเซ็ต'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await FirebaseFirestore.instance
            .collection('families')
            .doc(AuthService.currentUser!.uid)
            .collection('children')
            .doc(childId)
            .update({
          'kidPoints': 0,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('รีเซ็ตคะแนนแล้ว'),
            backgroundColor: Colors.green,
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เกิดข้อผิดพลาด: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class AddChildDialog extends StatefulWidget {
  @override
  _AddChildDialogState createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _addChild() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      bool success = await AuthService.addChildToFamily(
        childEmail: _emailController.text.trim(),
        childName: _nameController.text.trim(),
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มเด็กเข้าระบบสำเร็จ!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('เพิ่มเด็กเข้าระบบไม่สำเร็จ กรุณาลองใหม่'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
    return AlertDialog(
      title: Text('เพิ่มเด็กเข้าระบบ'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              controller: _nameController,
              labelText: 'ชื่อ-นามสกุล',
              prefixIcon: Icons.person,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกชื่อ-นามสกุล';
                }
                return null;
              },
            ),
            SizedBox(height: 16),
            CustomTextField(
              controller: _emailController,
              labelText: 'อีเมล',
              keyboardType: TextInputType.emailAddress,
              prefixIcon: Icons.email,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'กรุณากรอกอีเมล';
                }
                if (!value.contains('@')) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('ยกเลิก'),
        ),
        CustomButton(
          text: 'เพิ่ม',
          onPressed: _isLoading ? null : _addChild,
          isLoading: _isLoading,
          width: 80,
          height: 40,
        ),
      ],
    );
  }
}

