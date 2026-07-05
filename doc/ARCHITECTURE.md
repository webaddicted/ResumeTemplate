# Architecture — ResumeKit Pro

> GetX feature-based architecture with clean separation of presentation, data, and domain layers.

---

## 1. High-Level Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Presentation                          │
│  features/*/presentation/*.dart                          │
│  BaseStatelessWidget / BaseStatefulWidget                │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│                    Controller                            │
│  features/*/controller/*_controller.dart                 │
│  BaseController + GetX reactive state                    │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│              Data + Domain                               │
│  data/*_repository.dart  →  domain/*_model.dart          │
│  BaseRepository                                          │
└─────────────────────────┬───────────────────────────────┘
                          │
┌─────────────────────────▼───────────────────────────────┐
│         Remote API  │  Local Storage  │  Firebase       │
│  ApiBaseHelper (Dio) │  SP / Encrypted │  (optional)     │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Folder Layout

```
lib/
├── main.dart
├── controller/
│   ├── initial_binding.dart
│   ├── routes.dart
│   └── theme_controller.dart
├── features/
│   ├── home/presentation/
│   ├── resume/{data,domain,presentation}/
│   ├── biodata/{domain,presentation}/
│   ├── cards/{domain,presentation}/
│   ├── ats_analysis/{data,domain,presentation}/
│   ├── jd_optimizer/{data,domain,presentation}/
│   └── final_validation/presentation/
└── global/
    ├── base/
    ├── apiutils/
    ├── constant/
    ├── extension/
    ├── services/          # data_service, encryption_service
    ├── sp/
    ├── theme/
    ├── utils/             # PDF generators, file import, env helpers
    └── widgets/           # form widgets, ATS widgets, resume/card templates
```

---

## 3. Dependency Rules

| From | May import |
|------|------------|
| `features/*` | `global/*`, `controller/*` (routes only) |
| `global/*` | Other `global/*` only |
| `controller/*` | `features/*`, `global/*` |
| Features | **Must not** import other features directly |

---

## 4. Base Class Contract

| Type | Base class | Override |
|------|------------|----------|
| Stateless screen | `BaseStatelessWidget` | `initBuild(context)` |
| Stateful screen | `BaseStatefulWidget` + `BaseState<T>` | `initBuild(context)` |
| Controller | `BaseController` | lifecycle hooks |
| Repository | `BaseRepository` | API / local methods |

**Exceptions:** Root `App` widget in `main.dart`; tiny private widgets inside a file.

---

## 5. Navigation

- **Engine:** GetX named routes (`GetMaterialApp`, `GetPage`)
- **Constants:** `RoutersConst` in `global/constant/routers_const.dart`
- **Registration:** `lib/controller/routes.dart`
- **Entry:** `HomePage` at `/home` — mode picker for Resume, Biodata, and Cards flows

---

## 6. Startup Sequence

```dart
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: 'assets/env', isOptional: true);
  await initSDK();
  runApp(const ResumeKitApp());
}
```

---

## 7. Responsive & Web

- `ResponsiveLayout` — mobile vs desktop shell
- `WebUrlHelper` — sync browser URL with tab index
- `web/index.html` — branded loader before first Flutter frame

---

## 8. Firebase (when enabled)

| Service | File | Init in main |
|---------|------|--------------|
| Core | `firebase_options.dart` | `Firebase.initializeApp` |
| Auth | `auth_service.dart` | optional |
| Analytics | `analytics_service.dart` | optional |
| Crashlytics | `crashlytics_service.dart` | mobile only |
| Firestore | `firestore_service.dart` | optional |
| Storage | `storage_service.dart` | optional |

Guard all mobile-only Firebase calls with `PlatformHelper.isMobile`.

---

## 9. Error Handling

- `apiHandler()` — unified loading / success / error / offline UI
- `showErrorSnackbar()` / `showSuccessSnackbar()` — user feedback
- Logger via `printLog()` in `widget_helper.dart`

---

## 10. Testing Strategy

| Layer | Test type |
|-------|-----------|
| Models | Unit tests (serialization) |
| Repositories | Unit tests with mocked Dio |
| Controllers | Unit tests with GetX test mode |
| Screens | Widget tests for critical flows |
