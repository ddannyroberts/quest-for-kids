import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/reward_model.dart';
import '../../services/auth_service.dart';
import '../../widgets/custom_button.dart';

class RewardsScreen extends StatefulWidget {
  final Reward reward;

  const RewardsScreen({Key? key, required this.reward}) : super(key: key);

  @override
  _RewardsScreenState createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> {
  bool _isLoading = false;
  int _kidPoints = 0;

  @override
  void initState() {
    super.initState();
    _loadKidPoints();
  }

  Future<void> _loadKidPoints() async {
    final userData = await AuthService.getUserData();
    if (userData != null) {
      setState(() {
        _kidPoints = userData['kidPoints'] ?? 0;
      });
    }
  }

  Future<void> _redeemReward() async {
    if (_kidPoints < widget.reward.pointsRequired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('คะแนนไม่เพียงพอสำหรับแลกรางวัลนี้'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Create reward redemption record
      await FirebaseFirestore.instance
          .collection('reward_redemptions')
          .add({
        'rewardId': widget.reward.id,
        'childId': AuthService.currentUser!.uid,
        'parentId': widget.reward.parentId,
        'redeemedAt': FieldValue.serverTimestamp(),
        'status': 'pending',
        'pointsUsed': widget.reward.pointsRequired,
      });

      // Deduct points from child
      await FirebaseFirestore.instance
          .collection('users')
          .doc(AuthService.currentUser!.uid)
          .update({
        'kidPoints': FieldValue.increment(-widget.reward.pointsRequired),
      });

      // Update local points
      setState(() {
        _kidPoints -= widget.reward.pointsRequired;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('แลกรางวัลสำเร็จ! รอการอนุมัติจากผู้ปกครอง'),
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
    bool canRedeem = _kidPoints >= widget.reward.pointsRequired;

    return Scaffold(
      appBar: AppBar(
        title: Text('แลกรางวัล'),
        backgroundColor: Colors.pink[800],
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reward Header Card
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
                          backgroundColor: canRedeem ? Colors.pink : Colors.grey,
                          radius: 30,
                          child: Icon(
                            Icons.card_giftcard,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.reward.title,
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                widget.reward.categoryDisplayText,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      widget.reward.description,
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

            // Points Information
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
                      'ข้อมูลคะแนน',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPointsCard(
                            'คะแนนของคุณ',
                            '$_kidPoints',
                            Colors.amber,
                            Icons.star,
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: _buildPointsCard(
                            'คะแนนที่ต้องการ',
                            '${widget.reward.pointsRequired}',
                            Colors.pink,
                            Icons.card_giftcard,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    if (canRedeem) ...[
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
                                'คุณสามารถแลกรางวัลนี้ได้!',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
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
                                'คะแนนไม่เพียงพอ คุณต้องมี ${widget.reward.pointsRequired - _kidPoints} คะแนนเพิ่มเติม',
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
            ),
            SizedBox(height: 20),

            // Action Buttons
            if (canRedeem) ...[
              CustomButton(
                text: 'แลกรางวัล',
                onPressed: _isLoading ? null : _redeemReward,
                isLoading: _isLoading,
                backgroundColor: Colors.pink[600],
              ),
              SizedBox(height: 12),
              CustomButton(
                text: 'ยกเลิก',
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.grey[600],
              ),
            ] else ...[
              CustomButton(
                text: 'กลับ',
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.grey[600],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPointsCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
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
    );
  }
}

