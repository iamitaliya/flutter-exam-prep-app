import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'core/services/hive_service.dart';
import 'app.dart';

/// Application entry point.
///
/// Initialisation order (all before [runApp]):
///   1. Flutter engine bindings
///   2. System UI overlay style (status bar / navigation bar)
///   3. Hive (local database) — opens boxes and registers adapters
///   4. Google Mobile Ads SDK
///   5. [runApp] inside a [ProviderScope]
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set the system overlay style for the status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D1B2A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialise Hive and register type adapters
  await HiveService.init();

  // Initialise Google Mobile Ads
  // This is non-blocking — the app starts before ads finish loading.
  MobileAds.instance.initialize();

  runApp(
    // ProviderScope is the root of the Riverpod dependency injection tree.
    // All providers are available to any descendant widget.
    const ProviderScope(
      child: App(),
    ),
  );
}
