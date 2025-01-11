import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/communication_protocol.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class JoinGameState {
  final bool isConnected;
  final bool isHostStarted;
  final bool isConnectionFailed;

  const JoinGameState({
    this.isConnected = false,
    this.isHostStarted = false,
    this.isConnectionFailed = false,
  });

  JoinGameState copyWith(
      {bool? isConnected, bool? isHostStarted, bool? isConnectionFailed}) {
    return JoinGameState(
      isConnected: isConnected ?? this.isConnected,
      isHostStarted: isHostStarted ?? this.isHostStarted,
      isConnectionFailed: isConnectionFailed ?? this.isConnectionFailed,
    );
  }
}

class JoinGameCubit extends Cubit<JoinGameState> {
  final JoiningPeerSignaling joiningPeerSignaling =
      getIt.get<JoiningPeerSignaling>();

  JoinGameCubit() : super(const JoinGameState());

  Future<void> connectToRoom(String roomId) async {
    final spotifyApi = getService<SpotifyApi>();

    if (spotifyApi == null) {
      return;
    }

    final spotifyUser = await spotifyApi.me.get();

    await joiningPeerSignaling.joinRoom(roomId, onOpen: () {
      sendSpotifyUserMessage(spotifyUser);
    },
        onError: onConnectionErrorEventHandler,
        onClosed: onConnectionErrorEventHandler);
    debugPrint('Connected to room: $roomId');

    joiningPeerSignaling.onMessageReceived =
        (message, _) => onMessageReceivedEventHandler(message);
  }

  Future<void> sendSpotifyUserMessage(User spotifyUser) async {
    joiningPeerSignaling
        .sendMessage(CommunicationProtocol.joinGameMessage(spotifyUser));
  }

  void onMessageReceivedEventHandler(dynamic message) {
    debugPrint('Message received: $message');
    CommunicationProtocol.onMessageReceivedPlayer(
        message, () => emit(state.copyWith(isHostStarted: true)));
  }

  void onConnectionErrorEventHandler() {
    emit(state.copyWith(
        isConnectionFailed: true, isConnected: false, isHostStarted: false));
  }

  Future<void> connectToGame(String roomId) async {
    // toDo make an error event handler
    try {
      await connectToRoom(roomId);
      if (!state.isConnectionFailed) {
        emit(state.copyWith(isConnected: true));
      }
    } catch (e) {
      debugPrint('Error connecting to the game: $e');
      emit(state.copyWith(isConnected: false, isConnectionFailed: true));
    }
  }

  void leaveGame() {
    if (state.isConnected) {
      joiningPeerSignaling.close();
    }
    emit(state.copyWith(isConnected: false, isHostStarted: false));
  }
}
