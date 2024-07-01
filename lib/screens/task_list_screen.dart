import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_list.dart';

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskList = Provider.of<TaskList>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
      ),
      body: ListView.builder(
        itemCount: taskList.tasks.length,
        itemBuilder: (context, index) {
          final task = taskList.tasks[index];
          return ListTile(
            title: Text(task.name),
            trailing: Checkbox(
              value: task.isCompleted,
              onChanged: (_) {
                taskList.toggleTaskCompletion(index);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          // Add your task creation logic here
        },
      ),
    );
  }
}
