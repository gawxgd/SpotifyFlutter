import 'package:spotify_flutter/src/authorization/authorization_service.dart';
import 'package:flutter/material.dart';

class AuthorizationController {
  const AuthorizationController({required this.service});

  final AuthorizationService service;

  void startAuthorization(BuildContext context) {
    service.authorizeUser(context);
  }
}
