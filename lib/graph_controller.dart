import 'package:meal_planner/graph_widget.dart';

class GraphController {

  //Replace var when type is known
  var userData;

  late ProgressGraphWidget graph;

  GraphController(data) {
    userData = data;
    graph = ProgressGraphWidget(dataPoints: {});
  }
}