import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../providers/task_list.dart';
import 'login_page.dart'; // Import the login page

class TaskListScreen extends StatefulWidget {
  @override
  _TaskListScreenState createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  Future<void>? _fetchTasksFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_fetchTasksFuture == null) {
      final taskList = Provider.of<TaskList>(context, listen: false);
      _fetchTasksFuture = taskList.fetchTasks();
    }
  }

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
        future: _fetchTasksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          return ListView.builder(
            itemCount: taskList.tasks.length,
            itemBuilder: (context, index) {
              final task = taskList.tasks[index];
              return ListTile(
                title: Text(task.name),
                leading: Checkbox(
                  value: task.isCompleted,
                  onChanged: (newValue) {
                    taskList.toggleTaskCompletion(index);
                  },
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        _editTask(context, taskList, index);
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        taskList.deleteTask(index);
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          _addTask(context, taskList);
        },
      ),
    );
  }

  void _editTask(BuildContext context, TaskList taskList, int index) {
    final _controller = TextEditingController(text: taskList.tasks[index].name);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: 'Edit task name',
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
              child: Text('Save'),
              onPressed: () {
                final editedTaskName = _controller.text.trim();
                if (editedTaskName.isNotEmpty) {
                  taskList.tasks[index].name = editedTaskName;
                  taskList.notifyListeners();
                }
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _addTask(BuildContext context, TaskList taskList) {
    final _controller = TextEditingController();
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
              },
            ),
          ],
        );
      },
    );
  }
}
