class GraphController {

  GraphController(data) {
    
    //Replace with actual goal
    updateGraph("calories");
  }

  List<int> updateGraph(var goal) {
    switch (goal) {
      case "calories":
        //hardcoded data for now
        return [2, 5, 10, 5];
      case "savings":
        return [7, 5, 4];
      //Continue for other goals
      default:
        return [1, 2, 3, 5, 6, 7];
    }
  }
}