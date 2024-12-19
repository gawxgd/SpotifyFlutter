import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spotify_flutter/src/authorization/authorization_controller.dart';
import 'package:spotify_flutter/src/authorization/authorization_service.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';

import 'src/app.dart';
import 'src/settings/settings_controller.dart';
import 'src/settings/settings_service.dart';

void main() async {
  // Set up the SettingsController, which will glue user settings to multiple
  // Flutter Widgets.
  setupDependencies();
  final settingsController = SettingsController(SettingsService());

  final authorizationController =
      AuthorizationController(service: GetIt.instance<AuthorizationService>());

  // Load the user's preferred theme while the splash screen is displayed.
  // This prevents a sudden theme change when the app is first displayed.
  await settingsController.loadSettings();

  // Run the app and pass in the SettingsController. The app listens to the
  // SettingsController for changes, then passes it further down to the
  // SettingsView.
  runApp(MyApp(
    settingsController: settingsController,
    authorizationController: authorizationController,
  ));
}
