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

class GameHostState {
  final List<User> users;
  final String? snackbarMessage;
  final Map<String, List<Track>> userIdToSongs;
  final User? currentUser;
  final Track? currentTrack;
  final int? remainingTime;
  final bool? isCorrectAnswer;
  final bool? hasUserAnswerd;
  final User? answeredUser;
  final int? roundNumber;
  final bool? showAnswer;
  final bool? endOfGame;
  final bool? canSkipQuestion;
  final bool? isGameLoaded;

  GameHostState(
    this.users, {
    this.snackbarMessage,
    Map<String, List<Track>>? userIdToSongs,
    this.currentUser,
    this.currentTrack,
    this.remainingTime,
    this.isCorrectAnswer = false,
    this.hasUserAnswerd = false,
    this.answeredUser,
    this.roundNumber,
    this.showAnswer = false,
    this.endOfGame = false,
    this.canSkipQuestion = true,
    this.isGameLoaded = false,
  }) : userIdToSongs = userIdToSongs ?? {};

  GameHostState copyWith({
    List<User>? users,
    String? snackbarMessage,
    Map<String, List<Track>>? userIdToSongs,
    User? currentUser,
    Track? currentTrack,
    int? remainingTime,
    bool? hasUserAnswerd,
    bool? isCorrectAnswer,
    User? answeredUser,
    int? roundNumber,
    bool? showAnswer,
    bool? endOfGame,
    bool? canSkipQuestion,
    bool? isGameLoaded,
  }) {
    return GameHostState(
      users ?? this.users,
      snackbarMessage: snackbarMessage ?? this.snackbarMessage,
      userIdToSongs: userIdToSongs ?? this.userIdToSongs,
      currentUser: currentUser ?? this.currentUser,
      currentTrack: currentTrack ?? this.currentTrack,
      remainingTime: remainingTime ?? this.remainingTime,
      hasUserAnswerd: hasUserAnswerd ?? this.hasUserAnswerd,
      isCorrectAnswer: isCorrectAnswer ?? this.isCorrectAnswer,
      answeredUser: answeredUser ?? this.answeredUser,
      roundNumber: roundNumber ?? this.roundNumber,
      showAnswer: showAnswer ?? this.showAnswer,
      endOfGame: endOfGame ?? this.endOfGame,
      canSkipQuestion: canSkipQuestion ?? this.canSkipQuestion,
      isGameLoaded: isGameLoaded ?? this.isGameLoaded,
    );
  }
}

class GameHostCubit extends Cubit<GameHostState> {
  static int defaultTime = 30;
  Timer? timer;
  final StreamController<int> timerStreamController =
      StreamController<int>.broadcast();
  final HostPeerSignaling hostPeerSignaling = getIt.get<HostPeerSignaling>();
  (User?, Track?)? question;

  Stream<int> get timerStream => timerStreamController.stream;
  Map<String, (User, int)>? userIdToPoints;
  User? host;
  bool canSkipQuestion = false;
  List<String> scoreRecivedFromUsers = [];

  GameHostCubit() : super(GameHostState([], snackbarMessage: null)) {
    if (getIt.isRegistered<GameHostCubit>()) {
      getIt.unregister<GameHostCubit>();
    }
    getIt.registerLazySingleton<GameHostCubit>(() => this);
  }

  Future<void> leave() {
    timerStreamController.close();
    timer?.cancel();
    hostPeerSignaling.close();
    if (getIt.isRegistered<GameHostCubit>()) {
      getIt.unregister<GameHostCubit>();
    }
    return super.close();
  }

  void initialize() async {
    if (getIt.isRegistered<RoundConfig>()) {
      await nextRoundInitialization();
      await hostPeerSignaling
          .sendMessageAsync(CommunicationProtocol.hostStartNewRoundMessage());
      emit(state.copyWith(isGameLoaded: true));
      startTimer();
    } else {
      await firstRoundInitialization();
    }
  }

  Future<void> firstRoundInitialization() async {
    if (getIt.isRegistered<GameSettings>()) {
      final gameSettings = getIt.get<GameSettings>();
      defaultTime = gameSettings.questionTime;
      emit(state.copyWith(roundNumber: gameSettings.rounds));
    }
    userIdToPoints = {};
    await loadUsers();
    for (var user in state.users) {
      userIdToPoints?[user.id!] = (user, 0);
      debugPrint('user.id + ${userIdToPoints?[user.id!].toString()}');
    }
    await requestUserSongs();
  }

  Future<void> nextRoundInitialization() async {
    final roundConfig = getIt.get<RoundConfig>();
    emit(GameHostState(roundConfig.users,
        userIdToSongs: roundConfig.userIdToSongs,
        roundNumber: roundConfig.roundNumber));

    question = getQuestion();
    emit(state.copyWith(currentTrack: question!.$2, currentUser: question!.$1));
    userIdToPoints = roundConfig.userIdToPoints;
    final spotifyApi = getIt.get<SpotifyApi>();
    final me = await spotifyApi.me.get();
    host = me;
    getIt.unregister<RoundConfig>();
  }

  Future<void> loadUsers() async {
    final userList = hostPeerSignaling.getUserList();
    final spotifyApi = getIt.get<SpotifyApi>();
    final me = await spotifyApi.me.get();
    userList.add(me);
    host = me;

    if (userList.isNotEmpty) {
      emit(state.copyWith(users: userList));
      debugPrint("usersLoaded");
    } else {
      emit(GameHostState([], snackbarMessage: 'No users found.'));
    }
  }

  Future<void> requestUserSongs() async {
    final updatedUserIdToSongs =
        Map<String, List<Track>>.from(state.userIdToSongs);

    final spotifyApi = getIt.get<SpotifyApi>();
    final me = await spotifyApi.me.get();
    if (me.id != null) {
      final tracks = spotifyApi.me.topTracks();
      final songs = await tracks.getPage(10);
      if (songs.items != null && songs.items!.isNotEmpty) {
        updatedUserIdToSongs[me.id!] = songs.items!.take(10).toList();
        debugPrint("added myself");
        emit(
          state.copyWith(userIdToSongs: updatedUserIdToSongs),
        );
      }
    }
    await hostPeerSignaling
        .sendMessageAsync(CommunicationProtocol.requestUserSongsMessage());
  }

  Future<void> loadUserSongsAsync(List<Track> songs, String userId) async {
    final updatedUserIdToSongs =
        Map<String, List<Track>>.from(state.userIdToSongs);

    updatedUserIdToSongs[userId] = songs;

    emit(state.copyWith(userIdToSongs: updatedUserIdToSongs));

    if (updatedUserIdToSongs.length == state.users.length) {
      question = getQuestion();

      emit(state.copyWith(
          userIdToSongs: updatedUserIdToSongs,
          currentUser: question!.$1,
          currentTrack: question!.$2,
          remainingTime: defaultTime));

      debugPrint(
          'Selected Question: User: ${question!.$1?.displayName}, Track: ${question!.$2?.name}');
      await hostPeerSignaling
          .sendMessageAsync(CommunicationProtocol.startGameMessage());
      emit(state.copyWith(isGameLoaded: true));
      startTimer();
    }
  }

  (User?, Track?) getQuestion() {
    final randomUserId = getRandomItem(state.userIdToSongs.keys.toList());
    final songs = state.userIdToSongs[randomUserId];

    if (songs != null && songs.isNotEmpty) {
      final randomTrack = getRandomItem(songs);
      final user = state.users.firstWhere((user) => user.id == randomUserId);
      return (user, randomTrack);
    }
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
        showAnswerAsync();
      } else {
        remainingTime--;
        timerStreamController.add(remainingTime);
      }
    });
  }

  Future<void> skipQuestion() async {
    final scoreList = makeScoreList();
    final score = Score(usersScore: scoreList);
    if (getIt.isRegistered<Score>()) {
      getIt.unregister<Score>();
    }
    getIt.registerSingleton(score);

    if (state.roundNumber != null) {
      if (state.roundNumber! - 1 >= 0) {
        emit(state.copyWith(roundNumber: state.roundNumber! - 1));
      } else {
        await hostPeerSignaling
            .sendMessageAsync(CommunicationProtocol.hostEndOfGameMessage());
        hostPeerSignaling.close();
        timerStreamController.close();
        timer?.cancel();
        emit(state.copyWith(endOfGame: true));
        return;
      }
    }
    final roundConfig = RoundConfig(
        users: state.users,
        userIdToPoints: userIdToPoints,
        roundNumber: state.roundNumber,
        userIdToSongs: state.userIdToSongs);
    getIt.registerSingleton(roundConfig);

    await hostPeerSignaling
        .sendMessageAsync(CommunicationProtocol.endOfTheRoundMessage());
  }

  List<MapEntry<User, int>> makeScoreList() {
    List<MapEntry<User, int>> scoreList = [];

    userIdToPoints!.forEach((userId, userStat) {
      var user = userStat.$1;
      var score = userStat.$2;
      scoreList.add(MapEntry(user, score));
      debugPrint("$user + $score");
    });

    scoreList.sort((a, b) => b.value.compareTo(a.value));
    return scoreList;
  }

  void userAnswered(User choosenUser) {
    scoreRecivedFromUsers.add(host!.id!);

    if (question != null && timer != null && timer!.isActive) {
      if (question!.$1 == choosenUser) {
        if (userIdToPoints!.containsKey(host!.id)) {
          var hostStat = userIdToPoints![host!.id];
          var user = hostStat!.$1;
          var score = hostStat.$2;
          score++;
          userIdToPoints![host!.id!] = (user, score);
        }
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

  void onUserRequestedDataForNewRound(String userId) {
    if (state.users.isNotEmpty &&
        state.currentUser != null &&
        state.currentTrack != null) {
      hostPeerSignaling.sendMessageToUser(
          userId,
          CommunicationProtocol.hostRoundInitializationMessage(state.users,
              state.currentUser!.id!, state.currentTrack!, defaultTime));
    }
  }

  Future<void> showAnswerAsync() async {
    timer?.cancel();
    emit(state.copyWith(showAnswer: true));
    await hostPeerSignaling
        .sendMessageAsync(CommunicationProtocol.showAnswerMessage());
  }

  void onHostRecivedScoreFromPlayer(String userId, int score) {
    if (userIdToPoints!.containsKey(userId)) {
      var playerStat = userIdToPoints![userId];
      var user = playerStat!.$1;
      var userScore = playerStat.$2;
      userScore += score;
      userIdToPoints![userId] = (user, userScore);
      scoreRecivedFromUsers.add(userId);

      canSkipQuestion = true;
      emit(state.copyWith(canSkipQuestion: true));
    }
  }
}
