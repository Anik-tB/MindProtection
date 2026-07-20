# MindProtection

MindProtection is a Flutter app for digital wellbeing, focus, habit building, and addiction recovery support. It combines local-first tracking with optional Supabase cloud sync, Android-focused blocking tools, gamification, wellbeing check-ins, and an AI coach.

## Features

- Dashboard with focus score, streaks, wellbeing summaries, and progress cards
- Focus timer with Pomodoro, stopwatch, deep focus, and subject session tracking
- Planner for tasks, routines, goals, and scheduled work
- Habit tracker with streaks, history, and heatmap-style progress views
- Wellbeing tools for sleep, hydration, mood, breathing, and reminders
- Recovery/guard mode with sobriety tracking and emergency lock UI
- Android blocking support using usage stats, accessibility, foreground service, notification listener, and device admin hooks
- Supabase authentication and cloud sync schema
- AI coach with local fallback responses and optional Gemini API support
- PIN-based startup lock and account/security screens

## Tech Stack

- Flutter / Dart
- Riverpod for state management
- Isar for local storage
- Supabase for auth and cloud sync
- Google Generative AI package for optional Gemini coach responses
- Android native integrations for blocking and monitoring features

## Project Structure

```text
lib/
  core/
    db/          Isar local database setup
    network/     Supabase config, auth, and sync helpers
    theme/       App theme
    ui/          Shared UI surfaces
  features/
    ai_coach/
    auth/
    blocking/
    community/
    dashboard/
    focus/
    gamification/
    habits/
    notifications/
    planner/
    recovery/
    security/
    wellbeing/
android/         Android app shell and native permission/service config
ios/             iOS app shell
assets/          App assets
test/            Widget and feature tests
```

## Setup

Install Flutter, then run:

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

If generated Riverpod or Isar files are already current, the `build_runner` step may not be needed every time.

## Supabase

The app initializes Supabase from:

```text
lib/core/network/supabase_config.dart
```

Database setup lives in:

```text
supabase_schema.sql
```

Run the SQL file in the Supabase SQL editor before testing cloud sync or account data. Keep service-role keys private; the app should only use public anon/publishable client keys.

## AI Coach

The AI coach works without an API key by using local fallback responses. To enable Gemini responses, enter a Gemini API key inside the AI coach settings screen. The key is stored locally on the device with `shared_preferences`.

## Android Permissions

Some protection features need Android system access:

- Usage access for screen time tracking
- Accessibility service for real-time app blocking
- Notification access for notification vault/blocking behavior
- Device admin for strict lock and anti-uninstall flows
- Exact alarm/notification permissions for reminders

These permissions must be enabled manually by the tester when Android prompts for them.

## Build And Share

For a quick Android test build:

```bash
flutter build apk --debug
```

The APK is created at:

```text
build/app/outputs/flutter-apk/app-debug.apk
```

You can send that APK to a friend on Android. They may need to allow "Install unknown apps" before installing it.

For a release-style APK:

```bash
flutter build apk --release
```

The current Android release config still uses the debug signing config, so it is fine for private testing but not ready for Play Store publishing. Before publishing, create a real upload keystore and configure release signing.

## iOS Sharing

Android APKs do not work on iPhone. To share with an iPhone user, use TestFlight or install from Xcode with a valid Apple Developer signing setup.

## Testing

Run the test suite with:

```bash
flutter test
```

## Notes

- Android is the primary target for blocking and device-protection features.
- Supabase-backed features require the configured Supabase project and schema.
- Gemini-backed AI responses require a user-provided Gemini API key; otherwise the local coach engine is used.
