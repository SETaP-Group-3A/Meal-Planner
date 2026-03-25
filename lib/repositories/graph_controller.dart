import 'package:meal_planner/models/weekly_goals.dart';

class GraphController {

  List<Goal> userData;

  GraphController(this.userData) {
    updateGraph(userData[0].id);
  }

  List<int> updateGraph(String goal) {  
    //Will need to switch goals here in future
    return userData.map((g) => g.id == goal ? g.value.toInt() : 0).toList();
  }
}