import 'package:cloud_firestore/cloud_firestore.dart';

class Reward {
  final String id;
  final String title;
  final String description;
  final int pointsRequired;
  final String imageUrl;
  final String parentId;
  final DateTime createdAt;
  final bool isActive;
  final String category; // 'toy', 'book', 'activity', 'privilege', 'other'

  Reward({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.imageUrl,
    required this.parentId,
    required this.createdAt,
    required this.isActive,
    required this.category,
  });

  // Convert Reward to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
      'category': category,
    };
  }

  // Create Reward from Firestore document
  factory Reward.fromMap(Map<String, dynamic> map, String documentId) {
    return Reward(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pointsRequired: map['pointsRequired'] ?? 0,
      imageUrl: map['imageUrl'] ?? '',
      parentId: map['parentId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? true,
      category: map['category'] ?? 'other',
    );
  }

  // Create a copy of Reward with updated fields
  Reward copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsRequired,
    String? imageUrl,
    String? parentId,
    DateTime? createdAt,
    bool? isActive,
    String? category,
  }) {
    return Reward(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      category: category ?? this.category,
    );
  }

  // Get category display text in Thai
  String get categoryDisplayText {
    switch (category) {
      case 'toy':
        return 'ของเล่น';
      case 'book':
        return 'หนังสือ';
      case 'activity':
        return 'กิจกรรม';
      case 'privilege':
        return 'สิทธิพิเศษ';
      case 'other':
        return 'อื่นๆ';
      default:
        return 'ไม่ระบุ';
    }
  }
}

class RewardRedemption {
  final String id;
  final String rewardId;
  final String childId;
  final String parentId;
  final DateTime redeemedAt;
  final String status; // 'pending', 'approved', 'denied', 'completed'
  final String? notes;

  RewardRedemption({
    required this.id,
    required this.rewardId,
    required this.childId,
    required this.parentId,
    required this.redeemedAt,
    required this.status,
    this.notes,
  });

  // Convert RewardRedemption to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'rewardId': rewardId,
      'childId': childId,
      'parentId': parentId,
      'redeemedAt': Timestamp.fromDate(redeemedAt),
      'status': status,
      'notes': notes,
    };
  }

  // Create RewardRedemption from Firestore document
  factory RewardRedemption.fromMap(Map<String, dynamic> map, String documentId) {
    return RewardRedemption(
      id: documentId,
      rewardId: map['rewardId'] ?? '',
      childId: map['childId'] ?? '',
      parentId: map['parentId'] ?? '',
      redeemedAt: (map['redeemedAt'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      notes: map['notes'],
    );
  }

  // Get status display text in Thai
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'รอการอนุมัติ';
      case 'approved':
        return 'อนุมัติแล้ว';
      case 'denied':
        return 'ปฏิเสธ';
      case 'completed':
        return 'เสร็จสิ้น';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }
}

