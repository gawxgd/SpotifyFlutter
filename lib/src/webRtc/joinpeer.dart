import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:spotify_flutter/src/webRtc/peersignalingbase.dart';

class JoiningPeerSignaling extends PeerSignalingBase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? remotePeerId;

  /// Join a room using the room ID
  Future<void> joinRoom(String roomId, {required VoidCallback onOpen}) async {
    await initializePeer(); // Ensure peer is initialized and opened

    DocumentSnapshot snapshot = await _db.collection('rooms').doc(roomId).get();

    if (!snapshot.exists) {
      debugPrint('Room does not exist');
      return;
    }

    final data = snapshot.data() as Map<String, dynamic>;
    remotePeerId = data['hostPeerId'];

    debugPrint('Connecting to remote peer: $remotePeerId');

    if (remotePeerId != null) {
      final connection = peer.connect(remotePeerId!);
      dataConnections.add(connection);
      setupDataConnection(connection, onOpen: onOpen);
    } else {
      debugPrint('Remote Peer ID is null.');
    }
  }
}
