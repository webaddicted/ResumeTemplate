# ResumeKit Pro — Complete Project Reference

> **Version:** 1.0.0+1  
> **Last Updated:** 2026-07-05  
> **Purpose:** Single source of truth from basic overview to advanced implementation details.

---

## Table of Contents

1. [Overview](#1-overview)
2. [App Metadata](#2-app-metadata)
3. [Tech Stack Summary](#3-tech-stack-summary)
4. [Project Structure](#4-project-structure)
5. [Entry Point & Bootstrap](#5-entry-point--bootstrap)
6. [Routing & Navigation](#6-routing--navigation)
7. [State Management & DI](#7-state-management--di)
8. [Features](#8-features)
9. [Global Layer](#9-global-layer)
10. [API & Networking](#10-api--networking)
11. [Local Storage](#11-local-storage)
12. [Theme & UI](#12-theme--ui)
13. [Environment & Config](#13-environment--config)
14. [Platform Support](#14-platform-support)
15. [Build & Release](#15-build--release)
16. [Testing](#16-testing)
17. [Security](#17-security)
18. [Related Documents](#18-related-documents)

---

## 1. Overview

| Key | Value |
|-----|-------|
| App Name | ResumeKit Pro |
| Tagline | Create professional resumes and biodata offline |
| Dart Package | template |
| Android Package | com.example.template |
| Type | Production Flutter Application |
| Dart SDK | 3.x |
| Architecture | GetX Feature-Based Clean Architecture |
| State Management | GetX |
| Backend | REST API |
| Target Platforms | Android, iOS, Web |

### Short Description

Build resumes & biodata offline with 100+ templates.

### Long Description

ResumeKit Pro helps you create polished resumes and biodata documents entirely on-device. Choose from 100+ templates, import existing files, and export PDFs — no account required.

---

## 2. App Metadata

See [APP_STORE_METADATA.md](APP_STORE_METADATA.md) for store listing copy, logo specs, tags, and hashtags.

| Field | Value |
|-------|-------|
| Tags | Flutter, GetX, Mobile App, Cross Platform |
| Hashtags | #Flutter #Dart #GetX #MobileApp #CrossPlatform #ResumeKitPro |
| Logo | `assets/images/logo.png` |
| Primary Color | #519755 |

---

## 3. Tech Stack Summary

| Category | Technology |
|----------|------------|
| Framework | Flutter 3.44.1 |
| Language | Dart 3.x |
| Architecture | GetX Feature-Based Clean Architecture |
| State / DI / Routing | GetX |
| HTTP Client | Dio + HTTP |
| Local Persistence | SharedPreferences + Encrypted Storage |
| Env Config | flutter_dotenv |
| Icons / Fonts | Poppins, Material Icons |

Full package list: [TECH_STACK.md](TECH_STACK.md)

---

## 4. Project Structure

```
lib/
├── main.dart
├── controller/
│   ├── initial_binding.dart
│   ├── routes.dart
│   └── theme_controller.dart
├── features/
│   ├── splash/presentation/
│   ├── onboarding/
│   ├── auth/
│   ├── main/
│   ├── home/
│   ├── test_api/
│   ├── profile/
│   ├── settings/
│   ├── legal/
│   ├── help/
│   └── about/
└── global/
    ├── base/
    ├── constant/
    ├── apiutils/
    ├── sp/
    ├── theme/
    ├── utils/
    ├── widgets/
    └── services/
```

### Layer Rules

| Layer | Path | Responsibility |
|-------|------|----------------|
| Controller (app) | `lib/controller/` | Routes, bindings, theme |
| Features | `lib/features/<name>/` | Screens, feature controllers, repos, models |
| Global | `lib/global/` | Shared base classes, utils, theme, widgets |
| Assets | `assets/` | Images, fonts |
| Config | `.env` | API URL, encryption key |

Each feature follows:

```
features/<feature>/
├── controller/
├── data/          # *_repository.dart
├── domain/        # *_model.dart
└── presentation/  # pages + widgets
```

---

## 5. Entry Point & Bootstrap

**File:** `lib/main.dart`

**Startup order (mandatory):**

1. `WidgetsFlutterBinding.ensureInitialized()`
2. `await dotenv.load(fileName: '.env')`
3. `await initSDK()` — SharedPreferences, encryption, platform guards, Firebase (if enabled)
4. `runApp(const App())`

Never call `initSDK()` before `dotenv.load()` when encryption or API helpers read env vars.

---

## 6. Routing & Navigation

**Files:**

- `lib/controller/routes.dart` — `GetPage` definitions
- `lib/global/constant/routers_const.dart` — route name constants

**Flow:**

```
Splash → Onboarding (first launch) → Auth → Main shell (Home / Test API / Profile)
```

Secondary routes: settings, edit profile, legal, help, about.

Web: tab routes sync via `WebUrlHelper`.

---

## 7. State Management & DI

| Component | Pattern |
|-----------|---------|
| App-wide | `InitialBinding` + `Get.put` / `Get.lazyPut` |
| Feature screens | `BaseController` subclasses |
| Theme | `ThemeController` (permanent) |
| Reactive UI | `Obx` / `.obs` on controllers |

**Base classes (mandatory for features):**

- Screens → `BaseStatelessWidget` / `BaseStatefulWidget`
- Controllers → `BaseController`
- Repositories → `BaseRepository`

---

## 8. Features

### Splash & Onboarding
- Branded splash with gradient
- 3-slide onboarding with skip/next

### Authentication
- Login, register, OTP verification
- Responsive split layout on desktop

### Main Shell
- Bottom nav (mobile) / side menu (web)
- Tabs: Home, Test API, Profile

### Settings & Legal
- Dark mode toggle
- Privacy policy, terms, help, about

---

## 9. Global Layer

| Folder | Contents |
|--------|----------|
| `global/base/` | BaseController, BaseRepository, BaseStatelessWidget, … |
| `global/constant/` | API, assets, colors, routes, strings |
| `global/apiutils/` | Dio client, API response wrapper |
| `global/sp/` | SharedPreferences + encrypted storage |
| `global/theme/` | AppTheme, AppTextStyle, ThemeController |
| `global/utils/` | env_helper, platform_helper, widget_helper, validation |
| `global/widgets/` | AppBar, SmartImage, CustomTextField, GradientButton |
| `global/services/` | Encryption, Firebase services (when enabled) |

---

## 10. API & Networking

- **Client:** Dio via `ApiBaseHelper`
- **Base URL:** `API_BASE_URL` from `.env` (via `envOr()`)
- **Patterns:** `apiHandler()` for loading / error / empty / offline states
- **Demo:** `test_api` feature — GET/POST jsonplaceholder

---

## 11. Local Storage

| Store | Use |
|-------|-----|
| SharedPreferences | Theme, onboarding flag, user session |
| Encrypted SP | Sensitive tokens (AES via `EncryptionService`) |
| Cache | `cached_network_image` + `flutter_cache_manager` |

---

## 12. Theme & UI

- **Font:** Poppins via `AppTextStyle`
- **Standard sizes:** 14px body, 12px captions, 16–18px headers, 20–32px hero
- **App bar:** Primary color background, white title/icons
- **Dark mode:** `ThemeController` + settings toggle
- **Responsive:** `ResponsiveLayout` / `ResponsiveBuilder` for web & tablet
- **Images:** `SmartImageWidget` only
- **Loading:** Shimmer placeholders

---

## 13. Environment & Config

See [ENVIRONMENT.md](ENVIRONMENT.md).

---

## 14. Platform Support

| Platform | Notes |
|----------|-------|
| Android | Full support; manifest permissions in `AndroidManifest.xml` |
| iOS | Full support; guard mobile-only plugins |
| Web | Branded `web/index.html` loader; URL sync for tabs |

Use `PlatformHelper` for mobile-only plugins (`no_screenshot`, `permission_handler`, etc.).

---

## 15. Build & Release

See [SETUP.md](SETUP.md).

```bash
flutter pub get
dart run flutter_launcher_icons
flutter build apk --release
flutter build ios
flutter build web
```

---

## 16. Testing

```bash
flutter test
flutter analyze
```

Add widget tests under `test/` for critical flows.

---

## 17. Security

- `.env` never committed (use `.gitignore`)
- `envOr()` for all env reads
- Encrypted storage for sensitive data
- `no_screenshot` on mobile (optional)
- HTTPS for API calls

---

## 18. Related Documents

| Document | Description |
|----------|-------------|
| [APP_STORE_METADATA.md](APP_STORE_METADATA.md) | Store listing metadata |
| [ARCHITECTURE.md](ARCHITECTURE.md) | Deep architecture notes |
| [FEATURES.md](FEATURES.md) | Feature checklist |
| [SETUP.md](SETUP.md) | Setup and build guide |
| [TECH_STACK.md](TECH_STACK.md) | All dependencies |
| [ENVIRONMENT.md](ENVIRONMENT.md) | Env variables |
| [CODING_STANDARDS.md](CODING_STANDARDS.md) | Code conventions |
| [ROADMAP.md](ROADMAP.md) | Future work |
