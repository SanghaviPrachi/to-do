import 'package:flutter/material.dart';
import '../models/task.dart';

class TaskListItem extends StatelessWidget {
  final Task task;
  final VoidCallback toggleTaskCompletion;
  final VoidCallback deleteTask;
  final Function(String) editTask;

  const TaskListItem({
    required this.task,
    required this.toggleTaskCompletion,
    required this.deleteTask,
    required this.editTask,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    return ListTile(
      title: Text(task.name),
      leading: Checkbox(
        value: task.isCompleted,
        onChanged: (newValue) {
          toggleTaskCompletion();
        },
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () {
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
                            editTask(editedTaskName);
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
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: deleteTask,
          ),
        ],
      ),
    );
  }
}
