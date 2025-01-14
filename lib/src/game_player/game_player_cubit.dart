import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/communication_protocol.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class GamePlayerState {
  final List<User> users;
  final String? snackbarMessage;
  final User? currentUser;
  final Track? currentTrack;
  final bool? isCorrectAnswer;
  final bool? hasUserAnswerd;
  final User? answeredUser;
  final bool? showAnswer;
  final bool? endOfRound;
  final bool? endOfGame;
  final bool? isGameLoaded;
  GamePlayerState(
    this.users, {
    this.snackbarMessage,
    this.currentUser,
    this.currentTrack,
    this.isCorrectAnswer = false,
    this.hasUserAnswerd = false,
    this.answeredUser,
    this.showAnswer = false,
    this.endOfRound = false,
    this.endOfGame = false,
    this.isGameLoaded = false,
  });

  GamePlayerState copyWith({
    List<User>? users,
    String? snackbarMessage,
    User? currentUser,
    Track? currentTrack,
    bool? hasUserAnswerd,
    bool? isCorrectAnswer,
    User? answeredUser,
    bool? showAnswer,
    bool? endOfRound,
    bool? endOfGame,
    bool? isGameLoaded,
  }) {
    return GamePlayerState(
      users ?? this.users,
      snackbarMessage: snackbarMessage ?? this.snackbarMessage,
      currentUser: currentUser ?? this.currentUser,
      currentTrack: currentTrack ?? this.currentTrack,
      hasUserAnswerd: hasUserAnswerd ?? this.hasUserAnswerd,
      isCorrectAnswer: isCorrectAnswer ?? this.isCorrectAnswer,
      answeredUser: answeredUser ?? this.answeredUser,
      showAnswer: showAnswer ?? this.showAnswer,
      endOfRound: endOfRound ?? this.endOfRound,
      endOfGame: endOfGame ?? this.endOfGame,
      isGameLoaded: isGameLoaded ?? this.isGameLoaded,
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

    return super.close();
  }

  void initialize() async {
    final spotifyApi = getIt.get<SpotifyApi>();
    me = await spotifyApi.me.get();
    await joiningPeerSignaling.sendMessageAsync(
        CommunicationProtocol.playerRoundInitializationMessage(me!));
  }

  void loadRoundData(
      List<User> usersList, Track song, String selectedUserId, int roundTime) {
    final currentUser =
        usersList.where((user) => user.id == selectedUserId).first;
    emit(GamePlayerState(usersList,
        currentTrack: song, currentUser: currentUser));
    defaultTime = roundTime;
    emit(state.copyWith(isGameLoaded: true));
    startTimer();
  }

  Future<void> showAnswerAsync() async {
    emit(state.copyWith(showAnswer: true));
    timer?.cancel();
    await sendMyScoreAsync();
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

  Future<void> onPlayerEndOfTheRound() async {
    emit(state.copyWith(endOfRound: true));
  }

  Future<void> sendMyScoreAsync() async {
    if (state.isCorrectAnswer != null) {
      final score = state.isCorrectAnswer! ? 1 : 0;
      await joiningPeerSignaling.sendMessageAsync(
          CommunicationProtocol.playerScoreMessage(me!, score));
    }
  }

  void onPlayerEndOfGame() {
    //joiningPeerSignaling.close();
    //timer?.cancel();
    debugPrint("end of game");
    emit(state.copyWith(endOfGame: true));
  }
}
