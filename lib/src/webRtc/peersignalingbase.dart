import 'dart:async';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';

typedef OnMessageCallback = void Function(
    String message, DataConnection connection);

abstract class PeerSignalingBase {
  late Peer peer;
  String? localPeerId;
  List<DataConnection> dataConnections = [];
  OnMessageCallback? onMessageReceived;

  Future<void> initializePeer({OnMessageCallback? onMessage}) async {
    onMessageReceived = onMessage;
    peer = Peer();

    Completer<void> peerOpenCompleter = Completer<void>();

    peer.on('open').listen((id) {
      localPeerId = id;
      debugPrint('Local Peer ID: $localPeerId');
      peerOpenCompleter.complete();
    });

    peer.on('error').listen((error) {
      debugPrint('Peer error: $error');
    });

    await peerOpenCompleter.future;
  }

  void setupDataConnection(DataConnection connection,
      {required VoidCallback onOpen}) {
    connection.on('data').listen((data) {
      onMessageReceived?.call(data.toString(), connection);
      debugPrint('Received message: $data');
    });

    connection.on('open').listen((_) {
      debugPrint('Data connection with ${connection.peer} is open');
      onOpen();
    });

    connection.on('close').listen((_) {
      debugPrint('Data connection closed with ${connection.peer}');
      dataConnections.remove(connection);
    });

    connection.on('error').listen((error) {
      debugPrint('Data connection error: $error');
    });
  }

  void sendMessage(String message) {
    for (var connection in dataConnections) {
      if (connection.open) {
        connection.send(message);
        debugPrint('Sent message to ${connection.peer}: $message');
      } else {
        debugPrint('Connection to ${connection.peer} is not open.');
      }
    }
  }

  Future<bool> sendMessageAsync(String message) async {
    if (dataConnections.isEmpty) {
      debugPrint("data connection is empty");
      return false;
    }
    for (var connection in dataConnections) {
      if (connection.open) {
        await connection.send(message);
        debugPrint('Sent message to ${connection.peer}: $message');
      } else {
        debugPrint('Connection to ${connection.peer} is not open.');
      }
    }
    return true;
  }

  void close() {
    if (dataConnections.isNotEmpty) {
      for (var connection in dataConnections) {
        connection.close();
      }
      dataConnections.clear();
    }
    try {
      if (peer.open) {
        peer.dispose();
        peer.close();
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    debugPrint('Peer connection closed');
  }
}
