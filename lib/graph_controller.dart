import 'package:meal_planner/graph_widget.dart';

class GraphController {

  //Replace var when type is known
  var userData;

  late ProgressGraphWidget graph;

  GraphController(data) {
    userData = data;
    graph = ProgressGraphWidget(goalData: []);

    //should actually pull goal out of data
    updateGraph("calories");
  }

  void updateGraph(var goal) {
    switch (goal) {
      case "calories":
        //hardcoded data for now
        graph = ProgressGraphWidget(goalData: [2, 5, 10, 5]);
        break;
      case "savings":
        graph = ProgressGraphWidget(goalData: [7, 5, 4]);
        break;
      //Continue for other goals
      default:
        graph = ProgressGraphWidget(goalData: [1, 2, 3, 5, 6, 7]);
    }
  }
}