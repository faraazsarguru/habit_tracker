import 'package:cloud_firestore/cloud_firestore.dart';

class TaskService {
  static final _db = FirebaseFirestore.instance;

  static Stream<QuerySnapshot> streamTasks(String userId) {
    return collectionFor(userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  static CollectionReference collectionFor(String userId) {
    return _db.collection('users').doc(userId).collection('tasks');
  }

  static Future<void> addTask({
    required String userId,
    required String name,
    required String description,
    DateTime? singleDate,
    DateTime? startDate,
    DateTime? endDate,
    required bool isDuration,
    required String colorHex,
  }) async {
    await collectionFor(userId).add({
      'name': name,
      'description': description,
      'singleDate': singleDate != null ? Timestamp.fromDate(singleDate) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
      'isDuration': isDuration,
      'colorHex': colorHex,
      'isDone': false,
      'createdAt': FieldValue.serverTimestamp(),
      'userId': userId,
    });
  }

  static Future<void> toggleDone({
    required String userId,
    required String taskId,
    required bool isDone,
  }) async {
    await collectionFor(userId).doc(taskId).update({'isDone': !isDone});
  }

  static Future<void> deleteTask({
    required String userId,
    required String taskId,
  }) async {
    await collectionFor(userId).doc(taskId).delete();
  }
}
