import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/home';

  static const name = 'Home';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Title Text
            const Text(
              'GrooveCheck',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 10), // Spacer between title and icon
            // Note Icon
            const Icon(
              Icons.music_note,
              size: 48,
              color: Colors.purple,
            ),
            const SizedBox(height: 40), // Spacer between icon and buttons
            // Start Game Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/startGame');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Start Game',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20), // Spacer
            // Join Game Button
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/joinGame');
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Join Game',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
