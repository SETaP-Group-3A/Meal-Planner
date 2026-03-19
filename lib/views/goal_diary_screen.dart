
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