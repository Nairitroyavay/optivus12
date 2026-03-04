import 'package:cloud_firestore/cloud_firestore.dart';

/// Thin wrapper around Firebase for feed data queries.
/// Throws raw exceptions — the repository layer catches and maps them.
class FeedRemoteDataSource {
  final FirebaseFirestore _firestore;

  FeedRemoteDataSource({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Fetches the daily summary for [uid] for today.
  /// Uses composite document ID: `{uid}_{YYYYMMDD}` for O(1) lookup.
  /// No query needed, no composite index required, no duplicate risk.
  /// Throws [FirebaseException] on read failure.
  Future<Map<String, dynamic>> fetchDailySummary(String uid) async {
    final today = DateTime.now().toIso8601String().substring(0, 10);
    final docId = '${uid}_$today';

    final snapshot = await _firestore
        .collection('daily_summaries')
        .doc(docId)
        .get();

    if (!snapshot.exists) {
      // No data for today — return safe defaults.
      return {
        'calories': 0,
        'minutes': 0,
        'insight': 'No data recorded yet today.',
        'task_progress': 0.0,
        'tasks_completed': 0,
        'tasks_total': 0,
      };
    }

    return snapshot.data() ?? {};
  }
}
