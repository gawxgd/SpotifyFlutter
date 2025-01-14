import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:peerdart/peerdart.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/webRtc/peersignalingbase.dart';

class HostPeerSignaling extends PeerSignalingBase {
  Map<String, (User, DataConnection)> userToDataConnectionMap =
      <String, (User, DataConnection)>{};
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  String? _roomId;

  /// Create a new room and save the Peer ID to Firestore
  Future<String> createRoom(Function(User) onClosed) async {
    await initializePeer(); // Ensure peer is initialized and opened
    if (localPeerId == null) {
      throw Exception('Peer ID is not initialized.');
    }

    DocumentReference roomRef = _db.collection('rooms').doc();
    await roomRef.set({
      'hostPeerId': localPeerId,
    });

    debugPrint('Room created with Peer ID: $localPeerId');

    peer.on('connection').listen((conn) {
      debugPrint('Incoming connection from: ${conn.peer}');
      dataConnections.add(conn);

      setupDataConnection(
        conn,
        onOpen: () {
          debugPrint('Data connection with ${conn.peer} is open');
        },
        onClosed: onClosed,
      );
    });

    _roomId = roomRef.id;
    return roomRef.id;
  }

  @override
  void setupDataConnection(
    DataConnection connection, {
    required VoidCallback onOpen,
    Function(User)? onClosed,
  }) {
    connection.on('data').listen((data) {
      onMessageReceived?.call(data.toString(), connection);
      debugPrint('Received message: $data');
    });

    connection.on('open').listen((_) {
      debugPrint('Data connection with ${connection.peer} is open');
      onOpen();
    });

    connection.on('close').listen((_) {
      final user = findUserFromDataConnection(connection);
      if (user != null) {
        if (onClosed != null) {
          onClosed(user);
        }
      }
    });

    connection.on('error').listen((error) {
      debugPrint('Data connection error: $error');
    });
  }

  void addUserToDataConnectionMapping(User user, DataConnection connection) {
    if (user.id != null) {
      userToDataConnectionMap.putIfAbsent(user.id!, () => (user, connection));
    }
  }

  User? findUserFromDataConnection(DataConnection connection) {
    if (userToDataConnectionMap.isNotEmpty) {
      for (var item in userToDataConnectionMap.values) {
        if (item.$2.peer == connection.peer) {
          return item.$1;
        }
      }
    }
    return null;
  }

  void closeConnectionWithPeer(DataConnection connection, User player) {
    debugPrint(
        'closing connection with ${player.id} and connection ${connection.peer} ');
    connection.close();
    connection.dispose();
    userToDataConnectionMap.remove(player.id);
    dataConnections.retainWhere((conn) {
      if (conn.peer == connection.peer) {
        conn.close();
        conn.dispose();
        return false;
      }
      return true;
    });
  }

  void removeDisconnectedConnection(DataConnection connection, User player) {
    userToDataConnectionMap.remove(player.id);
    dataConnections.retainWhere((conn) {
      if (conn.peer == connection.peer) {
        return false;
      }
      return true;
    });
  }

  List<User> getUserList() {
    List<User> userList = [];
    if (userToDataConnectionMap.isNotEmpty) {
      for (var item in userToDataConnectionMap.values) {
        userList.add(item.$1);
      }
    }
    return userList;
  }

  Future<void> sendMessageToUser(String userId, String message) async {
    if (userToDataConnectionMap.containsKey(userId)) {
      final userDataChannel = userToDataConnectionMap[userId]?.$2;
      if (userDataChannel != null && userDataChannel.open) {
        await userDataChannel.send(message);
        debugPrint("sent $message");
      }
    }
  }

  @override
  void close() {
    for (var item in userToDataConnectionMap.values) {
      if (item.$2.open) {
        item.$2.close();
      }
    }
    userToDataConnectionMap.clear();
    super.close();

    if (_roomId != null) {
      _db.collection('rooms').doc(_roomId).delete().then((_) {
        debugPrint('Room $_roomId deleted from Firestore.');
      }).catchError((error) {
        debugPrint('Failed to delete room $_roomId: $error');
      });
    }
  }
}
