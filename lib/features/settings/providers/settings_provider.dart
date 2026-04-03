import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

class UserSettings {
  final bool isPro;
  final bool onboardingComplete;
  final double passingThreshold;
  final int questionsPerSession;
  final String themeMode;

  const UserSettings({
    this.isPro = false,
    this.onboardingComplete = false,
    this.passingThreshold = AppConstants.defaultPassingThreshold,
    this.questionsPerSession = AppConstants.defaultQuestionsPerSession,
    this.themeMode = AppConstants.defaultThemeMode,
  });

  UserSettings copyWith({
    bool? isPro,
    bool? onboardingComplete,
    double? passingThreshold,
    int? questionsPerSession,
    String? themeMode,
  }) {
    return UserSettings(
      isPro: isPro ?? this.isPro,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      passingThreshold: passingThreshold ?? this.passingThreshold,
      questionsPerSession: questionsPerSession ?? this.questionsPerSession,
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  SharedPreferences? _prefs;

  UserSettingsNotifier() : super(const UserSettings());

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    state = UserSettings(
      isPro: _prefs!.getBool(AppConstants.keyIsPro) ?? false,
      onboardingComplete:
          _prefs!.getBool(AppConstants.keyOnboardingComplete) ?? false,
      passingThreshold: _prefs!.getDouble(AppConstants.keyPassingThreshold) ??
          AppConstants.defaultPassingThreshold,
      questionsPerSession: _prefs!.getInt(AppConstants.keyQuestionsPerSession) ??
          AppConstants.defaultQuestionsPerSession,
      themeMode: _prefs!.getString(AppConstants.keyThemeMode) ??
          AppConstants.defaultThemeMode,
    );
  }

  Future<void> setIsPro(bool value) async {
    await _prefs?.setBool(AppConstants.keyIsPro, value);
    state = state.copyWith(isPro: value);
  }

  Future<void> completeOnboarding() async {
    await _prefs?.setBool(AppConstants.keyOnboardingComplete, true);
    state = state.copyWith(onboardingComplete: true);
  }

  Future<void> setPassingThreshold(double value) async {
    await _prefs?.setDouble(AppConstants.keyPassingThreshold, value);
    state = state.copyWith(passingThreshold: value);
  }

  Future<void> setQuestionsPerSession(int value) async {
    await _prefs?.setInt(AppConstants.keyQuestionsPerSession, value);
    state = state.copyWith(questionsPerSession: value);
  }

  Future<void> setThemeMode(String value) async {
    await _prefs?.setString(AppConstants.keyThemeMode, value);
    state = state.copyWith(themeMode: value);
  }
}

final userSettingsProvider =
    StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});
