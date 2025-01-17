import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/game_host/game_view.dart';
import 'package:spotify_flutter/src/game_player/game_player_view.dart';
import 'package:spotify_flutter/src/leaderboard/leaderboard_cubit.dart';
import 'package:spotify_flutter/src/components/user_component.dart';

class LeaderboardView extends StatelessWidget {
  static const routeName = '/leaderboard';
  static const name = 'leaderboard';
  final bool isHost;

  const LeaderboardView({super.key, required this.isHost});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaderboardCubit()..initalize(isHost),
      child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
              builder: (context, state) {
                final usersScore = state.usersScore;
                if (state.isNewRound == true && isHost == false) {
                  context.go(GamePlayerView.routeName);
                }
                if (usersScore.isEmpty) {
                  return LeavingConfirmationPopscope(
                    onDispose: context.read<LeaderboardCubit>().leave,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }

                return LeavingConfirmationPopscope(
                  onDispose: context.read<LeaderboardCubit>().leave,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Leaderboard',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ),
                      ),
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final userScore = usersScore[index];
                            return UserComponent(
                              userName:
                                  '${index + 1}. ${userScore.key.displayName} score: ${userScore.value}',
                              userImageUrl:
                                  userScore.key.images?.firstOrNull?.url ?? '',
                              onDelete: () {},
                              isHost: false,
                            );
                          },
                          childCount: usersScore.length,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          floatingActionButton: isHost
              ? FloatingActionButton.extended(
                  onPressed: () {
                    context.go(GameHostView.routeName);
                  },
                  icon: Icon(
                    Icons.skip_next,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  label: Text(
                    'Skip Question',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary),
                  ),
                  tooltip: 'Skip to the next question',
                  backgroundColor: Theme.of(context).colorScheme.primary,
                )
              : null),
    );
  }
}
