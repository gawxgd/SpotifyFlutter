import 'package:spotify_flutter/src/join_game/join_game_model.dart';

class JoinGameController {
  final JoinGameModel model;
  final Function(bool isConnected) onConnectionChanged;
  final Function(bool isHostStarted) onHostStarted;

  JoinGameController({
    required this.model,
    required this.onConnectionChanged,
    required this.onHostStarted,
  });

  Future<void> connectToGame(String roomId) async {
    try {
      await model.connectToRoom(roomId);
      onConnectionChanged(true); // Notify the view about the connection status
    } catch (e) {
      print('Error connecting to the game: $e');
      onConnectionChanged(false);
    }
  }

  void waitForHostToStart() {
    model.waitForHostToStart().listen((isStarted) {
      if (isStarted) {
        onHostStarted(true); // Notify the view that the host has started
      }
    });
  }
}
