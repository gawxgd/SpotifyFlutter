import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_view_model.dart';

class GameLobbyController {
  final GameLobbyViewModel viewModel;

  GameLobbyController(this.viewModel);

  void copyDeepLink() {
    Clipboard.setData(ClipboardData(text: viewModel.deepLink));
  }

  void shareDeepLink(BuildContext context) {
    // Future feature: Integrate with sharing services (e.g., Messenger, WhatsApp)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sharing is not implemented yet.')),
    );
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
