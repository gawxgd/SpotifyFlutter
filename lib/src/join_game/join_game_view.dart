import 'package:flutter/material.dart';
import 'join_game_controller.dart';
import 'join_game_model.dart';

class JoinGameView extends StatefulWidget {
  static const routeName = '/joingame';
  static const name = 'Join Game';

  const JoinGameView({super.key});

  @override
  _JoinGameViewState createState() => _JoinGameViewState();
}

class _JoinGameViewState extends State<JoinGameView> {
  late final JoinGameController _controller;
  bool _isConnected = false;
  bool _isHostStarted = false;

  @override
  void initState() {
    super.initState();

    // Initialize the controller with the model and callback functions
    final model = JoinGameModel();
    _controller = JoinGameController(
      model: model,
      onConnectionChanged: (isConnected) {
        setState(() {
          _isConnected = isConnected;
        });
      },
      onHostStarted: (isHostStarted) {
        setState(() {
          _isHostStarted = isHostStarted;
        });
      },
    );

    // Connect to the game and wait for the host to start
    _controller.connectToGame();
    _controller.waitForHostToStart();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isHostStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'The host has started the game!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to the game view
                      Navigator.pushNamed(context, '/game');
                    },
                    child: const Text('Start Playing'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isConnected
                        ? 'Waiting for the host to start...'
                        : 'Connecting to the game...',
                    style: const TextStyle(fontSize: 20),
                  ),
                  const SizedBox(height: 20),
                  if (!_isConnected) const CircularProgressIndicator(),
                ],
              ),
      ),
    );
  }
}
