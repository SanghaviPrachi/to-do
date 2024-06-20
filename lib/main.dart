import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class Task {
  String id;
  String name;
  bool isCompleted;

  Task(this.name, {this.isCompleted = false, this.id = ''});
}

class TaskList with ChangeNotifier {
  List<Task> _tasks = [];
  final String userId;
  final DatabaseReference _tasksRef;

  TaskList(this.userId)
      : _tasksRef = FirebaseDatabase.instance.ref('users').child(userId).child('tasks');

  List<Task> get tasks => _tasks;

  Future<void> fetchTasks() async {
    final snapshot = await _tasksRef.once();
    _tasks = snapshot.snapshot.children.map((task) => Task(
      task.child('name').value as String,
      isCompleted: task.child('isCompleted').value as bool,
      id: task.key?? '',
    )).toList();
    notifyListeners();
  }

  Future<void> addTask(String name) async {
    final newTask = Task(name);
    final taskRef = await _tasksRef.push();
    newTask.id = taskRef.key?? '';
    await taskRef.set({
      'name': newTask.name,
      'isCompleted': newTask.isCompleted,
    });
    _tasks.add(newTask);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(int index) async {
    final task = _tasks[index];
    task.isCompleted =!task.isCompleted;
    await _tasksRef.child(task.id).update({
      'isCompleted': task.isCompleted,
    });
    notifyListeners();
  }

  Future<void> deleteTask(int index) async {
    final task = _tasks[index];
    await _tasksRef.child(task.id).remove();
    _tasks.removeAt(index);
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return ChangeNotifierProvider(
            create: (_) => TaskList(snapshot.data!.uid),
            child: TaskListScreen(),
          );
        }
        return LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';

  void _login() async {
    if (_formKey.currentState?.validate()?? false) {
      _formKey.currentState?.save();
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _email,
          password: _password,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login Successful')),
        );
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => TaskListScreen()),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to sign in: ${e.toString()}')),
        );
      }
    }
  }

  void _navigateToRegistration() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => RegistrationPage()),
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
                  _email = value?? '';
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
                  _password = value?? '';
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

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _confirmPassword = '';

  void _register() async {
    if (_formKey.currentState?.validate()?? false) {
      _formKey.currentState?.save();
      if (_password == _confirmPassword) {
        try {
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
            email: _email,
            password: _password,
          );
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Registration Successful')),
          );
          Navigator.of(context).pop();
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to register: ${e.toString()}')),
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
                  _email = value?? '';
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
                  _password = value?? '';
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
                  _confirmPassword = value?? '';
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

class TaskListScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final taskList = Provider.of<TaskList>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('To-Do APP'),
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
      body: taskList.tasks.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
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
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    taskList.deleteTask(index);
                  },
                ),
              ],
            ),
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