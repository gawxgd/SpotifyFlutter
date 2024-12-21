import 'package:get_it/get_it.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/authorization/authorization_service.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  setupAuthorizationService();
  setupSpotifyApi();
}

void setupAuthorizationService() {
  getIt.registerSingleton<AuthorizationService>(
    AuthorizationService(
      clientId: '9d6791260d0d417dacb912ea8331417e',
      clientSecret: '32693cd69bca421298c863fdb5a94c62',
      redirectUri: 'groove.check.app://callback',
      customUriScheme: 'groove.check.app',
      scopes: [
        'user-read-private',
        'user-read-playback-state',
        'user-modify-playback-state',
        'user-read-currently-playing',
        'user-read-email'
      ],
    ),
  );
}

void setupSpotifyApi() {
  getIt.registerLazySingleton<SpotifyApi>(() {
    throw Exception('SpotifyApi not yet authorized. Call authorizeUser first.');
  });
}

void updateSpotifyApi(SpotifyApi spotifyApi) {
  if (getIt.isRegistered<SpotifyApi>()) {
    getIt.unregister<SpotifyApi>();
  }
  getIt.registerSingleton<SpotifyApi>(spotifyApi);
}
