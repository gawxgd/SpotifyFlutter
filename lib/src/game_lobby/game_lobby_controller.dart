import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:peerdart/peerdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_view_model.dart';
import 'package:spotify_flutter/src/webRtc/communication_protocol.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:spotify_flutter/src/webRtc/peerdart.dart';
import 'package:spotify_flutter/src/webRtc/signaling.dart';

class GameLobbyController {
  final GameLobbyViewModel viewModel;
  final Signaling signaling = Signaling();
  final PeerSignaling peerSignaling = PeerSignaling();
  final HostPeerSignaling hostPeerSignaling = getIt.get<HostPeerSignaling>();
  User? hostPlayer;

  GameLobbyController(this.viewModel);

  Future<void> initializeHost() async {
    // String roomId = await signaling.createRoom();
    //String roomId = await peerSignaling.createRoom();
    String roomId =
        await hostPeerSignaling.createRoom(onClosedConnectionWithUser);
    viewModel.updateDeepLink(
        'https://groovecheck-6bbf7.web.app/joingame?roomId=$roomId');

    hostPeerSignaling.onMessageReceived = (message, connection) {
      onMessageReceivedEventHandler(message, connection);
    };
  }

  void onClosedConnectionWithUser(User user) {
    debugPrint("${user.id} with name ${user.displayName} disconnected");
    deleteDisconnectedPlayer(user);
  }

  void deleteDisconnectedPlayer(User user) {
    if (user.id != null) {
      viewModel.removePlayerById(user.id!);
    }
    if (hostPeerSignaling.userToDataConnectionMap.containsKey(user.id)) {
      var userWithConnection =
          hostPeerSignaling.userToDataConnectionMap[user.id];
      var connection = userWithConnection?.$2;
      if (connection != null) {
        hostPeerSignaling.removeDisconnectedConnection(connection, user);
      }
    }
  }

  void onMessageReceivedEventHandler(message, DataConnection connection) {
    debugPrint('message recived $message');
    CommunicationProtocol.onMessageReceivedHost(
        message, connection, onNewPlayerConnected);
  }

  void onNewPlayerConnected(User user, DataConnection connection) {
    viewModel.addPlayer(user);
    hostPeerSignaling.addUserToDataConnectionMapping(user, connection);
  }

  Future<bool> startGameAsync() async {
    return await hostPeerSignaling
        .sendMessageAsync(CommunicationProtocol.startGameMessage());
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
    if (hostPeerSignaling.userToDataConnectionMap.containsKey(player.id)) {
      var userWithConnection =
          hostPeerSignaling.userToDataConnectionMap[player.id];
      var connection = userWithConnection?.$2;
      if (connection != null) {
        hostPeerSignaling.closeConnectionWithPeer(connection, player);
      }
    }
  }
}
