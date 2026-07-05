# Coding Standards — ResumeKit Pro

---

## Architecture

- GetX feature-based layout: `controller/`, `features/`, `global/`
- Each feature: `controller/`, `data/`, `domain/`, `presentation/`
- Extend base classes — no raw `StatelessWidget` / `GetxController` on routes

---

## Naming Conventions

| Type | Convention | Example |
|------|------------|---------|
| Variable | lowerCamelCase | `userName` |
| Function | lowerCamelCase | `getUserData()` |
| Class | UpperCamelCase | `UserProfile` |
| File | snake_case | `user_profile.dart` |
| Folder | snake_case | `user_profile/` |

---

## SOLID & Clean Code

- Single responsibility per class
- Repositories for data access only
- Controllers for UI state and actions
- Models in `domain/` — no raw `Map` for API responses

---

## UI Standards

| Rule | Detail |
|------|--------|
| Typography | `AppTextStyle` only — 14px body, 12px captions |
| Images | `SmartImageWidget` only |
| App bar | Primary color + white text via `AppBarWidget` |
| Loading | Shimmer while fetching |
| Snackbars | `showSuccessSnackbar` / `showErrorSnackbar` |

---

## Linting

```bash
flutter analyze   # zero errors required
dart fix --apply
```

Uses `flutter_lints` from `analysis_options.yaml`.

---

## Git Workflow

1. Feature branch from `main`
2. Small focused commits
3. PR with description and test plan
4. No secrets in commits

---

## Documentation

- Update `README.md` when adding major features
- Update `doc/` when architecture or env changes
- Keep [APP_STORE_METADATA.md](APP_STORE_METADATA.md) in sync for releases
