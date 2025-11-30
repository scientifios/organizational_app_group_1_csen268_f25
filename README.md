# Organizational App (CSEN268 F25)

Single-user task/notes app (My Day, lists, reminders) built with Flutter + Firebase. Includes in-app message center and push reminders via Firebase Cloud Messaging + Cloud Functions.

## Features
- Tasks with due date/time, priority, steps, notes, My Day and Important flags
- Reminder options: off, at due, 5 minutes from now, repeat every 5 minutes until due, 1–3 days before
- In-app Messages page fed by task events + push notifications
- Firebase Auth + Firestore persistence; Cloud Functions for scheduled reminders
- Light/dark theme, simple routing via go_router

## Prerequisites
- Flutter 3.3+ with required toolchains (`flutter doctor` clean)
- Node 18+ for Firebase CLI / functions deploy
- Firebase project (Blaze plan enabled for scheduled functions)
- Android/iOS: enable Developer Mode on Windows to allow symlinks when building Flutter

## Setup (Firebase + app)
1) Clone repo and install deps
```bash
flutter pub get
```

2) Configure Firebase
- Install Firebase CLI and FlutterFire CLI: `npm i -g firebase-tools` and `dart pub global activate flutterfire_cli`
- Login: `firebase login`
- Run FlutterFire: `flutterfire configure` selecting your Firebase project; it generates `lib/firebase_options.dart` and platform configs (`google-services.json`, `GoogleService-Info.plist`).
- Ensure Firebase products enabled: Auth, Firestore, Cloud Messaging, Cloud Functions, (optional) Storage.

3) Firestore data model
- `users/{uid}/tasks/{taskId}`: title, completed, important, myDay, dueDate (Timestamp), notifyBeforeDays (int), priority, steps (array), note, estimateMinutes, listId, createdAt, updatedAt
- `users/{uid}/lists/{listId}`: name, createdAt
- `notifications/{uid}/messages/{messageId}`: title, body, route?, taskId?, createdAt
- `user_tokens/{uid}/tokens/{token}`: token docs (id = FCM token)
- `users/{uid}/reminders/{taskId}`: created by app to schedule pushes (notifyAt, repeatIntervalMinutes, sent, dueDate, title, taskId)

4) Cloud Functions (FCM reminders)
- From `functions/` install deps: `npm install`
- Deploy: `npx firebase-tools deploy --only functions:sendTaskReminders,functions:onNotificationCreated`
- Function behavior:
  - `sendTaskReminders` runs every 5 minutes, sends due reminders, supports repeat-every-5-min until due
  - `onNotificationCreated` pushes FCM when a Firestore notification doc is created

5) Push setup (mobile)
- Android: `google-services.json` in `android/app`; enable FCM in Firebase console
- iOS: `GoogleService-Info.plist` in `ios/Runner`; enable Push capability, request notification permission at runtime
- App uses `FirebaseMessaging` and registers background handler in `lib/main.dart`

6) External API keys
- Gemini / OpenAI are not wired into the app yet; if you add LLM features, inject keys via `.env` or Dart consts and **never commit secrets**. Document variables like `GEMINI_API_KEY` or `OPENAI_API_KEY` and load them in your services.

## Running
```bash
flutter run -d <device>
```
- First launch will ask for notification permission; allow it to test FCM.
- Find your FCM token in debug logs (`FCM token: ...`) and verify it is written under `user_tokens/{uid}/tokens/{token}`.

## Quick tests
- In Firestore, add a doc under `notifications/{uid}/messages` with `title/body`; you should see an in-app message + a push.
- Create a task with “Repeat every 5 minutes until due” and a due time ~20–30 min ahead; you should receive multiple pushes until the deadline.

## Project layout
```
lib/
  main.dart                # boot + PushNotificationService wiring
  router/app_router.dart   # go_router setup
  model/task.dart          # task model
  repository/              # tasks, reminders, notifications, messages
  state/                   # cubits for auth, tasks, messages, theme
  ui/pages/                # list page, task detail, messages page, etc.
functions/index.js         # Cloud Functions (reminders + FCM fan-out)
```

## Notes
- If you update dependencies, run `flutter pub upgrade` and `npm audit fix` (functions) as needed.
- Scheduled functions need Blaze (billing) and Cloud Scheduler enabled; otherwise deployments will fail.
- Keep secrets out of git; share sample `.env`/config instructions instead.
