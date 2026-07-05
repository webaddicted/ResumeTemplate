# Setup & Build — ResumeKit Pro

---

## Prerequisites

- Flutter 3.44.1 (stable)
- Dart 3.x
- Android Studio / Xcode (for mobile builds)
- Git

Verify:

```bash
flutter doctor -v
```

---

## 1. Clone & Install

```bash
git clone https://github.com/username/{{PACKAGE}.git}
cd template
flutter pub get
```

---

## 2. Environment

Create `.env` in project root:

```env
API_BASE_URL=https://your-api.example.com
ENCRYPTION_KEY=your-32-char-encryption-key-here
```

> `.env` is bundled as a Flutter asset — use non-production values in repo; override for release builds.

---

## 3. Assets & Icons

```bash
# Fonts and default images (if not present)
bash .cursor/skills/pipeline-setup-flutter-project/scripts/download-poppins-fonts.sh template

# Generate launcher icons
dart run flutter_launcher_icons
```

---

## 4. Run (Debug)

```bash
flutter run
flutter run -d chrome          # Web
flutter run -d <device-id>     # Specific device
```

---

## 5. Analyze & Test

```bash
flutter analyze
flutter test
dart fix --apply
```

---

## 6. Build Release

### Android APK

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (Play Store)

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
# Open Xcode for archive & upload
```

### Web

```bash
flutter build web --release
# Output: build/web/
```

---

## 7. Firebase (if enabled)

1. Replace demo `google-services.json` with production file
2. Run `flutterfire configure` for real `firebase_options.dart`
3. Add `GoogleService-Info.plist` for iOS

---

## 8. Signing (Release)

### Android

- Create keystore: `keytool -genkey ...`
- Configure `android/key.properties` and `build.gradle.kts`

### iOS

- Configure signing team in Xcode
- Provisioning profiles via Apple Developer portal

---

## 9. CI/CD (optional)

Example GitHub Actions steps:

```yaml
- run: flutter pub get
- run: flutter analyze
- run: flutter test
- run: flutter build apk --release
```

---

## 10. Troubleshooting

| Issue | Fix |
|-------|-----|
| `dotenv` not loaded | Ensure `dotenv.load()` before `initSDK()` |
| Missing fonts | Run `download-poppins-fonts.sh` |
| Web blank screen | Check `web/index.html` loader + `flutter build web` |
| Gradle errors | Run pipeline-upgrade-flutter-deps for Gradle sync |
