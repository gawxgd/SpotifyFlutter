import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game/game_cubit.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class CommunicationProtocol {
  static const startGameValue = "start";
  static const newPlayerConnectedValue = "player_connected";
  static const userSongsValue = "user_songs";
  static const requestUserSongsValue = "request_user_songs";
  static const endOfTheRoundValue = "end_of_round";

  static const typeField = "type";
  static const userField = "user";
  static const userIdField = "user_id";
  static const songsListField = "song_list";

  static Map<String, dynamic> _decodeMessage(message) {
    return jsonDecode(message) as Map<String, dynamic>;
  }

  static String joinGameMessage(User spotifyUser) {
    final message = {
      CommunicationProtocol.typeField:
          CommunicationProtocol.newPlayerConnectedValue,
      CommunicationProtocol.userField: spotifyUser.toJson(),
    };
    debugPrint('Spotify user message sent:$message');
    return jsonEncode(message);
  }

  static String startGameMessage() {
    final message = {
      CommunicationProtocol.typeField: CommunicationProtocol.startGameValue
    };
    return jsonEncode(message);
  }

  static String requestUserSongsMessage() {
    final message = {
      CommunicationProtocol.typeField:
          CommunicationProtocol.requestUserSongsValue
    };
    return jsonEncode(message);
  }

  static String userSongsMessage(List<Track> songs, User user) {
    final message = {
      CommunicationProtocol.typeField: CommunicationProtocol.userSongsValue,
      CommunicationProtocol.userIdField: user.id,
      CommunicationProtocol.songsListField:
          songs.map((song) => song.toJson()).toList()
    };
    debugPrint(jsonEncode(message));
    return jsonEncode(message);
  }

  static String endOfTheRoundMessage() {
    final message = {
      CommunicationProtocol.typeField: CommunicationProtocol.endOfTheRoundValue,
    };
    return jsonEncode(message);
  }

  static void onMessageReceivedHost(message, DataConnection connection,
      Function(User user, DataConnection connection) addPlayerCallback) {
    final decodedMessage = _decodeMessage(message);
    final type = decodedMessage[typeField];

    switch (type) {
      case newPlayerConnectedValue:
        {
          final playerMessage = decodedMessage[userField];
          _onNewPlayerConnected(playerMessage, connection, addPlayerCallback);
        }
      case userSongsValue:
        {
          final songsList = decodedMessage[songsListField];
          final userId = decodedMessage[userIdField];
          _onSongListRecived(songsList, userId);
        }
    }
  }

  static void _onNewPlayerConnected(
      Map<String, dynamic> playerMessage,
      DataConnection connection,
      Function(User user, DataConnection connection) addPlayerCallback) {
    debugPrint("New player connected");
    debugPrint(playerMessage.toString());

    final user = User.fromJson(playerMessage);
    addPlayerCallback(user, connection);
  }

  static void _onSongListRecived(List<dynamic> songListJson, String userId) {
    List<Track> songList =
        songListJson.map((song) => Track.fromJson(song)).toList();
    final gameCubit = getIt.get<GameCubit>();
    gameCubit.loadUserSongs(songList, userId);
  }

  static void onMessageReceivedPlayer(message, VoidCallback callback) {
    final decodedMessage = _decodeMessage(message);
    final type = decodedMessage[typeField];

    switch (type) {
      case startGameValue:
        debugPrint('the host has started the game');
        callback();
        break;
      case requestUserSongsValue:
        {
          debugPrint("host requested my songs");
          onHostRequestedUserSongs();
        }
      case endOfTheRoundValue:
        {
          debugPrint("the round has ended");
        }
    }
  }

  static void onHostRequestedUserSongs() async {
    final joiningPeerSignaling = getIt.get<JoiningPeerSignaling>();
    final spotifyApi = getIt.get<SpotifyApi>();
    final user = await spotifyApi.me.get();
    final tracksPages = spotifyApi.me.topTracks();
    final tracks = await tracksPages.getPage(10);
    List<Track> songs = [];
    if (tracks.items != null && tracks.items!.isNotEmpty) {
      songs = tracks.items!.take(10).toList();
    }

    await joiningPeerSignaling.sendMessageAsync(userSongsMessage(songs, user));
  }
}
