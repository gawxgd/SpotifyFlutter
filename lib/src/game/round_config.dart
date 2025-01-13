import 'package:spotify/spotify.dart';

class RoundConfig {
  final List<User> users;
  final Map<String, List<Track>> userIdToSongs;
  final int? roundNumber;
  Map<String, (User, int)>? userIdToPoints;
  RoundConfig(
      {required this.users,
      required this.userIdToPoints,
      required this.roundNumber,
      required this.userIdToSongs});
}
