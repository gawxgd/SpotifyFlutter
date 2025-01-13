import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/components/score.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class LeaderboardState {
  final List<MapEntry<User, int>> usersScore;

  const LeaderboardState({this.usersScore = const []});
}

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit() : super(const LeaderboardState());
  Score? score;

  void initalize() {
    if (getIt.isRegistered<Score>()) {
      score = getIt.get<Score>();
      for (var item in score!.usersScore) {
        debugPrint(item.key.id);
      }
      emit(LeaderboardState(usersScore: score!.usersScore));
    } else {
      debugPrint("score not registered");
    }
  }

  void leave() {
    if (getIt.isRegistered<HostPeerSignaling>()) {
      getIt.get<HostPeerSignaling>().close();
    }
    if (getIt.isRegistered<JoiningPeerSignaling>()) {
      getIt.get<JoiningPeerSignaling>().close();
    }
  }
}
