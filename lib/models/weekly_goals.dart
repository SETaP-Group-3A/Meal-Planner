class WeeklyGoals {
  Map<int, List<Goal>> goals = {};

  void addGoal(Goal goal, int weekID) {
    if (!goals.containsKey(weekID)) {
      goals[weekID] = [];
    }
    goals[weekID]!.add(goal);  
  }
}

class Goal {
  final String id;
  final String day;
  final String value;

  Goal({required this.id, required this.day, required this.value}); 
}