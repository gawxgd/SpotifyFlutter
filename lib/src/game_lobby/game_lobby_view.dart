import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_dialog.dart';
import 'package:spotify_flutter/src/components/leaving_confirmation/leaving_confirmation_popscope.dart';
import 'package:spotify_flutter/src/components/user_component.dart';
import 'package:spotify_flutter/src/game/game_view.dart';
import 'game_lobby_controller.dart';
import 'game_lobby_view_model.dart';
import 'package:vibration/vibration.dart';

class GameLobbyView extends StatelessWidget {
  static const routeName = '/gameLobby';
  static const name = 'Game Lobby';

  final GameLobbyViewModel viewModel = GameLobbyViewModel();
  late final GameLobbyController controller = GameLobbyController(viewModel);

  GameLobbyView({super.key});

  Future<bool?> _showBackDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return const LeavingConfirmationDialog();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    controller.initializeHost();
    controller.addHostPlayer();

    return ChangeNotifierProvider(
      create: (_) => viewModel,
      child: LeavingConfirmationPopscope(
        onDispose: () => controller.dispose,
        child: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<GameLobbyViewModel>(
              builder: (context, model, _) {
                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Deep Link Display
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(
                                color: Theme.of(context).primaryColor),
                            borderRadius: BorderRadius.circular(16)),
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
                                    model.deepLink,
                                    style: const TextStyle(fontSize: 16),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.copy),
                                  onPressed: controller.copyDeepLink,
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),

                            // Share Button
                            ShareButton(controller: controller),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),

                      // QR Code
                      Center(
                        child: QrImageView(
                          data: model.deepLink,
                          version: QrVersions.auto,
                          size: 200.0,
                          backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () async {
                          final canVibrate = await Vibration.hasVibrator();

                          if (canVibrate != null && canVibrate == true) {
                            Vibration.vibrate();
                          }
                          await controller.startGameAsync();
                          const gameState = true;
                          if (gameState == false) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('game failed to start')));
                            }
                          } else {
                            if (context.mounted) {
                              context.go(GameView.routeName);
                            }
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
                              color: Theme.of(context).colorScheme.onPrimary),
                        ),
                      ),
                      const SizedBox(height: 32),
                      const Text(
                        'Connected Players:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      // Replace Expanded with a Container or SizedBox to avoid layout issues
                      SizedBox(
                        height:
                            300, // Set a fixed height or let it adjust based on content
                        child: ListView.builder(
                          itemCount: model.players.length,
                          itemBuilder: (context, index) {
                            var player = model.players[index];
                            return UserComponent(
                              userName: player.displayName ?? ' ',
                              userImageUrl:
                                  player.images?.firstOrNull?.url ?? ' ',
                              onDelete: () => controller.deletePlayer(player),
                              canDelete: controller.isHostPlayer(player),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class ShareButton extends StatelessWidget {
  const ShareButton({
    super.key,
    required this.controller,
  });

  final GameLobbyController controller;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => controller.shareDeepLink(context),
      icon: const Icon(Icons.share),
      label: const Text('Share Link'),
    );
  }
}
