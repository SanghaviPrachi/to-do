import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
              'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDcvLsdUEbkgVp-NS_5v_8UQz2yhAkkLjA',
    appId: '1:1028974052224:android:dc5a5a89aa774e21823765',
    messagingSenderId: 'YOUR_ANDROID_MESSAGING_SENDER_ID',
    projectId: 'to-do-7c69d',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyC4fwyV89BsqpYKEDR8ieaNSbPeng-PTOg",
    appId: "1:1028974052224:ios:3ecbf2e5a4f09421823765",
    messagingSenderId: "YOUR_IOS_MESSAGING_SENDER_ID",
    projectId: "to-do-7c69d",
    storageBucket: "YOUR_IOS_STORAGE_BUCKET",
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: "YOUR_MACOS_API_KEY",
    appId: "1:1028974052224:macos:3ecbf2e5a4f09421823765",
    messagingSenderId: "YOUR_MACOS_MESSAGING_SENDER_ID",
    projectId: "to-do-7c69d",
    storageBucket: "YOUR_MACOS_STORAGE_BUCKET",
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "YOUR_WEB_API_KEY",
    appId: "1:1028974052224:web:3ecbf2e5a4f09421823765",
    messagingSenderId: "YOUR_WEB_MESSAGING_SENDER_ID",
    projectId: "to-do-7c69d",
    storageBucket: "YOUR_WEB_STORAGE_BUCKET",
  );
}
