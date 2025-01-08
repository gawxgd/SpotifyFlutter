import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_view_model.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:spotify_flutter/src/webRtc/peerdart.dart';
import 'package:spotify_flutter/src/webRtc/peersignalingbase.dart';
import 'package:spotify_flutter/src/webRtc/signaling.dart';

class GameLobbyController {
  final GameLobbyViewModel viewModel;
  final Signaling signaling = Signaling();
  final PeerSignaling peerSignaling = PeerSignaling();
  final HostPeerSignaling hostPeerSignaling = HostPeerSignaling();
  User? hostPlayer;

  GameLobbyController(this.viewModel);

  Future<void> initializeHost() async {
    // String roomId = await signaling.createRoom();
    //String roomId = await peerSignaling.createRoom();
    String roomId = await hostPeerSignaling.createRoom();
    viewModel.updateDeepLink(
        'https://groovecheck-6bbf7.web.app/joingame?roomId=$roomId');

    hostPeerSignaling.onMessageReceived = (message) {
      debugPrint("goooowno");
      debugPrint(message);
      final decodedMessage = jsonDecode(message);
      final user = User.fromJson(decodedMessage);
      viewModel.addPlayer(user);
    };
  }

  Future<bool> startGameAsync() async {
    return await hostPeerSignaling.sendMessageAsync("start");
  }

  Future<void> sendMessageToPlayers(Map<String, dynamic> message) async {
    await signaling.sendMessage(message);
  }

  void dispose() {
    hostPeerSignaling.close();
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

  Future<void> addHostPlayer() async {
    final spotifyApi = getService<SpotifyApi>();
    if (spotifyApi != null) {
      final hostPlayer = await spotifyApi.me.get();
      viewModel.addPlayer(hostPlayer);
      this.hostPlayer = hostPlayer;
    }
  }

  bool isHostPlayer(User player) {
    return player.id == hostPlayer?.id;
  }

  void deletePlayer(User player) {
    if (player.id != null) {
      viewModel.removePlayerById(player.id!);
    } // Remove the player from the list
  }
}
