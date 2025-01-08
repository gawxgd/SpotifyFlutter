import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_flutter/src/components/song_component.dart';
import 'package:spotify_flutter/src/components/square_user_component.dart';
import 'game_cubit.dart';

class GameView extends StatelessWidget {
  static const routeName = '/game';
  static const name = 'game';

  const GameView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameCubit()..loadUsers(),
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(
                height: 64,
              ),
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
              const SongComponent(
                songName: 'testSong',
                songImageUrl: '',
                songAuthor: 'testAuthor',
              ),
              const SizedBox(height: 24),
              Expanded(
                child: BlocBuilder<GameCubit, GameState>(
                  builder: (context, state) {
                    return GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2, // 2 items per row
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: 1, // Square items
                      ),
                      itemCount: state.users.length,
                      itemBuilder: (context, index) {
                        final user = state.users[index];
                        return SquareUserComponent(
                          userName: user['userName']!,
                          userImageUrl: user['userImageUrl']!,
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
    );
  }
}
