class RouteNames {
  RouteNames._();

  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String dashboard = '/dashboard';
  static const String topics = '/topics';
  static const String exam = '/topics/:topicId/exam';
  static const String results = '/exam/results';
  static const String review = '/exam/review';
  static const String settings = '/settings';

  static String examPath(String topicId) =>
      '/topics/$topicId/exam';
}
