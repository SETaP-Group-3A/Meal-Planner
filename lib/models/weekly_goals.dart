import 'package:flutter/foundation.dart';

class WeeklyGoals extends ChangeNotifier {
  Map<int, List<Goal>> goals = {};

  void addGoal(Goal goal, int weekID) {
    if (weekID < 0) {
      throw ArgumentError('Week ID must be non-negative');
    }

    if (!goals.containsKey(weekID)) {
      goals[weekID] = [];
    }
    goals[weekID]!.add(goal);
    notifyListeners();
  }

  void setGoalValue(int weekID, int day, double value, {String? id}) {
    if (!goals.containsKey(weekID)) goals[weekID] = [];
    final list = goals[weekID]!;
    final existing = list.firstWhere((g) => g.day == day, orElse: () => Goal(id: id ?? '', day: day, value: double.nan));
    if (existing.id.isEmpty) {
      list.add(Goal(id: id ?? 'goal', day: day, value: value));
    } else {
      existing.value = value;
    }
    notifyListeners();
  }

  List<Goal> getGoalsForCurrentWeek() {
    return getGoalsForWeek(goals.keys.isNotEmpty ? goals.keys.last : 0);
  }

  List<Goal> getGoalsForWeek(int weekID) {
    return goals[weekID] ?? [];
  }

  int get currentWeek => goals.keys.isNotEmpty ? goals.keys.last : 0;
}

class Goal {
  final String id;
  final int day;
  double value;

  Goal({required this.id, required this.day, required this.value}); 
}