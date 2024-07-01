import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/task_list.dart';
import '../models/task.dart'; // Import the Task model
import '../widgets/task_list_item.dart';
import 'login_page.dart';

class TaskListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final taskList = Provider.of<TaskList>(context);

    // Fetch tasks when the screen is first built
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      taskList.fetchTasks();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do App'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: ChangeNotifierProvider.value(
        value: taskList,
        child: Consumer<TaskList>(
          builder: (context, taskList, _) {
            if (taskList.tasks.isEmpty) {
              return Center(child: Text('No tasks available.'));
            }
            return ListView.builder(
              itemCount: taskList.tasks.length,
              itemBuilder: (context, index) {
                final task = taskList.tasks[index]; // Retrieve the task object

                return TaskListItem(
                  task: task, // Pass the task object to TaskListItem
                  toggleTaskCompletion: () => taskList.toggleTaskCompletion(index),
                  deleteTask: () => taskList.deleteTask(index),
                  editTask: (newName) {
                    taskList.editTaskName(index, newName); // Edit task name
                  },
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final TextEditingController _controller = TextEditingController();

              return AlertDialog(
                title: Text('Add Task'),
                content: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Enter task name',
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: Text('Add'),
                    onPressed: () {
                      final taskName = _controller.text.trim();
                      if (taskName.isNotEmpty) {
                        taskList.addTask(taskName);
                      }
                      Navigator.of(context).pop();
                      _controller.clear();
                    },
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
