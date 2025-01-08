import 'dart:convert';

import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';
import 'package:spotify_flutter/src/webRtc/peerdart.dart';

class JoinGameModel {
  final PeerSignaling peerSignaling = PeerSignaling();
  final JoiningPeerSignaling joiningPeerSignaling = JoiningPeerSignaling();

  Future<bool> connectToRoom(String roomId) async {

    final spotifyApi = getService<SpotifyApi>();

    if(spotifyApi == null)
    {
      return false;
    }

    final spotifyUser = await spotifyApi.me.get();

    await joiningPeerSignaling.joinRoom(roomId, onOpen: () {
      sendSpotifyUserMessage(spotifyUser.toJson());
    });
      print('Connected to room: $roomId');
      return true;
    }
  
  Stream<bool> waitForHostToStart() async* {
    // Simulate waiting for the host
    await Future.delayed(const Duration(seconds: 5));
    yield true; // Replace with actual server-side logic
  }

  Future<void> sendSpotifyUserMessage(Map<String, dynamic> spotifyUser) async {
    final message = {
      'type': 'player_joined',
      'user': spotifyUser,
    };
    joiningPeerSignaling.sendMessage(jsonEncode(spotifyUser));
    print('Spotify user message sent: $spotifyUser');
  }
}
