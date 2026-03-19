import 'package:flutter/material.dart';

class GoalDiaryScreen extends StatelessWidget {
  const GoalDiaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goal Diary'),
      ),
      body: const Center(
        child: Text('This is the Goal Diary Screen'),
      ),
    );
  }
}

class DayGoalWidget extends StatelessWidget {
  final String day;
  final String goal;

  const DayGoalWidget({super.key, required this.day, required this.goal});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(day),
        subtitle: Text(goal),
      ),
    );
  }
}