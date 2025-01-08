import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:spotify_flutter/src/components/user_component.dart';
import 'game_lobby_controller.dart';
import 'game_lobby_view_model.dart';

class GameLobbyView extends StatelessWidget {
  static const routeName = '/gameLobby';
  static const name = 'Game Lobby';

  final GameLobbyViewModel viewModel = GameLobbyViewModel();
  late final GameLobbyController controller = GameLobbyController(viewModel);

  GameLobbyView({super.key});

  @override
  Widget build(BuildContext context) {
    controller.initializeHost();
    controller.addHostPlayer();

    return ChangeNotifierProvider(
      create: (_) => viewModel,
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
                          border:
                              Border.all(color: Theme.of(context).primaryColor),
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
                    const SizedBox(height: 32),

                    // Player List
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
                            userName: player.displayName ??
                                ' ', 
                            userImageUrl: player.images?.firstOrNull?.url ??
                                ' ', 
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
