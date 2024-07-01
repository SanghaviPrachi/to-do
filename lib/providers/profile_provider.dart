import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfile {
  String uid;
  String name;
  String email;
  String phoneNumber;
  String? photoUrl;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.phoneNumber = '',
    this.photoUrl,
  });
}

class ProfileProvider with ChangeNotifier {
  UserProfile? _userProfile;

  UserProfile? get userProfile => _userProfile;

  Future<void> fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      final snapshot = await userRef.once();

      if (snapshot.snapshot.value != null) {
        final userData = Map<String, dynamic>.from(snapshot.snapshot.value as Map);
        _userProfile = UserProfile(
          uid: user.uid,
          name: userData['name'] ?? '',
          email: user.email!,
          phoneNumber: userData['phoneNumber'] ?? '',
          photoUrl: userData['photoUrl'],
        );
        notifyListeners();
      } else {
        _userProfile = UserProfile(
          uid: user.uid,
          name: 'Anonymous',
          email: user.email!,
        );
        notifyListeners();
      }
    }
  }

  Future<void> updateUserProfile(String newName, String newPhoneNumber) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _userProfile != null) {
      if (newPhoneNumber.length != 10 || int.tryParse(newPhoneNumber) == null) {
        throw Exception("Phone number must be 10 digits.");
      }

      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      await userRef.update({
        'name': newName,
        'phoneNumber': newPhoneNumber,
      });

      _userProfile!.name = newName;
      _userProfile!.phoneNumber = newPhoneNumber;
      notifyListeners();
    }
  }

  Future<void> updateEmail(String newEmail) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.updateEmail(newEmail);
      await user.sendEmailVerification();

      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      await userRef.update({
        'email': newEmail,
      });

      _userProfile!.email = newEmail;
      notifyListeners();
    }
  }

  Future<void> updateProfilePicture(XFile image) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _userProfile != null) {
      final filePath = 'users/${user.uid}/profile.jpg';
      final uploadTask = await FirebaseStorage.instance.ref(filePath).putFile(File(image.path));
      final photoUrl = await uploadTask.ref.getDownloadURL();

      final userRef = FirebaseDatabase.instance.ref('users/${user.uid}');
      await userRef.update({
        'photoUrl': photoUrl,
      });

      _userProfile!.photoUrl = photoUrl;
      notifyListeners();
    }
  }
}
