import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/components/song_component.dart';
import 'package:spotify_flutter/src/components/square_user_component.dart';
import 'package:spotify_flutter/src/game/game_cubit.dart';

class GameView extends StatelessWidget {
  static const routeName = '/game';
  static const name = 'game';

  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return LeavingConfirmationPopscope(
      // to do add disposing connection like in gameLobby view
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
                BlocBuilder<GameCubit, GameState>(
                  builder: (context, state) {
                    final track = state.currentTrack;
                    final user = state.currentUser;
                    if (track != null && user != null) {
                      return SongComponent(
                        songName: track.name ?? 'Unknown Song',
                        songImageUrl:
                            track.album?.images?.firstOrNull?.url ?? '',
                        songAuthor: track.artists?.firstOrNull?.name ??
                            'Unknown Artist',
                      );
                    } else {
                      return const Text('Loading song...');
                    }
                  },
                ),
                const SizedBox(height: 24),
                Expanded(
                  child: BlocBuilder<GameCubit, GameState>(
                    builder: (context, state) {
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

                          return SquareUserComponent(
                            userName: user.displayName ?? '',
                            userImageUrl: user.images?.firstOrNull?.url ?? '',
                          );
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
