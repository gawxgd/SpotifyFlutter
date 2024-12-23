class JoinGameModel {
  Future<void> connectToWebRTC() async {
    // Logic to initialize WebRTC connection
    await Future.delayed(const Duration(seconds: 2)); // Simulated delay
    print('Connected to WebRTC!');
  }

  Stream<bool> waitForHostToStart() async* {
    // Simulate waiting for the host
    await Future.delayed(const Duration(seconds: 5));
    yield true; // Replace with actual server-side logic
  }
}
