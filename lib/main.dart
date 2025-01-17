import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spotify_flutter/src/authorization/authorization_controller.dart';
import 'package:spotify_flutter/src/authorization/authorization_service.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'firebase_options.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: "secrets.env");

  setupDependencies();
  final settingsController = SettingsController(SettingsService());

  final authorizationController =
      AuthorizationController(service: GetIt.instance<AuthorizationService>());

  await settingsController.loadSettings();

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp(
    settingsController: settingsController,
    authorizationController: authorizationController,
  ));
}
