import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final int points;
  final DateTime dueDate;
  final String status; // 'pending', 'in_progress', 'completed', 'overdue'
  final String childId;
  final String parentId;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String category; // 'housework', 'study', 'exercise', 'other'

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.points,
    required this.dueDate,
    required this.status,
    required this.childId,
    required this.parentId,
    required this.createdAt,
    this.completedAt,
    required this.category,
  });

  // Convert Task to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'points': points,
      'dueDate': Timestamp.fromDate(dueDate),
      'status': status,
      'childId': childId,
      'parentId': parentId,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt': completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'category': category,
    };
  }

  // Create Task from Firestore document
  factory Task.fromMap(Map<String, dynamic> map, String documentId) {
    return Task(
      id: documentId,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      points: map['points'] ?? 0,
      dueDate: (map['dueDate'] as Timestamp).toDate(),
      status: map['status'] ?? 'pending',
      childId: map['childId'] ?? '',
      parentId: map['parentId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      completedAt: map['completedAt'] != null 
          ? (map['completedAt'] as Timestamp).toDate() 
          : null,
      category: map['category'] ?? 'other',
    );
  }

  // Create a copy of Task with updated fields
  Task copyWith({
    String? id,
    String? title,
    String? description,
    int? points,
    DateTime? dueDate,
    String? status,
    String? childId,
    String? parentId,
    DateTime? createdAt,
    DateTime? completedAt,
    String? category,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      points: points ?? this.points,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      childId: childId ?? this.childId,
      parentId: parentId ?? this.parentId,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      category: category ?? this.category,
    );
  }

  // Check if task is overdue
  bool get isOverdue {
    return status != 'completed' && DateTime.now().isAfter(dueDate);
  }

  // Get status display text in Thai
  String get statusDisplayText {
    switch (status) {
      case 'pending':
        return 'รอดำเนินการ';
      case 'in_progress':
        return 'กำลังทำ';
      case 'completed':
        return 'เสร็จสิ้น';
      case 'overdue':
        return 'เกินกำหนด';
      default:
        return 'ไม่ทราบสถานะ';
    }
  }

  // Get category display text in Thai
  String get categoryDisplayText {
    switch (category) {
      case 'housework':
        return 'งานบ้าน';
      case 'study':
        return 'การเรียน';
      case 'exercise':
        return 'การออกกำลังกาย';
      case 'other':
        return 'อื่นๆ';
      default:
        return 'ไม่ระบุ';
    }
  }
}

