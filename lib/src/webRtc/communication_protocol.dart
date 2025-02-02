import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/components/score.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game_host/game_cubit.dart';
import 'package:spotify_flutter/src/game_player/game_player_cubit.dart';
import 'package:spotify_flutter/src/leaderboard/leaderboard_cubit.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class CommunicationProtocol {
  static const startGameValue = "start";
  static const newPlayerConnectedValue = "player_connected";
  static const userSongsValue = "user_songs";
  static const requestUserSongsValue = "request_user_songs";
  static const endOfTheRoundValue = "end_of_round";
  static const playerRoundInitializationRequestValue = "request_new_round_data";
  static const hostRoundInitializationResponseValue = "answer_new_round_data";
  static const showAnswerValue = "show_answer";
  static const myScoreValue = "player_score";
  static const playerRequestScoreValue = "get_other_players_score";
  static const hostAnswerScoreValue = "answer_other_players_score";
  static const hostStartNewRoundValue = "start_new_round";
  static const hostEndOfGameValue = "end_of_game";

  static const typeField = "type";
  static const userField = "user";
  static const userIdField = "user_id";
  static const songsListField = "song_list";
  static const usersListField = "users_list";
  static const songField = "song";
  static const roundTimeField = "round_time";
  static const scoreField = "score";
  static const scoreListField = "score_list";

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

  static String playerRoundInitializationMessage(User user) {
    final message = {
      CommunicationProtocol.typeField:
          CommunicationProtocol.playerRoundInitializationRequestValue,
      CommunicationProtocol.userIdField: user.id,
    };
    return jsonEncode(message);
  }

  static String hostRoundInitializationMessage(
      List<User> usersList, String currentUserId, Track song, int roundTime) {
    final message = {
      CommunicationProtocol.typeField:
          CommunicationProtocol.hostRoundInitializationResponseValue,
      CommunicationProtocol.usersListField:
          usersList.map((user) => user.toJson()).toList(),
      CommunicationProtocol.userIdField: currentUserId,
      CommunicationProtocol.songField: song.toJson(),
      CommunicationProtocol.roundTimeField: roundTime,
    };
    return jsonEncode(message);
  }

  static String showAnswerMessage() {
    final message = {
      CommunicationProtocol.typeField: CommunicationProtocol.showAnswerValue,
    };
    return jsonEncode(message);
  }

  static String playerScoreMessage(User user, int score) {
    final message = {
      CommunicationProtocol.typeField: CommunicationProtocol.myScoreValue,
      CommunicationProtocol.scoreField: score,
      CommunicationProtocol.userIdField: user.id,
    };
    return jsonEncode(message);
  }

  static String playerRequestScoreFromOtherPlayersMessage(String userId) {
    final message = {
      CommunicationProtocol.typeField: playerRequestScoreValue,
      CommunicationProtocol.userIdField: userId,
    };
    return jsonEncode(message);
  }

  static String hostAnswerOtherPlayersScoreMessage(
      List<MapEntry<User, int>> usersScore) {
    final message = {
      CommunicationProtocol.typeField: hostAnswerScoreValue,
      CommunicationProtocol.scoreListField: usersScore.map((entry) {
        return {
          userField: entry.key.toJson(),
          scoreField: entry.value,
        };
      }).toList(),
    };
    return jsonEncode(message);
  }

  static String hostStartNewRoundMessage() {
    final message = {
      CommunicationProtocol.typeField: hostStartNewRoundValue,
    };
    return jsonEncode(message);
  }

  static String hostEndOfGameMessage() {
    final message = {
      CommunicationProtocol.typeField: hostEndOfGameValue,
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
      case playerRoundInitializationRequestValue:
        {
          final userId = decodedMessage[userIdField];
          _onPlayerRoundInitializationRecived(userId);
        }
      case myScoreValue:
        {
          final userId = decodedMessage[userIdField];
          final score = decodedMessage[scoreField];
          _onHostRecivedScoreFromPlayer(userId, score);
        }
      case playerRequestScoreValue:
        {
          final userId = decodedMessage[userIdField];
          _onHostRecivedScoreRequest(userId);
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
    final gameCubit = getIt.get<GameHostCubit>();
    gameCubit.loadUserSongsAsync(songList, userId);
  }

  static void _onPlayerRoundInitializationRecived(String userId) {
    debugPrint('$userId request data for new round');
    final gameCubit = getIt.get<GameHostCubit>();
    gameCubit.onUserRequestedDataForNewRound(userId);
  }

  static void _onHostRecivedScoreFromPlayer(String userId, int score) {
    final gameCubit = getIt.get<GameHostCubit>();
    gameCubit.onHostRecivedScoreFromPlayer(userId, score);
  }

  static void _onHostRecivedScoreRequest(String userId) {
    final hostPeerSignaling = getIt.get<HostPeerSignaling>();
    final score = getIt.get<Score>();
    hostPeerSignaling.sendMessageToUser(
        userId,
        CommunicationProtocol.hostAnswerOtherPlayersScoreMessage(
            score.usersScore));
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
          onPlayerEndOfTheRound();
        }
      case hostRoundInitializationResponseValue:
        {
          final userList = decodedMessage[usersListField];
          final song = decodedMessage[songField];
          final selectedUserId = decodedMessage[userIdField];
          final roundTime = decodedMessage[roundTimeField];
          debugPrint(message);
          onHostRoundInitializationResponse(
              userList, song, selectedUserId, roundTime);
        }
      case showAnswerValue:
        {
          onPlayerShowAnswer();
        }
      case hostAnswerScoreValue:
        {
          final usersScore = decodedMessage[scoreListField];
          onPlayerRecivedScoreFromOtherPlayers(usersScore);
        }
      case hostStartNewRoundValue:
        {
          onPlayerRecivedNewRound();
        }
      case hostEndOfGameValue:
        {
          onPlayerRecivedEndOfGame();
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

  static void onHostRoundInitializationResponse(List<dynamic> userList,
      dynamic song, String selectedUserId, int roundTime) async {
    List<User> usersList = userList.map((user) => User.fromJson(user)).toList();
    final gamePlayerCubit = getIt.get<GamePlayerCubit>();
    gamePlayerCubit.loadRoundData(
        usersList, Track.fromJson(song), selectedUserId, roundTime);
  }

  static void onPlayerShowAnswer() {
    final gamePlayerCubit = getIt.get<GamePlayerCubit>();
    gamePlayerCubit.showAnswerAsync();
  }

  static void onPlayerEndOfTheRound() {
    final gamePlayerCubit = getIt.get<GamePlayerCubit>();
    gamePlayerCubit.onPlayerEndOfTheRound();
  }

  static void onPlayerRecivedScoreFromOtherPlayers(List<dynamic> usersScore) {
    final usersScoreList = usersScore.map<MapEntry<User, int>>((entry) {
      final userMap = entry[userField];
      final score = entry[scoreField];
      final user = User.fromJson(userMap);

      return MapEntry(user, score);
    }).toList();
    final leaderboardCubit = getIt.get<LeaderboardCubit>();
    leaderboardCubit.onRecivedScoreFromOtherPlayersAsync(usersScoreList);
  }

  static void onPlayerRecivedNewRound() {
    final leaderboardCubit = getIt.get<LeaderboardCubit>();
    leaderboardCubit.onPlayerRecivedNewRound();
  }

  static void onPlayerRecivedEndOfGame() {
    final gamePlayerCubit = getIt.get<GamePlayerCubit>();
    gamePlayerCubit.onPlayerEndOfGame();
  }
}
