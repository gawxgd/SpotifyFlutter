import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/communication_protocol.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';

class GameState {
  final List<User> users;
  final String? snackbarMessage;
  final Map<String, List<Track>> userIdToSongs;
  final User? currentUser;
  final Track? currentTrack;
  final int remainingTime;

  GameState(
    this.users, {
    this.snackbarMessage,
    Map<String, List<Track>>? userIdToSongs,
    this.currentUser,
    this.currentTrack,
    this.remainingTime = GameCubit.defaultTime,
  }) : userIdToSongs = userIdToSongs ?? {};

  GameState copyWith({
    List<User>? users,
    String? snackbarMessage,
    Map<String, List<Track>>? userIdToSongs,
    User? currentUser,
    Track? currentTrack,
    int? remainingTime,
  }) {
    return GameState(
      users ?? this.users,
      snackbarMessage: snackbarMessage ?? this.snackbarMessage,
      userIdToSongs: userIdToSongs ?? this.userIdToSongs,
      currentUser: currentUser ?? this.currentUser,
      currentTrack: currentTrack ?? this.currentTrack,
      remainingTime: remainingTime ?? this.remainingTime,
    );
  }
}

class GameCubit extends Cubit<GameState> {
  static const int defaultTime = 30;
  Timer? timer;
  final StreamController<int> timerStreamController =
      StreamController<int>.broadcast();
  final HostPeerSignaling hostPeerSignaling = getIt.get<HostPeerSignaling>();

  Stream<int> get timerStream => timerStreamController.stream;

  GameCubit() : super(GameState([], snackbarMessage: null)) {
    if (getIt.isRegistered<GameCubit>()) {
      getIt.unregister<GameCubit>();
    }
    getIt.registerLazySingleton<GameCubit>(() => this);
  }

  @override
  Future<void> close() {
    timerStreamController.close();
    timer?.cancel();
    return super.close();
  }

  void initialize() async {
    await loadUsers();
    await requestUserSongs();
  }

  Future<void> loadUsers() async {
    final userList = hostPeerSignaling.getUserList();
    final spotifyApi = getIt.get<SpotifyApi>();
    final me = await spotifyApi.me.get();
    userList.add(me);

    if (userList.isNotEmpty) {
      emit(GameState(userList));
      debugPrint("usersLoaded");
    } else {
      emit(GameState([], snackbarMessage: 'No users found.'));
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
        emit(GameState(state.users, userIdToSongs: updatedUserIdToSongs));
      }
    }
    await hostPeerSignaling
        .sendMessageAsync(CommunicationProtocol.requestUserSongsMessage());
  }

  void loadUserSongs(List<Track> songs, String userId) {
    final updatedUserIdToSongs =
        Map<String, List<Track>>.from(state.userIdToSongs);

    updatedUserIdToSongs[userId] = songs;

    emit(GameState(state.users, userIdToSongs: updatedUserIdToSongs));
    debugPrint(
        updatedUserIdToSongs.length.toString() + state.users.length.toString());

    if (updatedUserIdToSongs.length == state.users.length) {
      final question = getQuestion();
      startTimer();

      emit(GameState(
        state.users,
        userIdToSongs: updatedUserIdToSongs,
        currentUser: question.$1,
        currentTrack: question.$2,
      ));
      debugPrint(
          'Selected Question: User: ${question.$1?.displayName}, Track: ${question.$2?.name}');
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
      if (remainingTime <= 1) {
        timer.cancel();
        skipQuestion();
      } else {
        remainingTime--;
        timerStreamController.add(remainingTime);
      }
    });
  }

  void skipQuestion() {}
}
