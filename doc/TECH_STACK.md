# Tech Stack — ResumeKit Pro

> Auto-generated from `pubspec.yaml`. Re-run doc generation after dependency changes.

---

## Environment

| Key | Value |
|-----|-------|
| Dart SDK | 3.x |
| Flutter | 3.44.1 |
| App Version | 1.0.0+1 |

---

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `cupertino_icons` | App dependency |
| `get` | State management, routing, DI |
| `dio` | HTTP client |
| `connectivity_plus` | Network connectivity |
| `shared_preferences` | Local key-value storage |
| `cached_network_image` | Image caching |
| `flutter_cache_manager` | App dependency |
| `image_picker` | Camera/gallery picker |
| `flutter_image_compress` | App dependency |
| `shimmer` | Loading placeholders |
| `device_info_plus` | App dependency |
| `package_info_plus` | App dependency |
| `permission_handler` | Runtime permissions |
| `pdf` | App dependency |
| `printing` | App dependency |
| `url_launcher` | Open URLs |
| `share_plus` | System share sheet |
| `path_provider` | App dependency |
| `intl` | Date/number formatting |
| `logger` | Structured logging |
| `flutter_dotenv` | Environment variables |
| `responsive_framework` | App dependency |
| `file_picker` | App dependency |
| `syncfusion_flutter_pdf` | App dependency |
| `archive` | App dependency |
| `image` | App dependency |

---

## Architecture Choices

| Category | Choice |
|----------|--------|
| Architecture | GetX Feature-Based Clean Architecture |
| State Management | GetX |
| Networking | Dio + HTTP |
| Local Storage | SharedPreferences + Encrypted Storage |
| Backend | REST API |
| Routing | GetX Named Routes |
| DI | GetX Bindings |

---

## Dev Dependencies

| Package | Purpose |
|---------|---------|
| flutter_test | Unit & widget tests |
| flutter_lints | Static analysis rules |

---

## Platform Plugins Requiring Guards

| Plugin | Guard |
|--------|-------|
| no_screenshot | `PlatformHelper.isMobile` |
| permission_handler | `PlatformHelper.isMobile` |
| image_picker | `PlatformHelper.isMobile` |
| firebase_crashlytics | `PlatformHelper.isMobile` |

See `global/utils/platform_helper.dart`.
