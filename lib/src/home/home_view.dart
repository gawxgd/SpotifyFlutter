import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/join_game/join_game_view.dart';
import 'package:spotify_flutter/src/prepare_game/prepare_game_view.dart';

class HomeView extends StatelessWidget {
  static const routeName = '/home';

  static const name = 'Home';

  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Title Text
              Text(
                'GrooveCheck',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(height: 10),
              // Note Icon
              Icon(
                Icons.music_note,
                size: 48,
                color: Theme.of(context).primaryColor,
              ),
              const SizedBox(height: 40),
              // Start Game Button
              ElevatedButton(
                onPressed: () {
                  context.push(PrepareGameView.routeName);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Start Game',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
              const SizedBox(height: 20),
              // Join Game Button
              ElevatedButton(
                onPressed: () {
                  context.push(JoinGameView.routeName);
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Join Game',
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.onPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
