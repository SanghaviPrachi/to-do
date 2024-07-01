import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/auth_wrapper.dart';
import 'screens/task_list_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/login_page.dart';
import 'providers/task_list.dart';
import 'providers/profile_provider.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TaskList('')),
        ChangeNotifierProvider(create: (_) => ProfileProvider()), // Add ProfileProvider
      ],
      child: MaterialApp(
        title: 'To-Do App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => AuthWrapper(),
          '/tasks': (context) => TaskListScreen(),
          '/profile': (context) => ProfileScreen(),
          '/login': (context) => LoginPage(),
        },
      ),
    );
  }
}
