import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/authorization/authorization_service.dart';
import 'package:spotify_flutter/src/dependency_injection.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit() : super(ProfileLoading());

  Future<void> fetchUserProfile(BuildContext context) async {
    try {
      final spotifyApi = await getSpotifyApi(context);
      final user = await spotifyApi.me.get();
      emit(ProfileLoaded(user));
    } catch (error) {
      emit(ProfileError('Failed to fetch profile: $error'));
    }
  }

  Future<void> logout() async {
    try {
      await getIt.unregister<SpotifyApi>();

      if (getIt.isRegistered<AuthorizationService>()) {
        final authService = getIt<AuthorizationService>();
        await authService.logout();
      }

      emit(ProfileLoggedOut());
    } catch (error) {
      emit(ProfileError('Failed to logout: $error'));
    }
  }
}

@immutable
abstract class ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final User user;

  ProfileLoaded(this.user);
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError(this.message);
}

class ProfileLoggedOut extends ProfileState {}
