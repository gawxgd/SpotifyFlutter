import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:spotify_flutter/src/authorization/authorization_controller.dart';
import 'package:spotify_flutter/src/authorization/authorization_view.dart';
import 'package:spotify_flutter/src/home/home_view.dart';
import 'package:spotify_flutter/src/profile/profile_view.dart';
import 'package:spotify_flutter/src/stats/stats_view.dart';

import 'sample_feature/sample_item_details_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.settingsController,
    required this.authorizationController,
  });

  final SettingsController settingsController;
  final AuthorizationController authorizationController;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  late AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  @override
  void initState() {
    super.initState();
    initDeepLinks();
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  Future<void> initDeepLinks() async {
    _appLinks = AppLinks();
    _linkSubscription = _appLinks.uriLinkStream.listen((uri) {
      debugPrint('onAppLink: $uri');
      openAppLink(uri);
    });
  }

  void openAppLink(Uri uri) {
    _navigatorKey.currentState?.pushNamed(uri.fragment);
  }

  void _onAuthorizationSuccess() {
    _navigatorKey.currentState?.pushReplacementNamed(HomeView.routeName);
  }

  Widget _buildScaffold(String title, Widget body, BuildContext context) {
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
                Navigator.of(context).pushReplacementNamed(HomeView.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text(SettingsView.name),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(SettingsView.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(ProfileView.name),
              onTap: () {
                Navigator.of(context)
                    .pushReplacementNamed(ProfileView.routeName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text(StatsView.name),
              onTap: () {
                Navigator.of(context).pushReplacementNamed(StatsView.routeName);
              },
            ),
          ],
        ),
      ),
      body: body,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          navigatorKey: _navigatorKey,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: widget.settingsController.themeMode,
          onGenerateRoute: (RouteSettings routeSettings) {
            return MaterialPageRoute<void>(
              settings: routeSettings,
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case SettingsView.routeName:
                    return _buildScaffold(
                      SettingsView.name,
                      SettingsView(controller: widget.settingsController),
                      context,
                    );
                  case SampleItemDetailsView.routeName:
                    return _buildScaffold(
                      'Item Details',
                      const SampleItemDetailsView(),
                      context,
                    );
                  case AuthorizationView.routeName:
                    return AuthorizationView(
                      controller: widget.authorizationController,
                      onSuccess: _onAuthorizationSuccess,
                    );
                  case ProfileView.routeName:
                    return _buildScaffold(
                      ProfileView.name,
                      const ProfileView(),
                      context,
                    );
                  case StatsView.routeName:
                    return _buildScaffold(
                      StatsView.name,
                      const StatsView(),
                      context,
                    );
                  case HomeView.routeName:
                    return _buildScaffold(
                      HomeView.name,
                      const HomeView(),
                      context,
                    );
                  default:
                    return AuthorizationView(
                      controller: widget.authorizationController,
                      onSuccess: _onAuthorizationSuccess,
                    );
                }
              },
            );
          },
        );
      },
    );
  }
}
