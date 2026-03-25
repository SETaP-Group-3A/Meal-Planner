class WeeklyGoals {
  Map<int, List<Goal>> goals = {};

  void addGoal(Goal goal, int weekID) {

    if (weekID < 0) {
      throw ArgumentError('Week ID must be non-negative');
    }

    if (!goals.containsKey(weekID)) {
      goals[weekID] = [];
    }
    goals[weekID]!.add(goal);  
  }

  List<Goal> getGoalsForCurrentWeek() {
    return getGoalsForWeek(goals.keys.isNotEmpty ? goals.keys.last : 0);
  }

  List<Goal> getGoalsForWeek(int weekID) {
    return goals[weekID] ?? [];
  }
}

class Goal {
  final String id;
  final int day;
  double value;

  Goal({required this.id, required this.day, required this.value}); 
}