import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class JoinGameController {
  final JoiningPeerSignaling joiningPeerSignaling = JoiningPeerSignaling();

  final Function(bool isConnected) onConnectionChanged;
  final Function(bool isHostStarted) onHostStarted;

  JoinGameController({
    required this.onConnectionChanged,
    required this.onHostStarted,
  });

  Future<bool> connectToRoom(String roomId) async {
    final spotifyApi = getService<SpotifyApi>();

    if (spotifyApi == null) {
      return false;
    }

    final spotifyUser = await spotifyApi.me.get();

    await joiningPeerSignaling.joinRoom(roomId, onOpen: () {
      sendSpotifyUserMessage(spotifyUser.toJson());
    });
    debugPrint('Connected to room: $roomId');
    joiningPeerSignaling.onMessageReceived =
        (message, _) => onMessageReceivedEventHandler(message);
    return true;
  }

  Future<void> sendSpotifyUserMessage(Map<String, dynamic> spotifyUser) async {
    final message = {
      'type': 'player_joined',
      'user': spotifyUser,
    };
    joiningPeerSignaling.sendMessage(jsonEncode(spotifyUser));
    debugPrint('Spotify user message sent: $spotifyUser');
  }

  void onMessageReceivedEventHandler(message) {
    debugPrint('message recived $message');
    switch (message) {
      case 'start':
        debugPrint('the host has started the game');
        onHostStarted(true);
    }
  }

  Future<void> connectToGame(String roomId) async {
    try {
      await connectToRoom(roomId);
      onConnectionChanged(true); // Notify the view about the connection status
    } catch (e) {
      debugPrint('Error connecting to the game: $e');
      onConnectionChanged(false);
    }
  }
}
