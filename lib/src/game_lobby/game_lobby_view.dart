import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/components/user_component.dart';
import 'package:spotify_flutter/src/game_host/game_view.dart';
import 'game_lobby_cubit.dart';

class GameLobbyView extends StatelessWidget {
  static const routeName = '/gameLobby';
  static const name = 'Game Lobby';

  const GameLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => GameLobbyCubit()..initializeHost(),
      child: BlocBuilder<GameLobbyCubit, GameLobbyState>(
        builder: (context, state) {
          final cubit = context.read<GameLobbyCubit>();

          return LeavingConfirmationPopscope(
            onDispose: () => context.read<GameLobbyCubit>().dispose,
            child: state.loading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Scaffold(
                    body: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Deep Link Display
                            Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Invite Link:',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: SelectableText(
                                          state.deepLink,
                                          style: const TextStyle(fontSize: 16),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: cubit.copyDeepLink,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),

                                  // Share Button
                                  ShareButton(cubit: cubit),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // QR Code
                            Center(
                              child: QrImageView(
                                data: state.deepLink,
                                version: QrVersions.auto,
                                size: 200.0,
                                backgroundColor: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () async {
                                await cubit.startGameAsync();

                                if (context.mounted) {
                                  context.go(GameHostView.routeName);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 30, vertical: 15),
                                backgroundColor: Theme.of(context).primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                'Start Game',
                                style: TextStyle(
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onPrimary),
                              ),
                            ),
                            const SizedBox(height: 32),
                            const Text(
                              'Connected Players:',
                              style: TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 300,
                              child: ListView.builder(
                                itemCount: state.players.length,
                                itemBuilder: (context, index) {
                                  var player = state.players[index];
                                  return UserComponent(
                                    userName: player.displayName ?? ' ',
                                    userImageUrl:
                                        player.images?.firstOrNull?.url ?? ' ',
                                    onDelete: () => cubit.deletePlayer(player),
                                    canDelete: cubit.isHostPlayer(player),
                                    isHost: cubit.isHostPlayer(player),
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
        },
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.cubit,
  });

  final GameLobbyCubit cubit;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => cubit.shareDeepLink(context),
      icon: const Icon(Icons.share),
      label: const Text('Share Link'),
    );
  }
}
