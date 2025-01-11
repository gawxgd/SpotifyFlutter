import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify_flutter/src/prepare_game/prepare_game_cubit.dart';

class PrepareGameView extends StatelessWidget {
  static const routeName = '/prepareGame';
  static const name = 'Prepare Game';

  const PrepareGameView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PrepareGameCubit(),
      child: BlocBuilder<PrepareGameCubit, PrepareGameState>(
        builder: (context, state) {
          final cubit = context.read<PrepareGameCubit>();

          return Scaffold(
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
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
                      onChanged: cubit.updateRounds,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Number of Rounds',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Game Mode Dropdown
                    DropdownButtonFormField<String>(
                      value: state.gameMode,
                      items: ['Standard', 'Challenge', 'Custom'].map((mode) {
                        return DropdownMenuItem(value: mode, child: Text(mode));
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          cubit.updateGameMode(value);
                        }
                      },
                      decoration: const InputDecoration(
                        labelText: 'Game Mode',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field with Show/Hide Option
                    TextField(
                      onChanged: cubit.updatePassword,
                      obscureText: !state.isPasswordVisible,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(
                            state.isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: cubit.togglePasswordVisibility,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Question Time Slider
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question Time: ${state.questionTime} seconds',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        Slider(
                          value: state.questionTime.toDouble(),
                          min: 10,
                          max: 120,
                          divisions: 11,
                          label: '${state.questionTime} seconds',
                          onChanged: (value) =>
                              cubit.updateQuestionTime(value.toInt()),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Start Game Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () => cubit.startGame(context),
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
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
