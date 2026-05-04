import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';

class Task {
  final String? id;
  final String name;
  final String description;
  final DateTime? singleDate;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool isDuration;
  final String colorHex;
  final bool isDone;
  final DateTime createdAt;
  final String userId;

  Color get color => Color(int.parse(colorHex));

  Task({
    this.id,
    required this.name,
    this.description = '',
    this.singleDate,
    this.startDate,
    this.endDate,
    required this.isDuration,
    required this.colorHex,
    this.isDone = false,
    required this.createdAt,
    required this.userId,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'singleDate': singleDate != null ? Timestamp.fromDate(singleDate!) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate!) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'isDuration': isDuration,
      'colorHex': colorHex,
      'isDone': isDone,
      'createdAt': Timestamp.fromDate(createdAt),
      'userId': userId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map, String id) {
    DateTime? toDate(dynamic val) {
      if (val == null) return null;
      if (val is Timestamp) return val.toDate();
      if (val is int) return DateTime.fromMillisecondsSinceEpoch(val);
      return null;
    }

    return Task(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      singleDate: toDate(map['singleDate']),
      startDate: toDate(map['startDate']),
      endDate: toDate(map['endDate']),
      isDuration: map['isDuration'] ?? false,
      colorHex: map['colorHex'] ?? '0xFF00E676',
      isDone: map['isDone'] ?? false,
      createdAt: toDate(map['createdAt']) ?? DateTime.now(),
      userId: map['userId'] ?? '',
    );
  }
}
