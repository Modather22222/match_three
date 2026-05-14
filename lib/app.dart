// =============================================================================
// APP ROUTER
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_game/screens/main_menu_screen.dart';
import 'package:flutter_game/screens/level_select_screen.dart';
import 'package:flutter_game/screens/game_screen.dart';
import 'package:flutter_game/screens/shop_screen.dart';
import 'package:flutter_game/screens/settings_screen.dart';

/// Central route configuration for the app.
/// All transitions use the fade-to-black pattern (§3.2).
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return _buildRoute(settings, const MainMenuScreen());
      case '/level-select':
        return _buildRoute(settings, const LevelSelectScreen());
      case '/game':
        final level = settings.arguments as int? ?? 1;
        return _buildRoute(settings, GameScreen(level: level));
      case '/shop':
        return _buildRoute(settings, const ShopScreen());
      case '/settings':
        return _buildRoute(settings, const SettingsScreen());
      default:
        return _buildRoute(settings, const MainMenuScreen());
    }
  }

  static PageRouteBuilder _buildRoute(RouteSettings settings, Widget child) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade-to-black transition (§3.2)
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 500),
    );
  }
}