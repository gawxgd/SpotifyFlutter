import 'package:flutter/material.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:spotify/spotify.dart';
import 'dart:async';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';

class AuthorizationService {
  AuthorizationService({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    required this.customUriScheme,
    required this.scopes,
  });

  final String clientId;
  final String clientSecret;

  final String redirectUri;
  final String customUriScheme;

  final List<String> scopes;

  late OAuth2Helper oAuth2Helper;

  Future<void> logout() async {
    await oAuth2Helper.removeAllTokens();
  }

  Future<bool> isAuthorized() async {
    try {
      final token = await oAuth2Helper.getTokenFromStorage();
      return token != null && !token.isExpired();
    } catch (e) {
      return false;
    }
  }

  Future<void> authorizeUser(BuildContext context) async {
    SpotifyOAuth2Client client = SpotifyOAuth2Client(
      customUriScheme: customUriScheme,
      redirectUri: redirectUri,
    );

    try {
      oAuth2Helper = OAuth2Helper(client,
          grantType: OAuth2Helper.authorizationCode,
          clientId: clientId,
          clientSecret: clientSecret,
          scopes: scopes);

      final tokenResponse = await oAuth2Helper.getToken();

      if (tokenResponse != null) {
        final accessToken = tokenResponse.accessToken!;

        final spotify = SpotifyApi.withAccessToken(accessToken.toString());

        updateSpotifyApi(spotify);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Authorization successful!')));
        }
      }
    } catch (error) {
      debugPrint('Authorization error: $error');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Authorization failed: $error')),
        );
      }
    }
  }
}
