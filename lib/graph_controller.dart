import 'package:meal_planner/graph_widget.dart';

class GraphController {

  //Replace var when type is known
  var userData;

  late ProgressGraphWidget graph;

  GraphController(data) {
    userData = data;
    graph = ProgressGraphWidget(dataPoints: {});

    //should actually pull goal out of data
    updateGraph("calories");
  }

  void updateGraph(var goal) {
    switch (goal) {
      case "calories":
        //hardcoded data for now
        graph = ProgressGraphWidget(dataPoints: {1: 2, 2: 7, 3: 4, 4: 5, 5: 6, 6: 10, 7: 4});
        break;
      case "savings":
        graph = ProgressGraphWidget(dataPoints: {1: 3, 2: 8, 3: 5, 4: 6, 5: 7, 6: 11, 7: 5});
        break;
      //Continue for other goals
      default:
        graph = ProgressGraphWidget(dataPoints: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0});
    }
  }
}