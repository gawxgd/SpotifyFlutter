import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:peerdart/peerdart.dart';
import 'package:share_plus/share_plus.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/communication_protocol.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:vibration/vibration.dart';

class GameLobbyState {
  final String deepLink;
  final List<User> players;
  final bool gameStarted;
  final bool loading;

  const GameLobbyState({
    this.deepLink = '',
    this.players = const [],
    this.gameStarted = false,
    this.loading = true,
  });

  GameLobbyState copyWith({
    String? deepLink,
    List<User>? players,
    bool? gameStarted,
    bool? loading,
  }) {
    return GameLobbyState(
      deepLink: deepLink ?? this.deepLink,
      players: players ?? this.players,
      gameStarted: gameStarted ?? this.gameStarted,
      loading: loading ?? this.loading,
    );
  }
}

class GameLobbyCubit extends Cubit<GameLobbyState> {
  final HostPeerSignaling hostPeerSignaling = getIt.get<HostPeerSignaling>();
  User? hostPlayer;

  GameLobbyCubit() : super(const GameLobbyState());

  Future<void> initializeHost() async {
    String roomId =
        await hostPeerSignaling.createRoom(onClosedConnectionWithUser);
    emit(state.copyWith(
        deepLink: 'https://groovecheck-6bbf7.web.app/joingame?roomId=$roomId'));

    addHostPlayer();
    emit(state.copyWith(loading: false));
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
      removePlayerById(user.id!);
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

  void removePlayerById(String userId) {
    var tempPlayers = List<User>.from(state.players);
    tempPlayers.removeWhere((player) => player.id == userId);
    emit(state.copyWith(players: tempPlayers));
  }

  void onMessageReceivedEventHandler(message, DataConnection connection) {
    debugPrint('message recived $message');
    CommunicationProtocol.onMessageReceivedHost(
        message, connection, onNewPlayerConnected);
  }

  void onNewPlayerConnected(User user, DataConnection connection) {
    addPlayer(user);
    hostPeerSignaling.addUserToDataConnectionMapping(user, connection);
  }

  void addPlayer(User player) {
    var tempPlayers = List<User>.from(state.players);
    tempPlayers.add(player);
    emit(state.copyWith(players: tempPlayers));
  }

  Future<void> startGameAsync() async {
    final canVibrate = await Vibration.hasVibrator();
    if (canVibrate != null && canVibrate) {
      Vibration.vibrate();
    }
  }

  void dispose() {
    hostPeerSignaling.close();
  }

  void copyDeepLink() {
    Clipboard.setData(ClipboardData(text: state.deepLink));
  }

  Future<void> shareDeepLink(BuildContext context) async {
    // get rid of buildContext
    final result =
        await Share.share('Play GrooveCheck with me ${state.deepLink}');

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
      addPlayer(hostPlayer);
      this.hostPlayer = hostPlayer;
    }
  }

  bool isHostPlayer(User player) {
    return player.id == hostPlayer?.id;
  }

  void deletePlayer(User player) {
    if (player.id != null) {
      removePlayerById(player.id!);
    }
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
