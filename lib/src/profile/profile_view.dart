import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/authorization/authorization_view.dart';
import 'package:spotify_flutter/src/stats/stats_view.dart';
import 'profile_cubit.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  static const String routeName = '/profile';
  static const String name = 'Profile';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ProfileCubit()..fetchUserProfile(context),
      child: const ProfileViewContent(),
    );
  }
}

class ProfileViewContent extends StatelessWidget {
  const ProfileViewContent({super.key});

  Widget _buildUserInfoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$title:',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is ProfileLoggedOut) {
            context.push(AuthorizationView.routeName);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoaded) {
            final userProfile = state.user;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: userProfile.images?.isNotEmpty == true
                        ? NetworkImage(userProfile.images!.first.url!)
                        : null,
                    child: userProfile.images?.isEmpty == true
                        ? const Icon(Icons.person, size: 60)
                        : null,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    userProfile.displayName ?? 'No Display Name',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${userProfile.country ?? 'Unknown Country'} • ${userProfile.product ?? 'Free Plan'}',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const Divider(height: 40),
                  _buildUserInfoRow('User ID', userProfile.id ?? 'N/A'),
                  _buildUserInfoRow('Email', userProfile.email ?? 'N/A'),
                  _buildUserInfoRow('Followers',
                      userProfile.followers?.total?.toString() ?? 'N/A'),
                  _buildUserInfoRow(
                      'External URL', userProfile.uri ?? 'No URL available'),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    icon: Icon(Icons.open_in_new,
                        color: Theme.of(context).colorScheme.onPrimary),
                    label: const Text('Open Spotify Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      // Implement URL launch logic here
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.bar_chart,
                        color: Theme.of(context).colorScheme.onPrimary),
                    label: const Text('View your stats'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => context.push(StatsView.routeName),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.logout,
                        color: Theme.of(context).colorScheme.onPrimary),
                    label: const Text('Logout'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => context.read<ProfileCubit>().logout(),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Text(
              'Failed to load profile',
              style: TextStyle(fontSize: 16),
            ),
          );
        },
      ),
    );
  }
}
