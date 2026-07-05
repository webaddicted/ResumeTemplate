# aaresumeTemplate — Coding Guidelines

<!-- AUTO-GENERATED:guidelines -->
## Conventions detected

- **Files:** snake_case `.dart` filenames
- **Classes:** UpperCamelCase
- **Members:** lowerCamelCase
- **Features:** `lib/features/<feature>/{controller,data,domain,presentation}` when using scaffold architecture
- **Routing:** central `lib/controller/routes.dart` + `routers_const.dart`

## Error handling

- Use shared helpers (`apiHandler`, snackbars) when present in `widget_helper.dart`
- Firebase init often wrapped in try/catch in `main.dart`

## Logging

- Look for `printLog`, `logger`, or `debugPrint` utilities in global utils
<!-- END AUTO-GENERATED:guidelines -->
