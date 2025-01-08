import 'package:flutter/material.dart';
import 'join_game_controller.dart';

class JoinGameView extends StatefulWidget {
  static const routeName = '/joingame';
  static const name = 'Join Game';
  final String? roomId;

  const JoinGameView({super.key, this.roomId});

  @override
  JoinGameViewState createState() => JoinGameViewState();
}

class JoinGameViewState extends State<JoinGameView> {
  late final JoinGameController _controller;
  bool _isConnected = false;
  bool _isHostStarted = false;
  final TextEditingController _roomIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.roomId != null) {
      _roomIdController.text = widget.roomId!;
    }

    _controller = JoinGameController(
      onConnectionChanged: (isConnected) {
        setState(() {
          _isConnected = isConnected;
        });
      },
      onHostStarted: (isHostStarted) {
        setState(() {
          _isHostStarted = isHostStarted;
        });
      },
    );
  }

  void getRouteArgs() {
    final routeArguments = ModalRoute.of(context)?.settings.arguments;
    if (routeArguments is String) {
      _roomIdController.text = routeArguments;
    }
  }

  @override
  Widget build(BuildContext context) {
    getRouteArgs();
    return Scaffold(
      body: Center(
        child: _isHostStarted
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'The host has started the game!',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      //Navigator.pushNamed(context, '/game');
                    },
                    child: const Text('Start Playing'),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (!_isConnected)
                    Column(
                      children: [
                        const Text(
                          'Enter Room ID:',
                          style: TextStyle(fontSize: 16),
                        ),
                        TextField(
                          controller: _roomIdController,
                          decoration: const InputDecoration(
                            hintText: 'Room ID',
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            final roomId = _roomIdController.text;
                            if (roomId.isNotEmpty) {
                              _controller.connectToGame(roomId);
                              //_controller.waitForHostToStart();
                            }
                          },
                          child: const Text('Join Game'),
                        ),
                      ],
                    ),
                  if (_isConnected)
                    const Text(
                      'Waiting for the host to start...',
                      style: TextStyle(fontSize: 20),
                    ),
                  const SizedBox(height: 20),
                  if (!_isConnected) const CircularProgressIndicator(),
                ],
              ),
      ),
    );
  }
}
