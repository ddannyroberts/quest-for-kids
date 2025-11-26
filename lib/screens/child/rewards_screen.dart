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

    String rewardEmoji = _getRewardCategoryEmoji(widget.reward.category);
    
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('🎁 ', style: TextStyle(fontSize: 24)),
            Text('แลกรางวัล'),
          ],
        ),
        backgroundColor: Colors.pink[800],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Reward Header Card - Enhanced
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: canRedeem
                      ? LinearGradient(
                          colors: [Colors.pink[400]!, Colors.purple[400]!],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: canRedeem ? null : Colors.grey[200],
                ),
                padding: EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              rewardEmoji,
                              style: TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.reward.title,
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                  color: canRedeem ? Colors.white : Colors.grey[800],
                                ),
                              ),
                              SizedBox(height: 6),
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  widget.reward.categoryDisplayText,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: canRedeem ? Colors.white : Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
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
                        color: canRedeem ? Colors.white70 : Colors.grey[700],
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
                    Row(
                      children: [
                        Text('💰 ', style: TextStyle(fontSize: 20)),
                        Text(
                          'ข้อมูลคะแนน',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink[800],
                          ),
                        ),
                      ],
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
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF4CAF50), Color(0xFF45A049)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.green.withOpacity(0.3),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Text('✅', style: TextStyle(fontSize: 32)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'คุณสามารถแลกรางวัลนี้ได้! 🎉',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red[300]!, width: 2),
                        ),
                        child: Row(
                          children: [
                            Text('⚠️', style: TextStyle(fontSize: 32)),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'คะแนนไม่เพียงพอ',
                                    style: TextStyle(
                                      color: Colors.red[800],
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'คุณต้องมี ${widget.reward.pointsRequired - _kidPoints} คะแนนเพิ่มเติม',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
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
                text: '🎁 แลกรางวัล',
                onPressed: _isLoading ? null : _redeemReward,
                isLoading: _isLoading,
                backgroundColor: Colors.pink[600],
              ),
              SizedBox(height: 12),
              CustomButton(
                text: '❌ ยกเลิก',
                onPressed: () => Navigator.pop(context),
                backgroundColor: Colors.grey[600],
              ),
            ] else ...[
              CustomButton(
                text: '🔙 กลับ',
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
    String emoji = title.contains('ของคุณ') ? '⭐' : '🎁';
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      child: Column(
        children: [
          Text(emoji, style: TextStyle(fontSize: 36)),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getRewardCategoryEmoji(String category) {
    switch (category) {
      case 'toy':
        return '🧸';
      case 'book':
        return '📖';
      case 'activity':
        return '🎪';
      case 'privilege':
        return '👑';
      case 'other':
        return '🎁';
      default:
        return '🎁';
    }
  }
}


