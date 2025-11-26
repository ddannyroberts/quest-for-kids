import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../models/task_model.dart';
import '../../models/reward_model.dart';
import '../../widgets/custom_button.dart';
import 'task_detail_screen.dart';
import 'rewards_screen.dart';

class ChildHomeScreen extends StatefulWidget {
  @override
  _ChildHomeScreenState createState() => _ChildHomeScreenState();
}

class _ChildHomeScreenState extends State<ChildHomeScreen> {
  int _selectedIndex = 0;
  String? _userName;
  int _kidPoints = 0;

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
        _kidPoints = userData['kidPoints'] ?? 0;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QuestForKids'),
        backgroundColor: Colors.purple[800],
        foregroundColor: Colors.white,
        actions: [
          // Kid Points Display
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.amber[600],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 4),
                Text(
                  '$_kidPoints',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
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
        selectedItemColor: Colors.purple[800],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'หน้าหลัก',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'ภารกิจของฉัน',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.card_giftcard),
            label: 'รางวัล',
          ),
        ],
      ),
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
                    'สวัสดี ${_userName ?? 'เด็กๆ'}!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'พร้อมรับภารกิจใหม่แล้วหรือยัง?',
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

          // Kid Points Card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  colors: [Colors.amber[400]!, Colors.amber[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.star,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'คะแนนของฉัน',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$_kidPoints คะแนน',
                          style: TextStyle(
                            fontSize: 32,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
                  'ภารกิจรอทำ',
                  '0',
                  Icons.schedule,
                  Colors.orange,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'ภารกิจเสร็จแล้ว',
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
                  'รางวัลที่แลกได้',
                  '0',
                  Icons.card_giftcard,
                  Colors.pink,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'รางวัลที่แลกแล้ว',
                  '0',
                  Icons.redeem,
                  Colors.blue,
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
                  text: 'ดูภารกิจ',
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                  },
                  backgroundColor: Colors.purple[600],
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: CustomButton(
                  text: 'แลกรางวัล',
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                  },
                  backgroundColor: Colors.pink[600],
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
          .where('childId', isEqualTo: AuthService.currentUser?.uid)
          .orderBy('dueDate', descending: false)
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
                  'รอผู้ปกครองมอบหมายภารกิจให้',
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
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailScreen(task: task),
                    ),
                  );
                },
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
          .where('isActive', isEqualTo: true)
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
                  'รอผู้ปกครองเพิ่มรางวัล',
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
            bool canRedeem = _kidPoints >= reward.pointsRequired;

            return Card(
              margin: EdgeInsets.only(bottom: 12),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(16),
                leading: CircleAvatar(
                  backgroundColor: canRedeem ? Colors.pink : Colors.grey,
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
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (canRedeem)
                      Text(
                        'แลกได้',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      Text(
                        'คะแนนไม่พอ',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    Text(
                      '$_kidPoints/${reward.pointsRequired}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                onTap: canRedeem ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => RewardsScreen(reward: reward),
                    ),
                  );
                } : null,
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

