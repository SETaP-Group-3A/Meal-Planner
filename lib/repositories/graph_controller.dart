import 'package:meal_planner/models/weekly_goals.dart';

class GraphController {

  List<Goal> userData;

  GraphController(this.userData) {
    updateGraph(userData[0].id);
  }

  List<int> updateGraph(String goal) {  
    // Produce a fixed 7-element list mapping days 0..6 to values for `goal`.
    final result = List<int>.filled(7, 0);
    for (final g in userData) {
      if (g.id == goal && g.day >= 0 && g.day < 7) {
        result[g.day] = g.value.toInt();
      }
    }
    return result;
  }
}