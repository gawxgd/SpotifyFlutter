import 'package:flutter/material.dart';
import 'package:spotify_flutter/src/authorization/authorization_controller.dart';

class AuthorizationView extends StatelessWidget {
  const AuthorizationView(
      {super.key, required this.controller, required this.onSuccess});

  static const routeName = '/authorization';

  final AuthorizationController controller;
  final VoidCallback onSuccess;

  Future<void> _authorize(BuildContext context) async {
    await controller.startAuthorization(context);
    onSuccess(); // Call the success callback
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Spotify Icon
              Icon(
                Icons.music_note, // Placeholder icon, replace with Spotify logo
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                'Login with Spotify',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                'We want to know what you listen to so we can personalize your experience.',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Login Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _authorize(context),
                child: const Text(
                  'Login with Spotify',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
