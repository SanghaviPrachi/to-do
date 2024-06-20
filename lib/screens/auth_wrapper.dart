import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'task_list_screen.dart';
import 'login_page.dart';
import '../providers/task_list.dart';

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
