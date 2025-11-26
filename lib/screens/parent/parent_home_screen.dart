import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/task_model.dart';
import '../../models/reward_model.dart';
import '../../widgets/custom_button.dart';
import 'add_task_screen.dart';
import 'manage_rewards_screen.dart';
import 'family_management_screen.dart';

class ParentHomeScreen extends StatefulWidget {
  @override
  _ParentHomeScreenState createState() => _ParentHomeScreenState();
}

class _ParentHomeScreenState extends State<ParentHomeScreen> {
  int _selectedIndex = 0;
  String? _userName;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await AuthService.getUserData();
    if (userData != null) {
      setState(() {
        _userName = userData['name'];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuestForKids'),
        backgroundColor: Colors.blue[800],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await AuthService.signOut();
            },
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildDashboard(),
          _buildTasksTab(),
          _buildRewardsTab(),
          _buildFamilyTab(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        selectedItemColor: Colors.blue[800],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'ภารกิจ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'รางวัล',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.family_restroom),
            label: 'ครอบครัว',
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddTaskScreen(),
                  ),
                );
              },
              child: Icon(Icons.add),
              backgroundColor: Colors.blue[800],
            )
          : null,
    );
  }

  Widget _buildDashboard() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
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
                  Text(
                    'สวัสดี ${_userName ?? 'ผู้ปกครอง'}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'ยินดีต้อนรับสู่ QuestForKids',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 20),

          // Quick Stats
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'ภารกิจทั้งหมด',
                  '0',
                  Icons.assignment,
                  Colors.blue,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'ภารกิจเสร็จสิ้น',
                  '0',
                  Icons.check_circle,
                  Colors.green,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'รางวัลทั้งหมด',
                  '0',
                  Icons.card_giftcard,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'เด็กในครอบครัว',
                  '0',
                  Icons.child_care,
                  Colors.purple,
                ),
              ),
            ],
          ),
          SizedBox(height: 20),

          // Quick Actions
          Text(
            'การดำเนินการด่วน',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'เพิ่มภารกิจ',
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddTaskScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.blue[600],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'จัดการรางวัล',
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageRewardsScreen(),
                      ),
                    );
                  },
                  backgroundColor: Colors.orange[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('tasks')
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
                  Icons.assignment_outlined,
                  size: 64,
                  color: Colors.grey[400],
                ),
                SizedBox(height: 16),
                Text(
                  'ยังไม่มีภารกิจ',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'กดปุ่ม + เพื่อเพิ่มภารกิจใหม่',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        List<Task> tasks = snapshot.data!.docs.map((doc) {
          return Task.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }).toList();

        return ListView.builder(
          padding: EdgeInsets.all(16),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            Task task = tasks[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: _getStatusColor(task.status),
                  child: Icon(
                    _getStatusIcon(task.status),
                    color: Colors.white,
                  ),
                ),
                title: Text(
                  task.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(task.description),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text('${task.points} คะแนน'),
                        SizedBox(width: 16),
                        Icon(
                          Icons.category,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 4),
                        Text(task.categoryDisplayText),
                      ],
                    ),
                  ],
                ),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      task.statusDisplayText,
                      style: TextStyle(
                        color: _getStatusColor(task.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRewardsTab() {
    return StreamBuilder<QuerySnapshot>(
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
                  backgroundColor: Colors.orange,
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
                trailing: Icon(
                  reward.isActive ? Icons.check_circle : Icons.cancel,
                  color: reward.isActive ? Colors.green : Colors.red,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFamilyTab() {
    return StreamBuilder<QuerySnapshot>(
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FamilyManagementScreen(),
                      ),
                    );
                  },
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
                subtitle: Text(childData['email'] ?? 'ไม่ระบุอีเมล'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 16,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '$kidPoints',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'คะแนน',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
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

