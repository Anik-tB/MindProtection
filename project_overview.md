# MindProtection – AI Digital Wellbeing & Addiction Recovery Platform

## Project Overview
A Premium Digital Wellbeing, Focus, Productivity, and Addiction Recovery App built with Flutter.

## Core Goals
* Screen Time Reduction
* Focus Improvement
* Study Productivity Enhancement
* Self-Discipline & Habit Formation
* Better Sleep Hygiene
* Healthy Lifestyle Building
* Digital Addiction Recovery Support (Phone, Porn, Social Media, Gaming, etc.)

---

## Core Features

### 1. Dashboard
* Daily & Weekly Screen Time Tracking
* Monthly Analytics
* Focus Score & Productivity Score
* Streak Counter (Habits / Sobriety / Focus)
* Goals & Habit Progress
* Mood & Sleep Summaries

### 2. Focus System
* **Focus Timer:** Custom, Countdown, and Stopwatch Modes.
* **Pomodoro:** Customizable sessions with long break support (default 25/5).
* **Deep Focus Mode:** Strict blocking, no exit until session ends, with a highly protected emergency exit.
* **Study Sessions:** Subject tracking, session history, and study analytics.

### 3. Planner System
* **Daily Planner:** Tasks, scheduling, and priority management.
* **Routine Planner:** Morning, Study, and Night routines.
* **Calendar:** Daily, Weekly, and Monthly views.
* **Goals:** Short-term and long-term goal tracking.

### 4. Habit Tracking
* Custom habits, daily check-ins, habit streaks, statistics, and completion rates.

### 5. Health & Wellbeing
* **Sleep Tracker:** Schedule, bedtime/wake-up reminders.
* **Water Reminder:** Daily goal, smart notifications.
* **Exercise/Stretch Reminders:** Active alerts.
* **Eye Care:** 20-20-20 rule helper.
* **Mood Tracker:** Daily logging and mood analytics.
* **Meditation:** Guided sessions, breathing exercises.
* **Prayer Reminder:** Tracking and alerts.

### 6. Addiction Recovery System
* **Phone Addiction:** Usage limits, daily goals, warning notifications.
* **Social Media Limiter:** Blockers/limiters for Facebook, Instagram, TikTok, Snapchat, etc.
* **Shorts/Reels Block:** Targeted blocking of YouTube Shorts, FB/IG Reels, TikTok Feed.
* **Porn Recovery System:** Adult site blocking, DNS filtering, Safe Search enforcement, recovery dashboard, relapse tracking, streaks.

### 7. Blocking Engine (Android Focus)
* **App Blocking:** App-specific, category-based, and schedule-based.
* **Time Blocking:** Daily and weekly usage limits.
* **Strict Mode:** Prevention of disabling/uninstalling during focus sessions.
* **Emergency Lock:** Temporary full device lock.
* **Notification Blocking:** Hiding notifications and storing them in an in-app vault.
* **Internet Control:** Internet lock, per-app internet blocking.
* **Whitelists & Blacklists**

### 8. Analytics
* Usage Analytics (Daily, Weekly, Monthly, Yearly)
* Charts (Heat maps, Line, Bar, Pie charts)
* Export options (PDF, Email)

### 9. Gamification
* XP, Coins, Levels, Achievements, Badges, Daily Challenges, and Streak Rewards.

### 10. AI Features
* **AI Coach:** Tailored advice, focus/habit/recovery recommendations.
* **Smart Insights:** Usage pattern detection, risk alerts, productivity tips.

### 11. Community Features
* Study & Focus rooms, Accountability partners, Leaderboards, Groups.

### 12. Security
* PIN, Password, Fingerprint/Face authentication.
* Anti-uninstall and Device Admin protection.

---

## Technical Specifications

### Frontend
* **Framework:** Flutter
* **Design System:** Material 3, Premium modern dark-themed glassmorphic UI, smooth micro-animations, pixel-perfect responsive layouts.
* **State Management:** Riverpod (flutter_riverpod)
* **Architecture:** Clean Architecture + MVVM
* **Local Database:** Hive or Isar

### Backend (Supabase)
* Supabase Auth (Email/Socials), Supabase PostgreSQL Database, Supabase Storage.

### Native Android Integration
* **Accessibility Service:** For real-time app/web blocking and layout inspection.
* **Usage Stats API:** For screen time tracking and app usage duration monitoring.
* **Notification Listener Service:** For blocking, capturing, and vaulting notifications.
* **Foreground Service:** To ensure persistent tracking, blocking engine integrity, and avoid OS-termination.
* **Device Admin APIs:** For anti-uninstall protection and emergency lock capabilities.
