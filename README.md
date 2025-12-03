# Organizational App (CSEN268 F25)

Single-user task/notes app built with Flutter + Firebase. It supports My Day, lists, due reminders (FCM), in-app messages, and note attachments (camera/gallery). This repo is meant to be re-used with **your own Firebase project/keys**—see setup below.

## Features
- Tasks: due date/time, priority, steps, notes, My Day / Important flags, list grouping.
- Reminders: up to two pushes per task (10 minutes before due, and at/after due) driven by Cloud Functions + FCM.
- In-app Messages: task events + push notifications with basic de-dup.
- Notes: text plus up to 3 photos (camera or gallery), stored in Firebase Storage.
- Auth & persistence: Firebase Auth + Firestore; routes via go_router; light/dark theme.

## Tech stack
- Flutter, Bloc, go_router, image_picker, intl.
- Firebase: Auth, Firestore, Storage, Cloud Messaging.
- Cloud Functions (Node.js 20) + Cloud Scheduler (every 1 minute) for reminders.

## Prerequisites
- Flutter 3.3+ (`flutter doctor` clean).
- Node 18+ for Firebase CLI / functions.
- A Firebase project (Blaze plan needed for scheduled functions).
- Android/iOS toolchains as usual.

## Setup (connect your own Firebase/API keys)
1) Install deps:
```bash
flutter pub get
```

2) Firebase CLI & FlutterFire:
```bash
npm i -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --project <your_project_id>
```
This generates `lib/firebase_options.dart` and places `google-services.json` (Android) / `GoogleService-Info.plist` (iOS). Ensure Auth, Firestore, Cloud Messaging, Storage, and Cloud Functions are enabled in the console.

3) Firestore index (required for reminders):
- Create a **composite index** on collection group `tasks` with fields: `completed` Asc, `dueDate` Asc.

4) Optional external keys (LLM, etc.):
- Gemini/OpenAI are **not wired by default**. If you add them, provide keys via `--dart-define` or a .env loader, e.g.:
  - `GEMINI_API_KEY=...`
  - `OPENAI_API_KEY=...`
  Keep secrets out of git; document how they’re loaded in your service code.

5) Cloud Functions (reminders & FCM fan-out):
```bash
cd functions
npm install
firebase deploy --only functions:sendTaskReminders,functions:onNotificationCreated
```
- `sendTaskReminders`: runs every 1 minute; for each incomplete task sends at most two notifications (10 minutes before due; at/after due) and sets `preReminderSent` / `dueReminderSent`.
- `onNotificationCreated`: pushes FCM when a Firestore `notifications/{uid}/messages` doc is created.

## Firestore data model (current)
- `users/{uid}/tasks/{taskId}`: title, completed, important, myDay, dueDate (Timestamp), priority, steps (array), note, estimateMinutes, listId, createdAt, updatedAt, preReminderSent (bool), dueReminderSent (bool), noteImageUrls (array<string>).
- `users/{uid}/lists/{listId}`: name, createdAt.
- `notifications/{uid}/messages/{messageId}`: title, body, route?, taskId?, createdAt.
- `user_tokens/{uid}/tokens/{token}`: device tokens (doc id = token).
- (Legacy, unused) `users/{uid}/reminders/{taskId}` from the old repeat-every-5-min logic.

## Running
```bash
flutter run -d <device>
```
- Allow notification permission on first launch. The FCM token appears in debug logs; ensure it’s stored under `user_tokens/{uid}/tokens/{token}`.

## Build
- Debug APK: `flutter build apk --debug`
- Release APK: `flutter build apk --release`
- iOS IPA (on macOS): `flutter build ipa --release`

## App icons
- Replace `assets/icons/appstore.png` with a 1024x1024 image, then regenerate:
```bash
dart run flutter_launcher_icons
```

## Quick tests
- Add a doc under `notifications/{uid}/messages` with `title/body`: should appear in Messages and push via FCM.
- Create a task with due time ~15–20 minutes out: expect one push at T-10 minutes and one at/after due if still incomplete.

## Project layout
```
lib/
  main.dart                # bootstrap + PushNotificationService wiring
  router/app_router.dart   # go_router setup
  model/task.dart          # task model (reminder flags, noteImageUrls)
  repository/              # tasks, notifications, messages, reminders (legacy)
  state/                   # cubits for auth, tasks, messages, theme
  ui/pages/                # home, tasks, task detail, messages, settings, etc.
functions/index.js         # Cloud Functions (reminders + FCM fan-out)
assets/icons/              # app icon source (appstore.png)
assets/animations/         # Lottie splash
```

## Notes & gotchas
- Scheduled functions require Blaze billing and Cloud Scheduler enabled.
- Network issues on emulators (DNS/GMS) can block Firestore/FCM; use a clean Play emulator or a real device with working DNS.
- Logout redirects to `/login`; reminders are now fixed to 10-min-before + due (no repeat-every-5-min). 
