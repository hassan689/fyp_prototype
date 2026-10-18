# NextGenYield — Flutter mobile app

A native Flutter prototype for Android and iOS, based on the wheat-monitoring concept in the supplied PDF. The UI is written in Dart using Flutter widgets. There is no WebView, HTML frontend, or web target in this mobile project.
<img width="384" height="842" alt="image" src="https://github.com/user-attachments/assets/a08942d9-636e-46d6-8fd1-f701e142b002" />
<img width="496" height="915" alt="Screenshot 2026-10-18 102037" src="https://github.com/user-attachments/assets/aacf03cd-70a6-4637-aa3c-9436e2b34bc9" />
<img width="494" height="913" alt="Screenshot 2026-10-18 102022" src="https://github.com/user-attachments/assets/0bc054ad-2aba-40fa-a115-135f08bb5b63" />
<img width="498" height="914" alt="Screenshot 2026-10-18 101957" src="https://github.com/user-attachments/assets/156180d8-86d7-474c-a515-db5e77c74c94" />
<img width="496" height="917" alt="Screenshot 2026-10-18 101931" src="https://github.com/user-attachments/assets/a15a457f-4a3a-4983-a9ef-6c5a30f388ab" />

## Open the project

Open this folder (the one containing `pubspec.yaml`) in Android Studio with the Flutter/Dart plugins or in VS Code with the Flutter extension. The app entry point is `lib/main.dart`.

Requirements:
- Flutter 3.47.7 / Dart 3.13.5 or a compatible newer stable SDK.
- For Android: Android SDK, Java 17 or later as supported by the Android Gradle plugin, and an Android phone with USB debugging or an emulator.
- For iOS: macOS, Xcode, and an iPhone or iOS simulator. Device builds require Apple signing configuration.

## Run on an Android phone or emulator

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
```

Replace `<android-device-id>` with the ID shown by `flutter devices`. Select an Android phone or emulator, not Chrome or Edge. In an IDE, select the Android device and run `lib/main.dart`.

## Build an APK when the Android SDK is available

```sh
flutter build apk --debug
```

The installable prototype will be at `build/app/outputs/flutter-apk/app-debug.apk`. Debug builds use development signing. Production publishing requires your own signing configuration; the generated release configuration also currently uses the debug key.

The Android SDK was **not installed**, as requested. No APK has been built or tested on an Android device in this environment. The Flutter source is ready for a machine with the Android toolchain installed. The SDK and its licenses must be configured by whoever runs the native build.

## Run on iOS

On a Mac with Xcode configured:

```sh
flutter pub get
flutter devices
flutter run -d <ios-device-id>
```

The iOS project is under `ios/`. iOS compilation and signing have not been verified on this Windows computer.

## Working prototype flows

- Mobile bottom navigation and Android Back behavior that returns from a tab to Home and from a field journal to the field list.
- Full-screen field-setup and scan flows on phones; dialogs on tablets.
- Dashboard with field switching, crop progress, sample weather, and checkable reminders.
- Add fields using rectangle/circle presets or tap-to-draw polygons. Missing names and crossing/degenerate boundaries are rejected. Area is an explicitly labeled practice-grid estimate, not a real land survey.
- Start a crop cycle with seed variety, supplier, fertilizer partner, and a non-future sowing date.
- Guided demo scan with an angle slider, sample result, and save-to-journal action.
- Six-stage crop journey, scan/care journal filters, and season information.
- Growing-plan browsing, variety filtering, plan details, and following a plan for the selected field.
- Anonymous illustrative regional plots.
- English/Urdu core navigation and overview labels, plus larger text. Other content remains English.
- On-device persistence using `shared_preferences` for fields, observations, crop cycles, settings, care tasks, and saved plans.

## Prototype scope

The app opens directly into a seeded demo farmer workspace. There is no authentication/backend service. Scans, confidence values, weather, plans, and regional plots are illustrative. The scan does not access the camera, motion sensors, or a trained model. Maps are original vector illustrations, not GPS or satellite maps. Full Urdu localization, narration, cloud synchronization, and live farming integrations are future work.

Saved data stays on the device. Clearing the app's data restores the seeded demo. Fonts and original illustrations are bundled locally; the prototype needs no API keys.

## Validate the Flutter code

```sh
flutter analyze
flutter test
```

Tests cover local persistence, polygon validation, phone layouts, navigation, Android Back behavior, demo scan saving, and field-name validation. Widget tests do not replace device testing or a native build.

## Project structure

- `lib/main.dart`: application entry point.
- `lib/src/app.dart`: mobile/tablet shell, navigation, preferences.
- `lib/src/design.dart`: styling, components, original vector artwork.
- `lib/src/store.dart`: data models and persistent state.
- `lib/src/dashboard.dart`: dashboard and care reminders.
- `lib/src/fields.dart`: field management and crop journal.
- `lib/src/discover.dart`: growing plans and regional preview.
- `lib/src/workflows.dart`: native Flutter field, cycle, and scan flows.
- `android/`: Android application project.
- `ios/`: iOS application project.
- `assets/fonts/`: Roboto font files and license.
- `docs/mobile-preview.png`: rendered phone layout.

The deliverable ZIP contains the mobile source project, tests, bundled assets, and instructions. It excludes web files, build caches, local SDK paths, and machine-specific configuration.
