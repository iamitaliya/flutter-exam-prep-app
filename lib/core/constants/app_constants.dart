class AppConstants {
  AppConstants._();

  static const String appName = 'ExamPrep';
  static const String appVersion = '1.0.0';

  // Hive box names
  static const String topicProgressBox = 'topic_progress';
  static const String examSessionBox = 'exam_sessions';

  // SharedPreferences keys
  static const String keyIsPro = 'is_pro';
  static const String keyOnboardingComplete = 'onboarding_complete';
  static const String keyPassingThreshold = 'passing_threshold';
  static const String keyQuestionsPerSession = 'questions_per_session';
  static const String keyThemeMode = 'theme_mode';

  // Default values
  static const double defaultPassingThreshold = 0.70;
  static const int defaultQuestionsPerSession = 20;
  static const String defaultThemeMode = 'dark';

  // Question assets
  static const String questionsDataPath = 'assets/data/questions.json';

  // Ad unit IDs (test IDs for development)
  static const String bannerAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/6300978111';
  static const String bannerAdUnitIdIos =
      'ca-app-pub-3940256099942544/2934735716';
  static const String interstitialAdUnitIdAndroid =
      'ca-app-pub-3940256099942544/1033173712';
  static const String interstitialAdUnitIdIos =
      'ca-app-pub-3940256099942544/4411468910';

  // AdMob App IDs (test)
  static const String admobAppIdAndroid =
      'ca-app-pub-3940256099942544~3347511713';
  static const String admobAppIdIos = 'ca-app-pub-3940256099942544~1458002511';

  // Topic strength thresholds
  static const double strongThreshold = 0.75;
  static const double averageThreshold = 0.50;

  // Session constants
  static const int maxRecentSessions = 5;
  static const int passingScore = 70; // percentage
}
