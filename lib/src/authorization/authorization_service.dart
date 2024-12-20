import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/helpers/error_dialog';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:oauth2_client/oauth2_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:oauth2_client/oauth2_helper.dart';
import 'package:http/http.dart' as http;

class AuthorizationService {
  AuthorizationService({
    required this.clientId,
    required this.clientSecret,
    required this.redirectUri,
    required this.customUriScheme,
  });

  final String clientId;
  final String clientSecret;

  final String redirectUri;
  final String customUriScheme;

  Future<void> authorizeUser(BuildContext context) async {
    SpotifyOAuth2Client client = SpotifyOAuth2Client(
      customUriScheme: customUriScheme,
      redirectUri: redirectUri,
    );

    try {
      OAuth2Helper oauth2Helper = OAuth2Helper(client,
          grantType: OAuth2Helper.authorizationCode,
          clientId: clientId,
          clientSecret: clientSecret,
          scopes: [
            'user-read-private',
            'user-read-playback-state',
            'user-modify-playback-state',
            'user-read-currently-playing',
            'user-read-email'
          ]);
      final tokenResponse = await oauth2Helper.getToken();

      if (tokenResponse != null) {
        final accessToken = tokenResponse.accessToken!;

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(accessToken.toString())));

        final spotify = SpotifyApi.withAccessToken(accessToken.toString());

        http.Response resp =
            await oauth2Helper.get('https://api.spotify.com/v1/me');

        if (resp.statusCode == 200) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(resp.body.toString())));
        } else {
          debugPrint(resp.statusCode.toString() + resp.body);
        }

        final user = await spotify.me.get();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(user.toString())));
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

  Future<void> saveAccessToken({
    required String accessToken,
    String? refreshToken,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token', accessToken);
    if (refreshToken != null) {
      await prefs.setString('refresh_token', refreshToken);
    }
  }
}
