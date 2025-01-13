import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/components/song_component.dart';
import 'package:spotify_flutter/src/components/square_user_component.dart';
import 'package:spotify_flutter/src/components/timer_widget.dart';
import 'package:spotify_flutter/src/game/game_cubit.dart';

class GameView extends StatelessWidget {
  static const routeName = '/game';
  static const name = 'game';

  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return LeavingConfirmationPopscope(
      // Add disposing logic if necessary
      child: BlocProvider(
        create: (_) => GameCubit()..initialize(),
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
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
                BlocBuilder<GameCubit, GameState>(
                  builder: (context, state) {
                    final cubit = context.read<GameCubit>();
                    final track = state.currentTrack;

                    return Column(
                      children: [
                        // Song information
                        track != null
                            ? SongComponent(
                                songName: track.name ?? 'Unknown Song',
                                songImageUrl:
                                    track.album?.images?.firstOrNull?.url ?? '',
                                songAuthor: track.artists?.firstOrNull?.name ??
                                    'Unknown Artist',
                              )
                            : const Text('Loading song...'),

                        const SizedBox(height: 16),

                        // Timer and Skip Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Timer
                            StreamBuilder<int>(
                              stream: cubit.timerStream,
                              builder: (context, snapshot) {
                                final remainingTime = snapshot.data ?? 30;
                                return TimerWidget(
                                    remainingTime: remainingTime);
                              },
                            ),
                            // Skip Button
                            ElevatedButton(
                                onPressed: cubit.skipQuestion,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.primary,
                                ),
                                child: Text(
                                  'Skip',
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                  ),
                                )),
                          ],
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 24),

                // User Grid
                Expanded(
                  child: BlocBuilder<GameCubit, GameState>(
                    builder: (context, state) {
                      final cubit = context.read<GameCubit>();
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 1,
                        ),
                        itemCount: state.users.length,
                        itemBuilder: (context, index) {
                          if (state.users.isEmpty) {
                            return const Center(
                                child: Text('No users available'));
                          }
                          final user = state.users[index];

                          return InkWell(
                              onTap: () => cubit.userAnswered(user),
                              child: state.answeredUser?.id == user.id
                                  ? SquareUserComponent(
                                      hasUserAnswerd:
                                          state.hasUserAnswerd ?? false,
                                      isCorrectAnswer:
                                          state.isCorrectAnswer ?? false,
                                      userName: user.displayName ?? '',
                                      userImageUrl:
                                          user.images?.firstOrNull?.url ?? '',
                                    )
                                  : SquareUserComponent(
                                      userName: user.displayName ?? '',
                                      userImageUrl:
                                          user.images?.firstOrNull?.url ?? '',
                                      isCorrectAnswer: false,
                                      hasUserAnswerd: false));
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
