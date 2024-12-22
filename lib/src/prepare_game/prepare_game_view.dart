import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spotify_flutter/src/prepare_game/prepare_game_controller.dart';
import 'package:spotify_flutter/src/prepare_game/prepare_game_view_model.dart';

class PrepareGameView extends StatelessWidget {
  static const routeName = '/prepareGame';
  static const name = 'Prepare Game';

  PrepareGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PrepareGameViewModel(), // Providing the ViewModel here
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Consumer<PrepareGameViewModel>(
              builder: (context, model, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title with Logo
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.factory,
                            size: 80,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Prepare Your Game',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Number of Rounds
                    TextField(
                      onChanged: (value) => model.rounds = value,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of Rounds',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Game Mode Dropdown
                    DropdownButtonFormField<String>(
                      value: model.gameMode,
                      items: ['Standard', 'Challenge', 'Custom'].map((mode) {
                        return DropdownMenuItem(value: mode, child: Text(mode));
                      }).toList(),
                      onChanged: (value) => model.gameMode = value!,
                      decoration: const InputDecoration(
                        labelText: 'Game Mode',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field with Show/Hide Option
                    TextField(
                      onChanged: (value) => model.password = value,
                      obscureText: !model.isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            model.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            model.isPasswordVisible = !model.isPasswordVisible;
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Start Game Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Pass the controller method here
                          final controller = PrepareGameController(model);
                          controller.startGame(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Start Game',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.onPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
