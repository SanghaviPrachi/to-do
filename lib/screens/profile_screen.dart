import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends StatelessWidget {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(BuildContext context) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      Provider.of<ProfileProvider>(context, listen: false).updateProfilePicture(image);
    }
  }

  Future<void> _editFieldDialog(BuildContext context, String title, TextEditingController controller, Function(String) onSave) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Enter new $title'),
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
                onSave(controller.text.trim());
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context);

    // Fetch user profile when the screen is first built
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      profileProvider.fetchUserProfile();
    });

    if (profileProvider.userProfile == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final nameController = TextEditingController(text: profileProvider.userProfile!.name);
    final phoneController = TextEditingController(text: profileProvider.userProfile!.phoneNumber);
    final emailController = TextEditingController(text: profileProvider.userProfile!.email);

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacementNamed('/login');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profileProvider.userProfile!.photoUrl != null
                        ? NetworkImage(profileProvider.userProfile!.photoUrl!)
                        : null,
                    child: profileProvider.userProfile!.photoUrl == null
                        ? Icon(Icons.person, size: 50)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.camera_alt),
                      onPressed: () => _pickImage(context),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Name: ${profileProvider.userProfile!.name}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editFieldDialog(context, 'Name', nameController, (newName) {
                  profileProvider.updateUserProfile(newName, profileProvider.userProfile!.phoneNumber);
                }),
              ),
            ),
            ListTile(
              leading: Icon(Icons.email),
              title: Text('Email: ${profileProvider.userProfile!.email}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editFieldDialog(context, 'Email', emailController, (newEmail) {
                  profileProvider.updateEmail(newEmail);
                }),
              ),
            ),
            ListTile(
              leading: Icon(Icons.phone),
              title: Text('Phone: ${profileProvider.userProfile!.phoneNumber}'),
              trailing: IconButton(
                icon: Icon(Icons.edit),
                onPressed: () => _editFieldDialog(context, 'Phone', phoneController, (newPhone) {
                  if (newPhone.length == 10 && int.tryParse(newPhone) != null) {
                    profileProvider.updateUserProfile(profileProvider.userProfile!.name, newPhone);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text("Phone number must be 10 digits."),
                    ));
                  }
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
