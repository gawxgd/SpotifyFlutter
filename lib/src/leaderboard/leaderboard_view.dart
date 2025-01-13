import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/leaderboard/leaderboard_cubit.dart';
import 'package:spotify_flutter/src/components/user_component.dart';

class LeaderboardView extends StatelessWidget {
  static const routeName = '/leaderboard';
  static const name = 'leaderboard';

  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LeaderboardCubit()..initalize(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: BlocBuilder<LeaderboardCubit, LeaderboardState>(
            builder: (context, state) {
              final usersScore = state.usersScore;

              if (usersScore.isEmpty) {
                return LeavingConfirmationPopscope(
                  onDispose: context.read<LeaderboardCubit>().leave,
                  child: const Center(
                    child: Text('No users in the leaderboard yet!'),
                  ),
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
                            color: Theme.of(context)
                                .primaryColor, // Use primary color
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
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            // Add your action here
          },
          icon: Icon(
            Icons.skip_next,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          label: Text(
            'Skip Question',
            style: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          ),
          tooltip: 'Skip to the next question',
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
