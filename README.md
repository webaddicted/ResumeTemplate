# 🚀 ResumeKit Pro

> Create professional resumes and biodata offline

<p align="center">
  <img src="assets/images/logo.png" alt="ResumeKit Pro logo" width="120">
</p>

[![Flutter](https://img.shields.io/badge/Flutter-3.44.1-blue.svg)]()
[![Dart](https://img.shields.io/badge/Dart-3.x-blue.svg)]()
[![License](https://img.shields.io/badge/License-MIT-green.svg)]()
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-lightgrey.svg)]()

**Tags:** Flutter, GetX, Resume, PDF, Biodata

**Hashtags:** #Flutter #Dart #GetX #Resume #Biodata #ResumeKitPro

---

## 📱 Screenshots

| Home | Profile | Settings |
|------|----------|----------|
| <img src="screenshots/home.png" width="250" alt="Home"> | <img src="screenshots/profile.png" width="250" alt="Profile"> | <img src="screenshots/settings.png" width="250" alt="Settings"> |

> Add screenshots under `screenshots/` and update paths above.

---

## ✨ Features

- ✅ Resume builder with multi-step form and 100+ templates
- ✅ ATS analysis and keyword scoring (on-device)
- ✅ JD optimizer — gap analysis against job descriptions
- ✅ Marriage biodata builder with templates
- ✅ Cards — invitations, business cards, event passes, profiles
- ✅ PDF export and share
- ✅ Import existing resume files (PDF/DOCX)
- ✅ Encrypted local storage
- ✅ Responsive layout (mobile + web)

---

## 📂 Project Structure

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
    ├── services/
    ├── sp/
    ├── theme/
    ├── utils/
    └── widgets/
```

---

## 🛠 Tech Stack

| Category | Technology |
|----------|------------|
| Framework | Flutter |
| Language | Dart |
| Architecture | GetX Feature-Based Clean Architecture |
| State Management | GetX |
| Networking | Dio + HTTP |
| Local Database | SharedPreferences + Encrypted Storage |
| Backend | On-device (no Firebase) |
| Dependency Injection | GetX Bindings |
| Routing | GetX Named Routes |
| CI/CD | GitHub Actions (optional) |

---

## 📦 Packages Used

| Package | Purpose |
|----------|----------|
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

## 🚀 Getting Started

### Clone Repository

```bash
git clone https://github.com/username/{{PACKAGE}.git}
cd template
```

### Install Packages

```bash
flutter pub get
```

### Run

```bash
flutter run
```

---

## 🔥 Build APK

```bash
flutter build apk --release
```

---

## 🍎 Build iOS

```bash
flutter build ios
```

---

## 🧪 Run Tests

```bash
flutter test
```

---

## 📷 App Demo

![Demo](demo/demo.gif)

> Add `demo/demo.gif` when available.

---

## 🌍 Environment

Create `.env` in the project root:

```
API_BASE_URL=
ENCRYPTION_KEY=

```

See [doc/ENVIRONMENT.md](doc/ENVIRONMENT.md) for full configuration.

---

## ⚙️ Flavor

```
dev
qa
staging
production
```

Run:

```bash
flutter run --flavor dev
```

---

## 📊 Architecture

```
Presentation (features/*/presentation)
      │
Controller (GetX + BaseController)
      │
Data / Domain (repository + models)
      │
Remote API / Local Storage
```

See [doc/ARCHITECTURE.md](doc/ARCHITECTURE.md) for details.

---

## 🔐 Permissions

**Android**

- Internet
- Network state
- Post notifications
- Storage (when required)

**iOS**

- Camera (when required)
- Photos (when required)
- Notifications (when required)

---

## 📌 Roadmap

- [x] Project scaffold
- [x] Authentication flow
- [x] Main shell navigation
- [x] API integration demo
- [ ] Offline sync
- [ ] AI features
- [ ] Web polish

See [doc/ROADMAP.md](doc/ROADMAP.md).

---

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Open a Pull Request

---

## 📝 Coding Standards

- GetX feature-based architecture
- SOLID principles
- Feature-first folder structure
- Dart lints (`flutter_lints`)
- Null safety
- Documentation in `doc/`
- Unit tests for business logic

See [doc/CODING_STANDARDS.md](doc/CODING_STANDARDS.md).

---

## 📄 License

MIT License

---

## 👨‍💻 Author

**Deepak Sharma**

- LinkedIn: 
- GitHub: 
- Email: deepaksharma040695@gmail.com

---

## 📚 Documentation

| Document | Description |
|----------|-------------|
| [PROJECT_INFO.md](doc/PROJECT_INFO.md) | Complete project reference (basic → advanced) |
| [APP_STORE_METADATA.md](doc/APP_STORE_METADATA.md) | Store listing: title, logo, descriptions, tags |
| [ARCHITECTURE.md](doc/ARCHITECTURE.md) | Architecture and folder layout |
| [SETUP.md](doc/SETUP.md) | Setup, build, and deployment |
| [TECH_STACK.md](doc/TECH_STACK.md) | Dependencies and versions |
| [ENVIRONMENT.md](doc/ENVIRONMENT.md) | Env vars and secrets |
| [CODING_STANDARDS.md](doc/CODING_STANDARDS.md) | Code style and conventions |
| [ROADMAP.md](doc/ROADMAP.md) | Planned features |
