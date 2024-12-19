import 'package:flutter/material.dart';
import 'package:oauth2_client/access_token_response.dart';
import 'package:oauth2_client/spotify_oauth2_client.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/helpers/error_dialog';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:oauth2_client/oauth2_client.dart';

class AuthorizationService {
  AuthorizationService({required this.clientId, required this.clientSecret});
  //final SpotifyApiCredentials _credentials;

  final String clientId;
  final String clientSecret;

  //final String _redirectUri = 'myapp://auth';

  Future<void> authorizeUser(BuildContext context) async {
    AccessTokenResponse? accessToken;
    SpotifyOAuth2Client client = SpotifyOAuth2Client(
      customUriScheme: 'groove.check.app',
      redirectUri: 'groove.check.app://callback',
    );

    var authResp =
        await client.requestAuthorization(clientId: clientId, customParams: {
      'show_dialog': 'true'
    }, scopes: [
      AuthorizationScope.user.readEmail,
      AuthorizationScope.library.read,
    ]);

    var authCode = authResp.code;

    accessToken = await client.requestAccessToken(
        code: authCode.toString(),
        clientId: clientId,
        clientSecret: clientSecret);

    // Global variables
    final Access_Token = accessToken.accessToken;
    final Refresh_Token = accessToken.refreshToken;
  }

  Future<void> _openAuthorizationUrl(Uri authUri, BuildContext context) async {
    if (await canLaunchUrl(authUri)) {
      await launchUrl(authUri);
    } else {
      showErrorDialog(context, 'cannot open url');
    }
  }

/*
  Future<Uri?> _listenForRedirectUri() async {
     Completer<Uri?> completer = Completer();

  // Use a method channel or listen to URL changes to capture the redirect URI
  // This can be done via a stream, URL scheme handler, or deep linking approach
  StreamSubscription<Uri> subscription;

  // Listen for events that match the redirect URI scheme
  subscription = uriStreamController.stream.listen((uri) {
    if (uri != null && uri.scheme == 'myapp') { // Replace 'myapp' with your custom scheme
      subscription.cancel(); // Stop listening
      completer.complete(uri); // Complete the future with the captured URI
    }
  });

  // Return the result of the listener as a Future
  return completer.future;
  }
  */
}
