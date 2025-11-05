# Organizational App

Flutter 3.x UI-only prototype for the Organizational App spec. The app focuses on navigation, layout, and interactive flows without connecting to live services. Sample tasks and lists are injected through `TasksCubit.seedDemoData()` to keep demos consistent.

## Highlights
- Multi-screen routing with `go_router`, including guarded login flows and deep links.
- Task-centric UI covering My Day, Important, list views, and detail flows with add-note overlays.
- Floating actions for Copilot and group creation showcased through custom dialogs and FAB layouts.
- Theme management via `flutter_bloc`, supporting light, dark, and system modes out of the box.
- Settings, notifications, and policy pages included as static content templates for future expansion.

## Project Structure
- `lib/main.dart` boots the app with `MultiBlocProvider` and `MaterialApp.router`.
- `lib/router/app_router.dart` centralizes page registration, transitions, and auth redirects.
- `lib/state/` hosts Cubits for auth, theme, and task state backed by models in `lib/model/`.
- `lib/ui/` separates layout scaffolds, feature pages, and reusable widgets for clarity.

```
lib/
|-- main.dart
|-- model/
|   |-- task.dart
|   |-- user.dart
|-- router/
|   |-- app_router.dart
|-- state/
|   |-- auth_cubit.dart
|   |-- tasks_cubit.dart
|   |-- theme_cubit.dart
`-- ui/
    |-- layout/
    |-- pages/
    `-- widgets/
```

## Primary Dependencies
- `flutter_bloc` for Cubit-based presentation logic and theme toggling.
- `go_router` for declarative navigation and deep-link friendly routing.
- `equatable` to simplify state comparison in immutable models and Cubits.
- `intl` reserved for future formatting and localization work.

## Getting Started
1. Install Flutter 3.3 or newer and configure target platforms (`flutter doctor`).
2. Fetch packages with `flutter pub get` from the repository root.
3. Launch the UI prototype using `flutter run -d <device>` (for example `chrome`, `windows`, or `android`).
4. Optional: format with `flutter format .` and analyze with `flutter analyze` before submitting changes.

## Development Notes
- The demo dataset lives in `TasksCubit.seedDemoData()`; adjust it to showcase additional scenarios.
- Authentication state is mocked, so replace `AuthCubit` with a real service layer when APIs are ready.
- Add new feature pages under `lib/ui/pages/` and register them in `AppRouter.create` to expose routes.
- Keep Cubit states immutable and rely on `copyWith` patterns to avoid unintended widget rebuilds.
