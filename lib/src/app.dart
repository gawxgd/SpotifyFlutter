import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:spotify_flutter/src/authorization/authorization_controller.dart';
import 'package:spotify_flutter/src/authorization/authorization_view.dart';
import 'package:spotify_flutter/src/game_host/game_view.dart';
import 'package:spotify_flutter/src/game_lobby/game_lobby_view.dart';
import 'package:spotify_flutter/src/game_player/game_player_view.dart';
import 'package:spotify_flutter/src/home/home_view.dart';
import 'package:spotify_flutter/src/join_game/join_game_view.dart';
import 'package:spotify_flutter/src/leaderboard/leaderboard_view.dart';
import 'package:spotify_flutter/src/main_scaffold.dart';
import 'package:spotify_flutter/src/prepare_game/prepare_game_view.dart';
import 'package:spotify_flutter/src/profile/profile_view.dart';
import 'package:spotify_flutter/src/stats/stats_view.dart';

import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

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
  late final AppLinks _appLinks;
  StreamSubscription<Uri>? _linkSubscription;

  final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _router = GoRouter(
      navigatorKey: _rootNavigatorKey,
      initialLocation: AuthorizationView.routeName,
      routes: [
        GoRoute(
          path: AuthorizationView.routeName,
          builder: (context, state) => AuthorizationView(
            controller: widget.authorizationController,
            onSuccess: () => _router.go(HomeView.routeName),
          ),
        ),
        GoRoute(
          path: HomeView.routeName,
          builder: (context, state) => const MainScaffold(
            title: HomeView.name,
            body: HomeView(),
          ),
        ),
        GoRoute(
          path: SettingsView.routeName,
          builder: (context, state) => MainScaffold(
            title: SettingsView.name,
            body: SettingsView(controller: widget.settingsController),
          ),
        ),
        GoRoute(
          path: ProfileView.routeName,
          builder: (context, state) => const MainScaffold(
            title: ProfileView.name,
            body: ProfileView(),
          ),
        ),
        GoRoute(
          path: StatsView.routeName,
          builder: (context, state) => const MainScaffold(
            title: StatsView.name,
            body: StatsView(),
          ),
        ),
        GoRoute(
          path: PrepareGameView.routeName,
          builder: (context, state) => const MainScaffold(
            title: PrepareGameView.name,
            body: PrepareGameView(),
          ),
        ),
        GoRoute(
          path: GameLobbyView.routeName,
          builder: (context, state) => const MainScaffold(
            title: GameLobbyView.name,
            body: GameLobbyView(),
          ),
        ),
        GoRoute(
          path: JoinGameView.routeName,
          builder: (context, state) {
            final roomId = state.uri.queryParameters['roomId'];
            return JoinGameView(roomId: roomId);
          },
        ),
        GoRoute(
            path: GameHostView.routeName,
            builder: (context, state) {
              return const GameHostView();
            }),
        GoRoute(
            path: LeaderboardView.routeName,
            builder: (context, state) {
              return const LeaderboardView();
            }),
        GoRoute(
          path: GamePlayerView.routeName,
          builder: (context, state) => const GamePlayerView(),
        ),
      ],
      redirect: (context, state) async {
        final isAuthenticated =
            await widget.authorizationController.checkAuthorization();

        if (!isAuthenticated &&
            state.uri.toString() != AuthorizationView.routeName) {
          return AuthorizationView.routeName;
        }
        return null;
      },
    );

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
      if (uri.pathSegments.contains('joingame')) {
        final roomId = uri.queryParameters['roomId'];
        if (roomId != null) {
          debugPrint('Navigating to join game view with Room ID: $roomId');
          _router.go('${JoinGameView.routeName}?roomId=$roomId');
        } else {
          debugPrint('No roomId found in the deep link');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp.router(
          routerConfig: _router,
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
            primaryColor: Colors.purple,
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.purple,
              primary: Colors.purple,
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData.dark().copyWith(
            primaryColor: Colors.purple,
            colorScheme: const ColorScheme.dark(
              primary: Colors.purple,
            ),
          ),
          themeMode: widget.settingsController.themeMode,
        );
      },
    );
  }
}
