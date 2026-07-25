import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/providers/settings_provider.dart';

/// Root application widget.
///
/// Reads the [appRouterProvider] and [userSettingsProvider] to configure
/// the router and apply the correct theme.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(
      userSettingsProvider.select((s) => s.themeMode),
    );

    return MaterialApp.router(
      title: 'ExamPrep',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: _resolveThemeMode(themeMode),
      routerConfig: router,
    );
  }

  ThemeMode _resolveThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.dark; // default dark for premium look
    }
  }
}
