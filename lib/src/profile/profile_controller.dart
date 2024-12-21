import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/authorization/authorization_service.dart';

class ProfileController {
  final getIt = GetIt.instance;

  Future<User?> fetchUserProfile() async {
    try {
      final user = await getIt<SpotifyApi>().me.get();
      return user;
    } catch (error) {
      throw Exception('Failed to fetch profile: $error');
    }
  }

  Future<void> logout() async {
    await getIt.unregister<SpotifyApi>();

    if (getIt.isRegistered<AuthorizationService>()) {
      final authService = getIt<AuthorizationService>();
      await authService.logout();
    }
  }
}
