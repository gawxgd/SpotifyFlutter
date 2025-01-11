import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:spotify_flutter/src/webRtc/peersignalingbase.dart';

class JoiningPeerSignaling extends PeerSignalingBase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? remotePeerId;

  /// Join a room using the room ID
  Future<void> joinRoom(String roomId,
      {required VoidCallback onOpen,
      required VoidCallback onError,
      required VoidCallback onClosed}) async {
    await initializePeer(); // Ensure peer is initialized and opened

    DocumentSnapshot snapshot = await _db.collection('rooms').doc(roomId).get();

    if (!snapshot.exists) {
      debugPrint('Room does not exist');
      onError();
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    remotePeerId = data['hostPeerId'];

    debugPrint('Connecting to remote peer: $remotePeerId');

    if (remotePeerId != null) {
      final connection = peer.connect(remotePeerId!);
      dataConnections.add(connection);
      setupDataConnection(connection, onOpen: onOpen, onError: onError);
    } else {
      onError();
      debugPrint('Remote Peer ID is null.');
    }
  }

  @override
  void setupDataConnection(DataConnection connection,
      {required VoidCallback onOpen,
      VoidCallback? onError,
      VoidCallback? onClosed}) {
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
      if (onClosed != null) {
        onClosed();
      }
    });

    connection.on('error').listen((error) {
      debugPrint('Data connection error: $error');
      if (onError != null) {
        onError();
      }
    });
  }
}
