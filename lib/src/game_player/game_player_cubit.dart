import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/components/game_settings.dart';
import 'package:spotify_flutter/src/components/score.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/game_host/round_config.dart';
import 'package:spotify_flutter/src/webRtc/communication_protocol.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class GamePlayerState {
  final List<User> users;
  final String? snackbarMessage;
  final User? currentUser;
  final Track? currentTrack;
  final bool? isCorrectAnswer;
  final bool? hasUserAnswerd;
  final User? answeredUser;

  GamePlayerState(
    this.users, {
    this.snackbarMessage,
    this.currentUser,
    this.currentTrack,
    this.isCorrectAnswer = false,
    this.hasUserAnswerd = false,
    this.answeredUser,
  });

  GamePlayerState copyWith({
    List<User>? users,
    String? snackbarMessage,
    User? currentUser,
    Track? currentTrack,
    bool? hasUserAnswerd,
    bool? isCorrectAnswer,
    User? answeredUser,
  }) {
    return GamePlayerState(
      users ?? this.users,
      snackbarMessage: snackbarMessage ?? this.snackbarMessage,
      currentUser: currentUser ?? this.currentUser,
      currentTrack: currentTrack ?? this.currentTrack,
      hasUserAnswerd: hasUserAnswerd ?? this.hasUserAnswerd,
      isCorrectAnswer: isCorrectAnswer ?? this.isCorrectAnswer,
      answeredUser: answeredUser ?? this.answeredUser,
    );
  }
}

class GamePlayerCubit extends Cubit<GamePlayerState> {
  static int defaultTime = 30;
  Timer? timer;
  final StreamController<int> timerStreamController =
      StreamController<int>.broadcast();
  final JoiningPeerSignaling joiningPeerSignaling =
      getIt.get<JoiningPeerSignaling>();

  Stream<int> get timerStream => timerStreamController.stream;
  User? me;

  GamePlayerCubit() : super(GamePlayerState([], snackbarMessage: null)) {
    if (getIt.isRegistered<GamePlayerCubit>()) {
      getIt.unregister<GamePlayerCubit>();
    }
    getIt.registerSingleton(this);
  }

  Future<void> leave() {
    timerStreamController.close();
    timer?.cancel();
    joiningPeerSignaling.close();
    // if (getIt.isRegistered<GameHostCubit>()) {
    //   getIt.unregister<GameHostCubit>();
    // }
    return super.close();
  }

  void initialize() async {
    final spotifyApi = getIt.get<SpotifyApi>();
    me = await spotifyApi.me.get();
    await joiningPeerSignaling.sendMessageAsync(
        CommunicationProtocol.playerRoundInitializationMessage(me!));
    // if (getIt.isRegistered<RoundConfig>()) {
    //   await nextRoundInitialization();
    // } else {
    //   await firstRoundInitialization();
    // }
    // // send users question and start
  }

  void loadRoundData(List<User> usersList, Track song, String selectedUserId) {
    final currentUser =
        usersList.where((user) => user.id == selectedUserId).first;
    emit(GamePlayerState(usersList,
        currentTrack: song, currentUser: currentUser));
    startTimer();
  }

  Future<void> firstRoundInitialization() async {
    // if (getIt.isRegistered<GameSettings>()) {
    //   final gameSettings = getIt.get<GameSettings>();
    //   defaultTime = gameSettings.questionTime;
    //   emit(state.copyWith(roundNumber: gameSettings.rounds));
    // }
    // userIdToPoints = {};
    // await loadUsers();
    // for (var user in state.users) {
    //   userIdToPoints?[user.id!] = (user, 0);
    //   debugPrint('user.id + ${userIdToPoints?[user.id!].toString()}');
    // }
    // await requestUserSongs();
  }

  Future<void> nextRoundInitialization() async {
    // final roundConfig = getIt.get<RoundConfig>();
    // emit(GameHostState(roundConfig.users,
    //     userIdToSongs: roundConfig.userIdToSongs,
    //     roundNumber: roundConfig.roundNumber));
    // question = getQuestion();
    // emit(state.copyWith(currentTrack: question!.$2, currentUser: question!.$1));
    // userIdToPoints = roundConfig.userIdToPoints;
    // final spotifyApi = getIt.get<SpotifyApi>();
    // final me = await spotifyApi.me.get();
    // host = me;
    // getIt.unregister<RoundConfig>();
    // startTimer();
  }

  Future<void> loadUsers() async {
    // final userList = hostPeerSignaling.getUserList();
    // final spotifyApi = getIt.get<SpotifyApi>();
    // final me = await spotifyApi.me.get();
    // userList.add(me);
    // host = me;

    // if (userList.isNotEmpty) {
    //   emit(GameHostState(userList));
    //   debugPrint("usersLoaded");
    // } else {
    //   emit(GameHostState([], snackbarMessage: 'No users found.'));
    // }
  }

  Future<void> requestUserSongs() async {
    // final updatedUserIdToSongs =
    //     Map<String, List<Track>>.from(state.userIdToSongs);

    // final spotifyApi = getIt.get<SpotifyApi>();
    // final me = await spotifyApi.me.get();
    // if (me.id != null) {
    //   final tracks = spotifyApi.me.topTracks();
    //   final songs = await tracks.getPage(10);
    //   if (songs.items != null && songs.items!.isNotEmpty) {
    //     updatedUserIdToSongs[me.id!] = songs.items!.take(10).toList();
    //     debugPrint("added myself");
    //     emit(
    //       GameHostState(state.users, userIdToSongs: updatedUserIdToSongs),
    //     );
    //   }
    // }
    // await hostPeerSignaling
    //     .sendMessageAsync(CommunicationProtocol.requestUserSongsMessage());
  }

  void loadUserSongs(List<Track> songs, String userId) {
    // final updatedUserIdToSongs =
    //     Map<String, List<Track>>.from(state.userIdToSongs);

    // updatedUserIdToSongs[userId] = songs;

    // emit(GameHostState(state.users, userIdToSongs: updatedUserIdToSongs));
    // debugPrint(
    //     updatedUserIdToSongs.length.toString() + state.users.length.toString());

    // if (updatedUserIdToSongs.length == state.users.length) {
    //   question = getQuestion();

    //   emit(GameHostState(state.users,
    //       userIdToSongs: updatedUserIdToSongs,
    //       currentUser: question!.$1,
    //       currentTrack: question!.$2,
    //       remainingTime: defaultTime));

    //   startTimer();
    //   debugPrint(
    //       'Selected Question: User: ${question!.$1?.displayName}, Track: ${question!.$2?.name}');
    // }
  }

  (User?, Track?) getQuestion() {
    // final randomUserId = getRandomItem(state.userIdToSongs.keys.toList());
    // final songs = state.userIdToSongs[randomUserId];

    // if (songs != null && songs.isNotEmpty) {
    //   final randomTrack = getRandomItem(songs);
    //   final user = state.users.firstWhere((user) => user.id == randomUserId);
    //   return (user, randomTrack);
    // }
    return (null, null);
  }

  T getRandomItem<T>(List<T> list) {
    final random = Random();
    return list[random.nextInt(list.length)];
  }

  void startTimer() {
    timer?.cancel();
    timerStreamController.add(defaultTime);

    int remainingTime = defaultTime;

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingTime == 0) {
        timer.cancel();
      } else {
        remainingTime--;
        timerStreamController.add(remainingTime);
      }
    });
  }

  Future<void> skipQuestion() async {
    // // toDo send to others that the round has ended
    // // they display answeres
    // // on second click send users that they should show leaderboard
    // // show leaderboard
    // final scoreList = makeScoreList();
    // final score = Score(usersScore: scoreList);
    // if (getIt.isRegistered<Score>()) {
    //   getIt.unregister<Score>();
    // }
    // getIt.registerSingleton(score);

    // if (state.roundNumber != null) {
    //   if (state.roundNumber! - 1 >= 0) {
    //     emit(state.copyWith(roundNumber: state.roundNumber! - 1));
    //   } else {
    //     // show the game end
    //   }
    // }
    // final roundConfig = RoundConfig(
    //     users: state.users,
    //     userIdToPoints: userIdToPoints,
    //     roundNumber: state.roundNumber,
    //     userIdToSongs: state.userIdToSongs);
    // getIt.registerSingleton(roundConfig);

    // await hostPeerSignaling
    // .sendMessageAsync(CommunicationProtocol.endOfTheRoundMessage());
  }

  List<MapEntry<User, int>>? makeScoreList() {
    // List<MapEntry<User, int>> scoreList = [];

    // userIdToPoints!.forEach((userId, userStat) {
    //   var user = userStat.$1;
    //   var score = userStat.$2;
    //   scoreList.add(MapEntry(user, score));
    //   debugPrint("$user + $score");
    // });

    // scoreList.sort((a, b) => b.value.compareTo(a.value));
    // return scoreList;
    return null;
  }

  void userAnswered(User choosenUser) {
    if (state.currentUser != null && timer!.isActive) {
      if (state.currentUser == choosenUser) {
        emit(state.copyWith(
            isCorrectAnswer: true,
            hasUserAnswerd: true,
            answeredUser: choosenUser));
      } else {
        emit(state.copyWith(
            isCorrectAnswer: false,
            hasUserAnswerd: true,
            answeredUser: choosenUser));
      }
    }
  }
}
