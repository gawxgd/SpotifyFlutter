import 'package:flutter/material.dart';
import 'package:spotify/spotify.dart';
import 'package:spotify_flutter/src/authorization/authorization_view.dart';
import 'package:spotify_flutter/src/stats/stats_view.dart';
import 'profile_controller.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  static const String routeName = '/profile';
  static const String name = 'Profile';

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final ProfileController _controller = ProfileController();

  User? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await _controller.fetchUserProfile();
      setState(() {
        userProfile = profile;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _logout() async {
    await _controller.logout();
    Navigator.pushReplacementNamed(context, AuthorizationView.routeName);
  }

  Future<void> _openSpotifyProfile() async {
    //final url = userProfile?.uri;

    // if (url != null && await canLaunchUrl(Uri.parse(url))) {
    //   await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    // } else {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('Unable to open Spotify profile URL')),
    //   );
    // }
  }

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userProfile != null
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Profile Image
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: userProfile?.images?.isNotEmpty == true
                            ? NetworkImage(userProfile!.images!.first.url!)
                            : null,
                        child: userProfile?.images?.isEmpty == true
                            ? const Icon(Icons.person, size: 60)
                            : null,
                      ),
                      const SizedBox(height: 20),
                      // Display Name
                      Text(
                        userProfile!.displayName ?? 'No Display Name',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Country & Product
                      Text(
                        '${userProfile?.country ?? 'Unknown Country'} • ${userProfile?.product ?? 'Free Plan'}',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const Divider(height: 40),
                      // User Info Section
                      _buildUserInfoRow('User ID', userProfile!.id ?? 'N/A'),
                      _buildUserInfoRow('Email', userProfile!.email ?? 'N/A'),
                      _buildUserInfoRow('Followers',
                          userProfile?.followers?.total?.toString() ?? 'N/A'),
                      _buildUserInfoRow('External URL',
                          userProfile?.uri ?? 'No URL available'),
                      const SizedBox(height: 30),
                      // Button to Open Spotify Profile
                      ElevatedButton.icon(
                        icon: const Icon(Icons.open_in_new),
                        label: const Text('Open Spotify Profile'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _openSpotifyProfile,
                      ),
                      const SizedBox(height: 20),
                      // Logout Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.bar_chart),
                        label: const Text('View your stats'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () =>
                            Navigator.pushNamed(context, StatsView.routeName),
                      ),
                      const SizedBox(height: 20),
                      // Logout Button
                      ElevatedButton.icon(
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: _logout,
                      ),
                    ],
                  ),
                )
              : const Center(
                  child: Text(
                    'Failed to load profile',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
    );
  }
}
