# Environment & Configuration — ResumeKit Pro

---

## `.env` Variables

| Variable | Required | Description |
|----------|----------|-------------|
| `API_BASE_URL` | Yes | Base URL for REST API calls |
| `ENCRYPTION_KEY` | Yes | AES key for encrypted SharedPreferences |


---

## Reading Env Vars

Always use `envOr()` from `lib/global/utils/env_helper.dart`:

```dart
import 'package:template/global/utils/env_helper.dart';

final baseUrl = envOr('API_BASE_URL', fallback: 'https://jsonplaceholder.typicode.com');
```

**Never** access `dotenv.env['KEY']` directly — throws if dotenv not loaded.

---

## Startup Order

```dart
await dotenv.load(fileName: '.env');  // FIRST
await initSDK();                       // THEN (reads env)
```

---

## Android Manifest Permissions

Always included:

- `INTERNET`
- `ACCESS_NETWORK_STATE`
- `POST_NOTIFICATIONS`
- Storage permissions (as needed)

FCM intent filter only when Firebase Messaging is enabled.

---

## Gradle / Firebase

When Firebase is enabled:

- `android/app/google-services.json`
- Google Services Gradle plugin
- `lib/firebase_options.dart`

---

## Secrets Policy

- Do **not** commit production API keys or encryption keys
- Use CI secrets for release builds
- Demo `.env` values are placeholders only

---

## Flavors (optional)

| Flavor | Use |
|--------|-----|
| dev | Local development |
| qa | QA testing |
| staging | Pre-production |
| production | Store release |

```bash
flutter run --flavor dev
```
