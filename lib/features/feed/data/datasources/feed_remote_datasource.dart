class FeedRemoteDataSource {
  Future<Map<String, dynamic>> fetchDailySummary() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    // Simulated data that maps to the UI
    return {
      'calories': 320,
      'minutes': 270, // 4.5h * 60
      'insight': "You're crushing your goals!",
      'taskProgress': 0.75,
      'tasksCompleted': 7,
      'tasksTotal': 10,
    };
  }
}
