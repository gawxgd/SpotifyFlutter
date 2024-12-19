import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/helpers/error_dialog';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';

class AuthorizationService {
  final SpotifyApiCredentials _credentials;
  final String _redirectUri = 'myapp://auth';

  AuthorizationService({required String clientId, required String clientSecret})
      : _credentials = SpotifyApiCredentials(clientId, clientSecret);

  Future<void> authorizeUser(BuildContext context) async {
    final grant = SpotifyApi.authorizationCodeGrant(_credentials);

    final scopes = [
      AuthorizationScope.user.readEmail,
      AuthorizationScope.library.read,
    ];

    // Generate the authorization URL
    final authUri = grant.getAuthorizationUrl(
      Uri.parse(_redirectUri),
      scopes: scopes,
    );

    // Redirect to the Spotify authorization page
    // Use a method to open the URL in a browser or web view
    await _openAuthorizationUrl(authUri, context);

    // After redirect, capture the response URI and handle the callback
    /*
    final responseUri = await _listenForRedirectUri();

    if (responseUri != null) {
      final spotify =
          SpotifyApi.fromAuthCodeGrant(grant, responseUri.toString());
      // Now you can use the `spotify` instance to fetch user data
      // For example:
      // final user = await spotify.me();
      // Use user data as needed
    }
    */
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
