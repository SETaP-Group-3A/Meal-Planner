import 'package:meal_planner/models/weekly_goals.dart';

class GraphController {

  List<Goal> userData;

  GraphController(this.userData) {
    updateGraph(userData[0].id);
  }

  List<int> updateGraph(String goal) {
    switch (goal) {
      case "calories":
        //hardcoded data for now
        return [2, 5, 10, 5];
      case "money":
        return [7, 5, 4];
      //Continue for other goals
      default:
        return [];
    }
  }
}