import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/join_game/join_game_cubit.dart';

class JoinGameView extends StatelessWidget {
  static const routeName = '/joingame';
  static const name = 'Join Game';
  final String? roomId;

  const JoinGameView({super.key, this.roomId});

  @override
  Widget build(BuildContext context) {
    final TextEditingController roomIdController = TextEditingController();
    if (roomId != null) {
      roomIdController.text = roomId!;
    }

    return BlocProvider(
      create: (_) => JoinGameCubit(),
      child: BlocBuilder<JoinGameCubit, JoinGameState>(
        builder: (context, state) {
          final cubit = context.read<JoinGameCubit>();
          return LeavingConfirmationPopscope(
            onDispose: cubit.leaveGame,
            child: Scaffold(
              body: Center(
                child: state.isHostStarted
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'The host has started the game!',
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navigate to game screen
                              // Navigator.pushNamed(context, '/game');
                            },
                            child: const Text('Start Playing'),
                          ),
                        ],
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!state.isConnected && !state.isConnectionFailed)
                            Column(
                              children: [
                                const Text(
                                  'Enter Room ID:',
                                  style: TextStyle(fontSize: 16),
                                ),
                                TextField(
                                  controller: roomIdController,
                                  decoration: const InputDecoration(
                                    hintText: 'Room ID',
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    final roomId = roomIdController.text;
                                    if (roomId.isNotEmpty) {
                                      cubit.connectToGame(roomId);
                                    }
                                  },
                                  child: const Text('Join Game'),
                                ),
                              ],
                            ),
                          if (state.isConnected)
                            const Text(
                              'Waiting for the host to start...',
                              style: TextStyle(fontSize: 20),
                            ),
                          if (state.isConnectionFailed)
                            const Text(
                              'Connection with host failed',
                              style: TextStyle(fontSize: 20),
                            ),
                          const SizedBox(height: 20),
                          if (!state.isConnected && !state.isConnectionFailed)
                            const CircularProgressIndicator(),
                        ],
                      ),
              ),
            ),
          );
        },
      ),
    );
  }
}
