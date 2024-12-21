import 'package:spotify_flutter/src/authorization/authorization_service.dart';
import 'package:flutter/material.dart';

class AuthorizationController {
  const AuthorizationController({required this.service});

  final AuthorizationService service;

  Future<void> startAuthorization(BuildContext context) async {
    await service.authorizeUser(context);
  }
}
