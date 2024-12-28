import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/home/home_view.dart';
import 'package:spotify_flutter/src/profile/profile_view.dart';
import 'package:spotify_flutter/src/settings/settings_view.dart';
import 'package:spotify_flutter/src/stats/stats_view.dart';

class MainScaffold extends StatelessWidget {
  const MainScaffold({
    super.key,
    required this.title,
    required this.body,
  });

  final String title;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.purple),
              child: Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text(HomeView.name),
              onTap: () {
                context.push(HomeView.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(SettingsView.name),
              onTap: () {
                context.pop();
                context.push(SettingsView.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(ProfileView.name),
              onTap: () {
                context.pop();
                context.push(ProfileView.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text(StatsView.name),
              onTap: () {
                context.pop();
                context.push(StatsView.routeName);
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }
}
