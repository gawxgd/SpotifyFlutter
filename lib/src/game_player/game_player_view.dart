import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/components/song_component.dart';
import 'package:spotify_flutter/src/components/square_user_component.dart';
import 'package:spotify_flutter/src/components/timer_widget.dart';
import 'package:spotify_flutter/src/end_of_game/end_of_game_view.dart';
import 'package:spotify_flutter/src/game_player/game_player_cubit.dart';
import 'package:spotify_flutter/src/leaderboard/leaderboard_view.dart';
import 'package:vibration/vibration.dart';

class GamePlayerView extends StatelessWidget {
  static const routeName = '/game_player';
  static const name = 'game_player';

  const GamePlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GamePlayerCubit>(
      create: (_) => GamePlayerCubit()..initialize(),
      child: BlocBuilder<GamePlayerCubit, GamePlayerState>(
        builder: (context, state) {
          final cubit = context.read<GamePlayerCubit>();
          final track = state.currentTrack;
          if (state.endOfRound == true) {
            context.go(LeaderboardView.routeName);
          }

          if (state.endOfGame == true) {
            context.go(EndOfGameView.routeName);
          }

          return LeavingConfirmationPopscope(
              onDispose: cubit.leave,
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: state.isGameLoaded == true
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const SizedBox(height: 64),
                            Text(
                              'Guess who listens to this:',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),

                            // Song component with timer and skip button
                            Column(
                              children: [
                                // Song information
                                track != null
                                    ? SongComponent(
                                        songName: track.name ?? 'Unknown Song',
                                        songImageUrl: track.album?.images
                                                ?.firstOrNull?.url ??
                                            '',
                                        songAuthor:
                                            track.artists?.firstOrNull?.name ??
                                                'Unknown Artist',
                                      )
                                    : const Text('Loading song...'),

                                const SizedBox(height: 16),

                                // Timer and Skip Button
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Timer
                                    StreamBuilder<int>(
                                      stream: cubit.timerStream,
                                      builder: (context, snapshot) {
                                        final remainingTime =
                                            snapshot.data ?? 30;

                                        return TimerWidget(
                                            remainingTime: remainingTime);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // User Grid
                            Expanded(
                              child: state.users.isEmpty
                                  ? const Center(
                                      child: Text('No users available'))
                                  : GridView.builder(
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 16,
                                        mainAxisSpacing: 16,
                                        childAspectRatio: 1,
                                      ),
                                      itemCount: state.users.length,
                                      itemBuilder: (context, index) {
                                        final user = state.users[index];

                                        return InkWell(
                                          onTap: () async {
                                            final canVibrate =
                                                await Vibration.hasVibrator();
                                            if (canVibrate == true) {
                                              Vibration.vibrate();
                                            }

                                            if (state.showAnswer == false) {
                                              cubit.userAnswered(user);
                                            }
                                          },
                                          child: SquareUserComponent(
                                            hasUserAnswerd: state.showAnswer !=
                                                        null &&
                                                    state.showAnswer! &&
                                                    state.answeredUser?.id ==
                                                        user.id
                                                ? state.hasUserAnswerd ?? false
                                                : false,
                                            isCorrectAnswer: state
                                                        .answeredUser?.id ==
                                                    user.id
                                                ? state.isCorrectAnswer ?? false
                                                : false,
                                            userName: user.displayName ?? '',
                                            isSelected:
                                                state.hasUserAnswerd != null &&
                                                    state.hasUserAnswerd! &&
                                                    state.answeredUser?.id ==
                                                        user.id,
                                            userImageUrl:
                                                user.images?.firstOrNull?.url ??
                                                    '',
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        )
                      : const Center(
                          child: CircularProgressIndicator(),
                        ),
                ),
              ));
        },
      ),
    );
  }
}
