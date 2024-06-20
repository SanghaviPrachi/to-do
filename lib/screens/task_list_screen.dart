import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/task_list.dart';
import '../widgets/task_list_item.dart';
import 'login_page.dart';

class TaskListScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskList = Provider.of<TaskList>(context);

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
      body: FutureBuilder(
        future: taskList.fetchTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (taskList.tasks.isEmpty) {
            return Center(child: Text('No tasks available.'));
          }
          return ListView.builder(
            itemCount: taskList.tasks.length,
            itemBuilder: (context, index) {
              return TaskListItem(
                task: taskList.tasks[index],
                toggleTaskCompletion: () => taskList.toggleTaskCompletion(index),
                deleteTask: () => taskList.deleteTask(index),
                editTask: (newName) {
                  taskList.tasks[index].name = newName;
                  taskList.notifyListeners();
                },
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
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
