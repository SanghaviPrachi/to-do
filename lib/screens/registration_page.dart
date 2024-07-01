import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'auth_wrapper.dart';
import '../widgets/error_dialog.dart';

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
    if (_formKey.currentState?.validate() ?? false) {
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
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => AuthWrapper()),
          );
        } catch (e) {
          showDialog(
            context: context,
            builder: (context) => ErrorDialog(message: e.toString()),
          );
        }
      } else {
        showDialog(
          context: context,
          builder: (context) => ErrorDialog(message: 'Passwords do not match'),
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
