// Firebase options generated from android/app/google-services.json and
// ios/Runner/GoogleService-Info.plist (same values `flutterfire configure` would produce).
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError('Firebase is only configured for Android and iOS.');
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD2InzN-sdx8oz1KbGR2IX-lCdOk2pYjno',
    appId: '1:990145127173:android:d7eb83cf7708320e7dcd6c',
    messagingSenderId: '990145127173',
    projectId: 'futblha',
    storageBucket: 'futblha.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjgtJsh7XKJTF4PVuHcTlDrnAvodYqhyc',
    appId: '1:990145127173:ios:1644c83efc1238d47dcd6c',
    messagingSenderId: '990145127173',
    projectId: 'futblha',
    storageBucket: 'futblha.firebasestorage.app',
    iosBundleId: 'com.raiyansoft.futblha',
  );
}
