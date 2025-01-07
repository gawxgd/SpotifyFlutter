import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

typedef OnMessageCallback = void Function(Map<String, dynamic> message);

class Signaling {
  Map<String, dynamic> configuration = {
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCPeerConnection? peerConnection;
  RTCDataChannel? dataChannel;
  String? roomId;
  String? currentRoomText;
  OnMessageCallback? onMessageReceived;

  /// Create a new WebRTC Room
  Future<String> createRoom() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc();

    debugPrint('Creating PeerConnection with configuration: $configuration');

    peerConnection = await createPeerConnection(configuration);
    registerPeerConnectionListeners();

    // Create Data Channel
    dataChannel =
        await peerConnection!.createDataChannel('data', RTCDataChannelInit());
    setupDataChannel();

    // Handle ICE Candidates
    var callerCandidatesCollection = roomRef.collection('callerCandidates');
    peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
      if (candidate == null) {
        debugPrint('onIceCandidate: complete!');
        return;
      }
      debugPrint('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };

    // Create and set the offer
    RTCSessionDescription offer = await peerConnection!.createOffer();
    await peerConnection!.setLocalDescription(offer);

    debugPrint('Created offer: $offer');

    await roomRef.set({'offer': offer.toMap()});

    roomId = roomRef.id;
    debugPrint('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';

    // Listen for remote session description
    roomRef.snapshots().listen((snapshot) async {
      if (!snapshot.exists) return;
      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (peerConnection?.getRemoteDescription() == null &&
          data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );
        await peerConnection?.setRemoteDescription(answer);
      }
    });

    // Listen for remote ICE candidates
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          var data = change.doc.data() as Map<String, dynamic>;
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      }
    });

    return roomId!;
  }

  /// Join an existing WebRTC Room
  Future<void> joinRoom(String roomId) async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();

    if (roomSnapshot.exists) {
      debugPrint('Joining room with configuration: $configuration');

      peerConnection = await createPeerConnection(configuration);
      registerPeerConnectionListeners();

      // Handle DataChannel
      peerConnection?.onDataChannel = (RTCDataChannel channel) {
        dataChannel = channel;
        setupDataChannel();
        debugPrint('Data channel established on join.');
      };

      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection?.onIceCandidate = (RTCIceCandidate? candidate) {
        if (candidate == null) {
          debugPrint('onIceCandidate: complete!');
          return;
        }
        debugPrint('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };

      var data = roomSnapshot.data() as Map<String, dynamic>;
      var offer = data['offer'];
      await peerConnection!.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );

      var answer = await peerConnection!.createAnswer();
      await peerConnection!.setLocalDescription(answer);

      await roomRef.update({'answer': answer.toMap()});
    }
  }

  /// Setup Data Channel for Messaging
  void setupDataChannel() {
    if (dataChannel == null) {
      debugPrint('setupDataChannel: Data channel is null!');
      return;
    }

    debugPrint('Setting up data channel listeners.');

    dataChannel?.onMessage = (RTCDataChannelMessage message) {
      if (message.isBinary) {
        debugPrint('Received binary message');
      } else {
        final decodedMessage = jsonDecode(message.text);
        onMessageReceived?.call(decodedMessage);
        debugPrint('Received message: ${message.text}');
      }
    };

    dataChannel?.onDataChannelState = (RTCDataChannelState state) {
      debugPrint('Data channel state: $state');
      if (state == RTCDataChannelState.RTCDataChannelOpen) {
        debugPrint('Data channel is open and ready for communication.');
      }
    };
  }

  /// Send a Message via Data Channel
  Future<void> sendMessage(Map<String, dynamic> message) async {
    if (dataChannel != null &&
        dataChannel!.state == RTCDataChannelState.RTCDataChannelOpen) {
      dataChannel!.send(RTCDataChannelMessage(jsonEncode(message)));
      debugPrint('Sent message: $message');
    } else {
      debugPrint('Data channel is not open or available');
    }
  }

  /// Peer Connection Listeners
  void registerPeerConnectionListeners() {
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      debugPrint('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      debugPrint('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      debugPrint('ICE gathering state changed: $state');
    };

    peerConnection?.onIceConnectionState = (RTCIceConnectionState state) {
      debugPrint('ICE connection state change: $state');
    };
  }
}
