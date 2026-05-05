import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

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
    required String priority,
  }) async {
    await collectionFor(userId).add({
      'name': name,
      'description': description,
      'singleDate': singleDate != null ? Timestamp.fromDate(singleDate) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
      'isDuration': isDuration,
      'priority': priority,
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

  static Future<void> updateTask({
    required String userId,
    required String taskId,
    required String name,
    required String description,
    DateTime? singleDate,
    DateTime? startDate,
    DateTime? endDate,
    required bool isDuration,
    required String priority,
  }) async {
    await collectionFor(userId).doc(taskId).update({
      'name': name,
      'description': description,
      'singleDate': singleDate != null ? Timestamp.fromDate(singleDate) : null,
      'startDate': startDate != null ? Timestamp.fromDate(startDate) : null,
      'endDate': endDate != null ? Timestamp.fromDate(endDate) : null,
      'isDuration': isDuration,
      'priority': priority,
    });
  }

  static Future<int> calculateStreak(String userId) async {
    final snapshot = await collectionFor(userId).get();
    if (snapshot.docs.isEmpty) return 0;

    final tasks = snapshot.docs
        .map((d) => Task.fromMap(d.data() as Map<String, dynamic>, d.id))
        .toList();

    final doneTasks = tasks.where((t) => t.isDone).toList();
    if (doneTasks.isEmpty) return 0;

    final completedDays = <String>{};
    for (final task in doneTasks) {
      final date = task.singleDate ?? task.startDate;
      if (date != null) {
        completedDays.add('${date.year}-${date.month}-${date.day}');
      }
    }

    if (completedDays.isEmpty) return 0;

    final today = DateTime.now();
    final todayKey = '${today.year}-${today.month}-${today.day}';
    final yesterdayKey = '${today.subtract(Duration(days: 1)).year}-${today.subtract(Duration(days: 1)).month}-${today.subtract(Duration(days: 1)).day}';

    if (!completedDays.contains(todayKey) && !completedDays.contains(yesterdayKey)) {
      return 0;
    }

    int streak = 0;
    DateTime checkDate = completedDays.contains(todayKey) ? today : today.subtract(const Duration(days: 1));

    while (true) {
      final key = '${checkDate.year}-${checkDate.month}-${checkDate.day}';
      if (completedDays.contains(key)) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return streak;
  }
}
