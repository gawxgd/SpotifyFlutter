import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/components/score.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';
import 'package:spotify_flutter/src/webRtc/communication_protocol.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';

class LeaderboardState {
  final List<MapEntry<User, int>> usersScore;
  final bool? isHost;
  final bool? isNewRound;

  const LeaderboardState(
      {this.usersScore = const [], this.isHost, this.isNewRound});
}

class LeaderboardCubit extends Cubit<LeaderboardState> {
  LeaderboardCubit() : super(const LeaderboardState());
  Score? score;

  Future<void> initalize(bool isHost) async {
    if (isHost == false) {
      if (getIt.isRegistered<LeaderboardCubit>()) {
        getIt.unregister<LeaderboardCubit>();
      }
      getIt.registerSingleton(this);
      emit(LeaderboardState(usersScore: [], isHost: isHost));
      requestScoreAsPlayerAsync();
      return;
    }
    if (getIt.isRegistered<Score>()) {
      score = getIt.get<Score>();
      for (var item in score!.usersScore) {
        debugPrint(item.key.id);
      }
      emit(LeaderboardState(usersScore: score!.usersScore, isHost: isHost));
    } else {
      debugPrint("score not registered");
    }
  }

  Future<void> requestScoreAsPlayerAsync() async {
    final joiningPeerSignaling = getIt.get<JoiningPeerSignaling>();
    final spotifyApi = getIt.get<SpotifyApi>();
    final me = await spotifyApi.me.get();
    await joiningPeerSignaling.sendMessageAsync(
        CommunicationProtocol.playerRequestScoreFromOtherPlayersMessage(
            me.id!));
  }

  void onRecivedScoreFromOtherPlayersAsync(
      List<MapEntry<User, int>> usersScore) {
    emit(LeaderboardState(usersScore: usersScore, isHost: state.isHost));
  }

  void leave() {
    if (getIt.isRegistered<HostPeerSignaling>() && state.isHost == true) {
      getIt.get<HostPeerSignaling>().close();
    }
    if (getIt.isRegistered<JoiningPeerSignaling>() &&
        state.isHost != null &&
        state.isHost == false) {
      getIt.get<JoiningPeerSignaling>().close();
    }
  }

  void onPlayerRecivedNewRound() {
    if (state.isHost != null && state.isHost == false) {
      emit(LeaderboardState(
          usersScore: state.usersScore,
          isHost: state.isHost,
          isNewRound: true));
    }
  }
}
