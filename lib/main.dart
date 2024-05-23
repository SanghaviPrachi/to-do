// Importing necessary packages
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Main function to run the app
void main() {
  runApp(MyApp());
}

// Definition of a Task class
class Task {
  String name; // Name of the task
  bool isCompleted; // Completion status of the task

  // Constructor with an optional named parameter
  Task(this.name, {this.isCompleted = false});
}

// Definition of TaskList class which extends ChangeNotifier
class TaskList extends ChangeNotifier {
  List<Task> _tasks = []; // List to hold tasks

  // Getter for accessing the tasks list
  List<Task> get tasks => _tasks;

  // Method to add a task
  void addTask(String name) {
    _tasks.add(Task(name));
    notifyListeners(); // Notify listeners (widgets) about the change
  }

  // Method to toggle task completion status
  void toggleTaskCompletion(int index) {
    _tasks[index].isCompleted = !_tasks[index].isCompleted;
    notifyListeners(); // Notify listeners about the change
  }

  // Method to delete a task
  void deleteTask(int index) {
    _tasks.removeAt(index);
    notifyListeners(); // Notify listeners about the change
  }
}

// Definition of the main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Providing TaskList to the widget tree
    return ChangeNotifierProvider(
      create: (context) => TaskList(),
      child: MaterialApp(
        title: 'To-Do App',
        debugShowCheckedModeBanner: false,// App title
        theme: ThemeData(
          primarySwatch: Colors.blue, // Theme color
        ),
        home: LoginPage(), // Starting screen of the app
      ),
    );
  }
}

// Login page widget
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  // Dummy credentials
  final Map<String, String> _registeredUsers = {};

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (_registeredUsers[_email] == _password) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TaskListScreen()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid email or password')),
        );
      }
    }
  }

  void _navigateToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RegistrationPage(_registeredUsers)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value ?? '';
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _login,
                child: Text('Login'),
              ),
              TextButton(
                onPressed: _navigateToRegistration,
                child: Text('Don\'t have an account? Register here.'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Registration page widget
class RegistrationPage extends StatefulWidget {
  final Map<String, String> registeredUsers;

  RegistrationPage(this.registeredUsers);

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  void _register() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (_password == _confirmPassword) {
        if (!widget.registeredUsers.containsKey(_email)) {
          widget.registeredUsers[_email] = _password;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Successful')),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Email already registered')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Passwords do not match')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registration'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  return null;
                },
                onSaved: (value) {
                  _email = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _password = value ?? '';
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  return null;
                },
                onSaved: (value) {
                  _confirmPassword = value ?? '';
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _register,
                child: Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Definition of the screen widget displaying the task list
class TaskListScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController(); // Controller for text input

  @override
  Widget build(BuildContext context) {
    final taskList = Provider.of<TaskList>(context); // Accessing TaskList from the context

    // Building the screen layout
    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do APP'), // AppBar title
      ),
      body: ListView.builder(
        itemCount: taskList.tasks.length, // Number of tasks
        itemBuilder: (context, index) {
          final task = taskList.tasks[index]; // Getting a task
          return ListTile(
            title: Text(task.name), // Displaying task name
            leading: Checkbox(
              value: task.isCompleted, // Checkbox value based on task completion status
              onChanged: (newValue) {
                taskList.toggleTaskCompletion(index); // Toggling task completion
              },
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    // Show a dialog to edit the task
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
                  icon: Icon(Icons.delete), // Delete icon
                  onPressed: () {
                    taskList.deleteTask(index); // Deleting the task
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add), // Icon for the floating button
        onPressed: () {
          // Show a dialog to add a new task
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
