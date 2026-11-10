import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';

import 'firebase_options.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/app_router.dart';

/// Enable Firebase emulators only when explicitly requested.
///
/// Default: false (use actual Firebase cloud services).
const bool useFirebaseEmulators = bool.fromEnvironment(
  'USE_FIREBASE_EMULATORS',
  defaultValue: false,
);

/// Optional custom emulator host.
///
/// Android emulator default: 10.0.2.2
/// Windows, Linux and macOS default: 127.0.0.1
const String customEmulatorHost = String.fromEnvironment(
  'FIREBASE_EMULATOR_HOST',
  defaultValue: '',
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase.
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Connect to Firebase emulators only when explicitly enabled.
  if (kDebugMode && useFirebaseEmulators) {
    final String defaultHost = defaultTargetPlatform == TargetPlatform.android
        ? '10.0.2.2'
        : '127.0.0.1';

    final String emulatorHost = customEmulatorHost.isNotEmpty
        ? customEmulatorHost
        : defaultHost;

    // Firebase Authentication Emulator.
    await FirebaseAuth.instance.useAuthEmulator(emulatorHost, 9099);

    // Cloud Firestore Emulator.
    FirebaseFirestore.instance.useFirestoreEmulator(emulatorHost, 8080);

    // Firebase Realtime Database Emulator.
    FirebaseDatabase.instance.useDatabaseEmulator(emulatorHost, 9000);

    debugPrint('FIREBASE MODE: EMULATOR');
    debugPrint('Emulator Host: $emulatorHost');
    debugPrint('Authentication Emulator: 9099');
    debugPrint('Firestore Emulator: 8080');
    debugPrint('Realtime Database Emulator: 9000');
  } else {
    debugPrint('FIREBASE MODE: CLOUD');
    debugPrint('Connected to actual Firebase services.');
  }

  runApp(const ProviderScope(child: AlertXBandApp()));
}

class AlertXBandApp extends StatelessWidget {
  const AlertXBandApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'AlertXBand',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      routerConfig: AppRouter.router,
    );
  }
}
