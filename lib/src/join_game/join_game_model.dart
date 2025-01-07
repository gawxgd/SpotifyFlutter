import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/peerdart.dart';
import 'package:spotify_flutter/src/webRtc/signaling.dart';

class JoinGameModel {
  final Signaling _signaling = Signaling();
  final PeerSignaling peerSignaling = PeerSignaling();

  Future<void> connectToRoom(String roomId) async {
    await peerSignaling.joinRoom(roomId);
    // await _signaling.joinRoom(roomId);

    final spotifyApi = getService<SpotifyApi>();

    if (spotifyApi != null) {
      final spotifyUser = await spotifyApi.me.get();

      // Wait until the connection and data channel are ready
      // await _waitForConnection();

      await sendSpotifyUserMessage(spotifyUser.toJson());
      print('Connected to room: $roomId');
    }
  }

  /// Wait for WebRTC connection and DataChannel to become active
  Future<void> _waitForConnection() async {
    const maxRetries = 50; // Max wait time: 30 * 500ms = 15 seconds
    int retries = 0;

    while (retries < maxRetries) {
      final connectionState = _signaling.peerConnection?.connectionState;
      final dataChannelState = _signaling.dataChannel?.state;

      if (connectionState ==
              RTCPeerConnectionState.RTCPeerConnectionStateConnected &&
          dataChannelState == RTCDataChannelState.RTCDataChannelOpen) {
        print('Connection and DataChannel are ready.');
        return;
      }

      await Future.delayed(const Duration(milliseconds: 500));
      retries++;
    }

    //throw Exception('Failed to establish connection or DataChannel in time.');
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
    // await _signaling.sendMessage(message);
    peerSignaling.sendMessage(message.toString());
    print('Spotify user message sent: $message');
  }
}
