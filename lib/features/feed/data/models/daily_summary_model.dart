import 'package:optivus/features/feed/domain/entities/daily_summary.dart';

class DailySummaryModel {
  final int caloriesBurned;
  final int activeMinutes;
  final String insightMessage;
  final double taskProgress;
  final int tasksCompleted;
  final int tasksTotal;

  const DailySummaryModel({
    required this.caloriesBurned,
    required this.activeMinutes,
    required this.insightMessage,
    required this.taskProgress,
    required this.tasksCompleted,
    required this.tasksTotal,
  });

  factory DailySummaryModel.fromJson(Map<String, dynamic> json) {
    return DailySummaryModel(
      caloriesBurned: json['calories'] ?? 0,
      activeMinutes: json['minutes'] ?? 0,
      insightMessage: json['insight'] ?? '',
      taskProgress: (json['task_progress'] ?? json['taskProgress'] ?? 0.0)
          .toDouble(),
      tasksCompleted: json['tasks_completed'] ?? json['tasksCompleted'] ?? 0,
      tasksTotal: json['tasks_total'] ?? json['tasksTotal'] ?? 0,
    );
  }

  DailySummary toEntity() {
    return DailySummary(
      caloriesBurned: caloriesBurned,
      activeMinutes: activeMinutes,
      insightMessage: insightMessage,
      taskProgress: taskProgress,
      tasksCompleted: tasksCompleted,
      tasksTotal: tasksTotal,
    );
  }
}
