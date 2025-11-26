import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reward_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'add_reward_screen.dart';

class ManageRewardsScreen extends StatefulWidget {
  @override
  _ManageRewardsScreenState createState() => _ManageRewardsScreenState();
}

class _ManageRewardsScreenState extends State<ManageRewardsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('จัดการรางวัล'),
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddRewardScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rewards')
            .where('parentId', isEqualTo: AuthService.currentUser?.uid)
            .snapshots(),
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
                    Icons.card_giftcard_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'ยังไม่มีรางวัล',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'กดปุ่ม + เพื่อเพิ่มรางวัลใหม่',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                  SizedBox(height: 20),
                  CustomButton(
                    text: 'เพิ่มรางวัล',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddRewardScreen(),
                        ),
                      );
                    },
                    backgroundColor: Colors.orange[600],
                  ),
                ],
              ),
            );
          }

          List<Reward> rewards = snapshot.data!.docs.map((doc) {
            return Reward.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          }).toList();

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: rewards.length,
            itemBuilder: (context, index) {
              Reward reward = rewards[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: reward.isActive ? Colors.orange : Colors.grey,
                    child: Icon(
                      Icons.card_giftcard,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    reward.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(reward.description),
                      SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 4),
                          Text('${reward.pointsRequired} คะแนน'),
                          SizedBox(width: 16),
                          Icon(
                            Icons.category,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 4),
                          Text(reward.categoryDisplayText),
                        ],
                      ),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        reward.isActive ? Icons.check_circle : Icons.cancel,
                        color: reward.isActive ? Colors.green : Colors.red,
                      ),
                      SizedBox(width: 8),
                      PopupMenuButton<String>(
                        onSelected: (value) async {
                          if (value == 'toggle') {
                            await _toggleRewardStatus(reward);
                          } else if (value == 'delete') {
                            await _deleteReward(reward);
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(
                                  reward.isActive ? Icons.pause : Icons.play_arrow,
                                  color: reward.isActive ? Colors.orange : Colors.green,
                                ),
                                SizedBox(width: 8),
                                Text(reward.isActive ? 'ปิดใช้งาน' : 'เปิดใช้งาน'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 8),
                                Text('ลบ'),
                              ],
                            ),
                          ),
                        ],
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRewardScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.orange[800],
      ),
    );
  }

  Future<void> _toggleRewardStatus(Reward reward) async {
    try {
      await FirebaseFirestore.instance
          .collection('rewards')
          .doc(reward.id)
          .update({
        'isActive': !reward.isActive,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reward.isActive ? 'ปิดใช้งานรางวัลแล้ว' : 'เปิดใช้งานรางวัลแล้ว',
          ),
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

  Future<void> _deleteReward(Reward reward) async {
    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('ยืนยันการลบ'),
        content: Text('คุณต้องการลบรางวัล "${reward.title}" หรือไม่?'),
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
            .collection('rewards')
            .doc(reward.id)
            .delete();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('ลบรางวัลแล้ว'),
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
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _pointsController.dispose();
    super.dispose();
  }

  Future<void> _createReward() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Reward newReward = Reward(
        id: '', // Will be set by Firestore
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        pointsRequired: int.parse(_pointsController.text),
        imageUrl: '', // Can be added later
        parentId: AuthService.currentUser!.uid,
        createdAt: DateTime.now(),
        isActive: true,
        category: _selectedCategory,
      );

      await FirebaseFirestore.instance
          .collection('rewards')
          .add(newReward.toMap());

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('สร้างรางวัลสำเร็จ!'),
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
        backgroundColor: Colors.orange[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Reward Title
              CustomTextField(
                controller: _titleController,
                labelText: 'ชื่อรางวัล',
                hintText: 'เช่น ของเล่นใหม่, ไปเที่ยวสวนสนุก',
                prefixIcon: Icons.card_giftcard,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกชื่อรางวัล';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Reward Description
              CustomTextField(
                controller: _descriptionController,
                labelText: 'รายละเอียดรางวัล',
                hintText: 'อธิบายรายละเอียดของรางวัล',
                prefixIcon: Icons.description,
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกรายละเอียดรางวัล';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),

              // Points Required
              CustomTextField(
                controller: _pointsController,
                labelText: 'คะแนนที่ต้องการ',
                hintText: 'เช่น 50',
                prefixIcon: Icons.star,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'กรุณากรอกคะแนนที่ต้องการ';
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
                    value: 'toy',
                    child: Text('ของเล่น'),
                  ),
                  DropdownMenuItem(
                    value: 'book',
                    child: Text('หนังสือ'),
                  ),
                  DropdownMenuItem(
                    value: 'activity',
                    child: Text('กิจกรรม'),
                  ),
                  DropdownMenuItem(
                    value: 'privilege',
                    child: Text('สิทธิพิเศษ'),
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
              SizedBox(height: 32),

              // Create Reward Button
              CustomButton(
                text: 'สร้างรางวัล',
                onPressed: _isLoading ? null : _createReward,
                isLoading: _isLoading,
                backgroundColor: Colors.orange[600],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

