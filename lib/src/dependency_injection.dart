import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/authorization/authorization_service.dart';
import 'package:spotify_flutter/src/webRtc/hostpeer.dart';
import 'package:spotify_flutter/src/webRtc/joinpeer.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  setupAuthorizationService();
  setupHostPeerSignaling();
  setupJoiningPeerSignaling();
}

void setupAuthorizationService() {
  String apiKey = dotenv.env['API_KEY'] ?? '';
  getIt.registerSingleton<AuthorizationService>(
    AuthorizationService(
      clientId: '9d6791260d0d417dacb912ea8331417e',
      clientSecret: apiKey,
      redirectUri: 'groove.check.app://callback',
      customUriScheme: 'groove.check.app',
      scopes: [
        'user-read-private',
        'user-read-playback-state',
        'user-modify-playback-state',
        'user-read-currently-playing',
        'user-read-email',
        'user-top-read',
      ],
    ),
  );
}

void setupSpotifyApi() {
  getIt.registerLazySingleton<SpotifyApi>(() {
    throw Exception('SpotifyApi not yet authorized. Call authorizeUser first.');
  });
}

void setupHostPeerSignaling() {
  getIt.registerLazySingleton<HostPeerSignaling>(() => HostPeerSignaling());
}

void setupJoiningPeerSignaling() {
  getIt.registerLazySingleton<JoiningPeerSignaling>(
      () => JoiningPeerSignaling());
}

void updateSpotifyApi(SpotifyApi spotifyApi) {
  if (getIt.isRegistered<SpotifyApi>()) {
    getIt.unregister<SpotifyApi>();
  }
  getIt.registerSingleton<SpotifyApi>(spotifyApi);
}

T? getService<T extends Object>() {
  if (getIt.isRegistered<T>()) {
    return getIt<T>();
  }
  return null;
}

Future<SpotifyApi> getSpotifyApi(BuildContext context) async {
  var spotifyApi = getService<SpotifyApi>();

  if (spotifyApi == null) {
    final authService = getService<AuthorizationService>();
    if (authService != null) {
      await authService.authorizeUser(context);

      spotifyApi = getService<SpotifyApi>();
      if (spotifyApi != null) {
        return spotifyApi;
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please log in to continue.')),
        );
      }
    }
  }
  return spotifyApi!;
}
