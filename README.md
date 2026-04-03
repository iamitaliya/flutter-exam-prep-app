# ExamPrep — Flutter Exam Preparation App

A cross-platform (iOS & Android) exam preparation app with topic-based progress tracking, rich question types, and a Free / Pro tier system.

---

## Features

| Feature | Detail |
|---|---|
| **Question Types** | Text, Photo (image), Video |
| **Answer Types** | Single choice, Multi-select, Text entry |
| **Progress Tracking** | Per-topic accuracy, strength classification, failed question history |
| **Topic Dashboard** | Visual grid showing Strong / Average / Weak / Untested for every topic |
| **Review Mode** | Review all failed answers from any session; re-practice them in a focused session |
| **Explanations** | Shown immediately after a wrong answer |
| **Free / Pro Tier** | Free tier shows banner + interstitial ads; Pro tier removes all ads |
| **Offline** | All questions bundled in `assets/data/questions.json` — no network required |

---

## Architecture

```
lib/
├── main.dart                   # App entry point (Hive init, MobileAds init, runApp)
├── app.dart                    # Root MaterialApp.router with theme + GoRouter
│
├── core/
│   ├── constants/              # AppColors, AppTypography, AppSpacing, AppConstants
│   ├── theme/                  # AppTheme (dark + light ThemeData)
│   ├── router/                 # GoRouter config, RouteNames
│   ├── models/                 # Question, AnswerOption, Topic, TopicProgress, ExamSession
│   ├── services/               # HiveService, QuestionLoaderService
│   ├── providers/              # hiveServiceProvider, questionDataProvider
│   └── widgets/                # AppCard, PrimaryButton, SecondaryButton, TopicStrengthBadge
│
└── features/
    ├── onboarding/             # SplashScreen, OnboardingScreen (3-page)
    ├── dashboard/              # DashboardScreen, dashboardProvider
    ├── topics/                 # TopicListScreen, topicsWithProgressProvider
    ├── exam/                   # QuestionScreen, ResultsScreen, ReviewScreen, examSessionProvider
    ├── settings/               # SettingsScreen, UserSettings, userSettingsProvider
    └── ads/                    # BannerAdWidget (Google Mobile Ads)
```

### Technology Stack

| Concern | Library |
|---|---|
| State management | `hooks_riverpod` + `StateNotifier` |
| Navigation | `go_router` (ShellRoute for bottom nav tabs) |
| Local persistence | `hive_flutter` (progress + sessions) + `shared_preferences` (settings) |
| UI / Charts | `percent_indicator`, `shimmer`, `flutter_animate` |
| Media | `cached_network_image`, `video_player` |
| Ads | `google_mobile_ads` |
| IAP | `in_app_purchase` (ready for Pro upgrade) |

---

## Getting Started

### Prerequisites

- Flutter SDK `>=3.22.0`
- Dart SDK `>=3.4.0`
- Android SDK (minSdk **23** required by Google Mobile Ads)
- Xcode 15+ (for iOS)

### Setup

```bash
# 1. Install dependencies
flutter pub get

# 2. Run the app
flutter run

# 3. Build for release
flutter build apk --release        # Android
flutter build ipa --release        # iOS (requires signing)
```

---

## Question Content

All questions live in `assets/data/questions.json`. The schema is:

```json
{
  "topics": [
    {
      "id": "unique_topic_id",
      "name": "Topic Name",
      "description": "Short description",
      "totalQuestions": 10,
      "orderIndex": 0
    }
  ],
  "questions": [
    {
      "id": "unique_question_id",
      "topicId": "unique_topic_id",
      "questionType": "text",           // "text" | "photo" | "video"
      "answerType": "multipleChoice",   // "multipleChoice" | "multiSelect" | "textEntry"
      "questionText": "The question?",
      "imageUrl": "https://...",        // optional, for photo questions
      "videoUrl": "https://...",        // optional, for video questions
      "options": [
        { "id": "opt_a", "text": "Option A" }
      ],
      "correctOptionIds": ["opt_a"],    // for multipleChoice/multiSelect
      "correctTextAnswer": "answer",   // for textEntry (case-insensitive match)
      "explanation": "Why this is correct...",
      "difficultyLevel": 1,            // 1 = Easy, 2 = Medium, 3 = Hard
      "orderIndex": 0
    }
  ]
}
```

The included sample data has **30 questions** across 4 topics:
- Flutter Basics (8 questions)
- Dart Language (8 questions)
- State Management (7 questions)
- Navigation & Routing (7 questions)

---

## Free vs Pro

### Current Implementation (Testing)
The **Settings screen** has a "Pro Mode" toggle (clearly labelled "Testing only"). Toggling it on:
- Hides banner ads on the Dashboard and Question screens
- The flag is stored in `SharedPreferences` under the key `is_pro`

### Production Upgrade Path
To ship real in-app purchase:
1. Replace `UserSettingsNotifier.setIsPro()` in `lib/features/settings/providers/settings_provider.dart` with an `in_app_purchase` purchase flow.
2. Replace the debug toggle in `SettingsScreen` with an "Upgrade to Pro — $X.XX" button.
3. Update `AppConstants.admobAppIdAndroid` / `admobAppIdIos` and ad unit IDs with your real AdMob IDs.

The `in_app_purchase` package is already declared in `pubspec.yaml`. No other changes needed.

---

## Ads Configuration

The app uses **Google Mobile Ads** with **test ad unit IDs** during development. Before publishing:

1. Create an AdMob account and register your app.
2. Replace the test IDs in `lib/core/constants/app_constants.dart`:

```dart
static const String bannerAdUnitIdAndroid       = 'ca-app-pub-XXXXXXXX/YYYYYYYY';
static const String bannerAdUnitIdIos           = 'ca-app-pub-XXXXXXXX/YYYYYYYY';
static const String interstitialAdUnitIdAndroid = 'ca-app-pub-XXXXXXXX/YYYYYYYY';
static const String interstitialAdUnitIdIos     = 'ca-app-pub-XXXXXXXX/YYYYYYYY';
```

3. Update the AdMob Application IDs in:
   - `android/app/src/main/AndroidManifest.xml` → `<meta-data android:name="com.google.android.gms.ads.APPLICATION_ID" .../>`
   - `ios/Runner/Info.plist` → `GADApplicationIdentifier`

---

## Design System

| Token | Value |
|---|---|
| Background | `#0D1B2A` (deep navy) |
| Surface | `#1A2D42` (lighter navy) |
| Accent | `#F0A500` (warm gold) |
| Text primary | `#F0F4F8` |
| Text secondary | `#8FA3B1` |
| Success (strong) | `#2ECC71` |
| Warning (average) | `#F39C12` |
| Error (weak) | `#E74C3C` |
| Font family | **Nunito** (Google Fonts) |
| Card radius | 16dp |
| Screen padding | 20dp |

---

## Navigation Map

```
/                    SplashScreen (auto-redirect after 2s)
/onboarding          OnboardingScreen (3-page, shown once)
ShellRoute (BottomNav: Dashboard | Topics | Settings)
  /dashboard         DashboardScreen
  /topics            TopicListScreen
  /settings          SettingsScreen
/topics/:id/exam     QuestionScreen (topicId, 'all', or 'review')
/exam/results        ResultsScreen
/exam/review         ReviewScreen
```

---

## Data Flow

```
assets/data/questions.json
       │
       ▼
QuestionLoaderService (cached singleton)
       │
       ▼
questionDataProvider (FutureProvider, keepAlive)
       │
  ┌────┴────────────────┐
  ▼                     ▼
topicsWithProgress   dashboardProvider
Provider                 │
  │                      ▼
  ▼               DashboardScreen
TopicListScreen

User answers ──► ExamSessionNotifier.submitAnswer()
                         │
                ┌────────┴────────┐
                ▼                 ▼
         HiveService          HiveService
     (TopicProgress)       (ExamSession)
```

---

## License

MIT