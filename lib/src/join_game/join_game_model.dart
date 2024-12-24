import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/signaling.dart';

class JoinGameModel {
  final Signaling _signaling = Signaling();

  Future<void> connectToRoom(String roomId) async {
    await _signaling.joinRoom(roomId);

    final spotifyApi = getService<SpotifyApi>();

    if (spotifyApi != null) {
      final spotifyUser = await spotifyApi.me.get();
      sendSpotifyUserMessage(spotifyUser.toJson());
      print('Connected to room: $roomId');
    }
  }

  Stream<bool> waitForHostToStart() async* {
    // Simulate waiting for the host
    await Future.delayed(const Duration(seconds: 5));
    yield true; // Replace with actual server-side logic
  }

  void setOnMessageCallback(OnMessageCallback callback) {
    _signaling.onMessageReceived = callback;
  }

  Future<void> sendSpotifyUserMessage(Map<String, dynamic> spotifyUser) async {
    final message = {
      'type': 'player_joined',
      'user': spotifyUser,
    };

    await _signaling.sendMessage(message);
    print('Spotify user message sent: $message');
  }
}
