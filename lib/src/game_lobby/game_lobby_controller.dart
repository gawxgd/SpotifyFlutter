import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_view_model.dart';
import 'package:spotify_flutter/src/webRtc/signaling.dart';

class GameLobbyController {
  final GameLobbyViewModel viewModel;
  final Signaling signaling = Signaling();

  GameLobbyController(this.viewModel);

  Future<void> initializeHost() async {
    String roomId = await signaling.createRoom();
    viewModel.updateDeepLink(
        'https://groovecheck-6bbf7.web.app/joingame?roomId=$roomId');

    signaling.onMessageReceived = (message) {
      if (message['type'] == 'player_joined') {
        User newUser = message['user'] as User;
        viewModel.addPlayer(newUser);
      }
    };
  }

  Future<void> sendMessageToPlayers(Map<String, dynamic> message) async {
    await signaling.sendMessage(message);
  }

  void dispose() {
    signaling.peerConnection?.close();
    signaling.peerConnection = null;
  }

  void copyDeepLink() {
    Clipboard.setData(ClipboardData(text: viewModel.deepLink));
  }

  Future<void> shareDeepLink(BuildContext context) async {
    final result =
        await Share.share('Play GrooveCheck with me ${viewModel.deepLink}');

    if (result.status == ShareResultStatus.success) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invite sent succesfully.')),
        );
      }
    }
  }

  Future<void> addDummyPlayers() async {
    // // Simulating player connections
    // await Future.delayed(const Duration(seconds: 1));
    // viewModel.addPlayer('Player1');
    // await Future.delayed(const Duration(seconds: 1));
    // viewModel.addPlayer('Player2');
  }
  Future<void> addHostPlayer() async {
    final spotifyApi = getService<SpotifyApi>();
    if (spotifyApi != null) {
      final hostPlayer = await spotifyApi.me.get();
      viewModel.addPlayer(hostPlayer);
    }
  }

  void deletePlayer(User player) {
    if (player.id != null) {
      viewModel.removePlayerById(player.id!);
    } // Remove the player from the list
  }
}
