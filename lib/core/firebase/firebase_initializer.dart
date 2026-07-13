import 'package:firebase_core/firebase_core.dart';

import '../../firebase_options.dart';

/// Bootstraps Firebase before the app widget tree mounts.
abstract final class FirebaseInitializer {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}
