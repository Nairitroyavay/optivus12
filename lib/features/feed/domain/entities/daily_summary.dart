class DailySummary {
  final int caloriesBurned;
  final int activeMinutes;
  final String insightMessage;
  final double taskProgress;
  final int tasksCompleted;
  final int tasksTotal;

  const DailySummary({
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.insightMessage,
    required this.taskProgress,
    required this.tasksCompleted,
    required this.tasksTotal,
  });
}
