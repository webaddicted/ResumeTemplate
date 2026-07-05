# Features — ResumeKit Pro

---

## Core Features

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

## Feature Matrix

| Feature | Route | Tab / Push | Status |
|---------|-------|------------|--------|
| Splash | `/` | Auto | ✅ |
| Onboarding | `/onboarding` | First launch | ✅ |
| Login | `/login` | Auth gate | ✅ |
| Register | `/register` | Auth | ✅ |
| OTP | `/otp` | Auth | ✅ |
| Main Shell | `/main` | Post-auth | ✅ |
| Home | Tab 0 | In shell | ✅ |
| Test API | Tab 1 | In shell | ✅ |
| Profile | Tab 2 | In shell | ✅ |
| Edit Profile | `/edit-profile` | Push | ✅ |
| Settings | `/settings` | Push | ✅ |
| Privacy Policy | `/privacy` | Push | ✅ |
| Terms | `/terms` | Push | ✅ |
| Help & Support | `/help` | Push | ✅ |
| About | `/about` | Push | ✅ |

---

## Cross-Cutting

| Capability | Implementation |
|------------|----------------|
| Dark mode | `ThemeController` + Settings |
| Offline detection | `connectivity_plus` + `noInternetUI()` |
| Shimmer loading | `shimmer` + `widget_helper` |
| Image cache | `SmartImageWidget` + `cached_network_image` |
| Encrypted prefs | `EncryptedSpHelper` |
| Debug form fill | `DummyHelper` in `kDebugMode` |
| Responsive UI | `ResponsiveLayout` |
| Web URL sync | `WebUrlHelper` |

---

## Optional / Roadmap

See [ROADMAP.md](ROADMAP.md).
