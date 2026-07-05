# aaresumeTemplate — Folder Structure

<!-- AUTO-GENERATED:folders -->
### `android/`
- **Purpose:** Android native project and Gradle build
- **Files:** 7
  - `android/local.properties`
  - `android/gradlew`
  - `android/build.gradle.kts`
  - `android/template_android.iml`
  - `android/settings.gradle.kts`
  - `android/gradle.properties`
  - `android/gradlew.bat`

### `android/app/`
- **Purpose:** app/ module
- **Files:** 1
  - `android/app/build.gradle.kts`

### `android/app/src/debug/`
- **Purpose:** debug/ module
- **Files:** 1
  - `android/app/src/debug/AndroidManifest.xml`

### `android/app/src/main/`
- **Purpose:** main/ module
- **Files:** 1
  - `android/app/src/main/AndroidManifest.xml`

### `android/app/src/main/java/io/flutter/plugins/`
- **Purpose:** plugins/ module
- **Files:** 1
  - `android/app/src/main/java/io/flutter/plugins/GeneratedPluginRegistrant.java`

### `android/app/src/main/kotlin/com/webaddicted/template/`
- **Purpose:** template/ module
- **Files:** 1
  - `android/app/src/main/kotlin/com/webaddicted/template/MainActivity.kt`

### `android/app/src/main/res/drawable/`
- **Purpose:** drawable/ module
- **Files:** 1
  - `android/app/src/main/res/drawable/launch_background.xml`

### `android/app/src/main/res/drawable-v21/`
- **Purpose:** drawable-v21/ module
- **Files:** 1
  - `android/app/src/main/res/drawable-v21/launch_background.xml`

### `android/app/src/main/res/values/`
- **Purpose:** values/ module
- **Files:** 1
  - `android/app/src/main/res/values/styles.xml`

### `android/app/src/main/res/values-night/`
- **Purpose:** values-night/ module
- **Files:** 1
  - `android/app/src/main/res/values-night/styles.xml`

### `android/app/src/profile/`
- **Purpose:** profile/ module
- **Files:** 1
  - `android/app/src/profile/AndroidManifest.xml`

### `android/gradle/wrapper/`
- **Purpose:** wrapper/ module
- **Files:** 1
  - `android/gradle/wrapper/gradle-wrapper.properties`

### `assets/fonts/`
- **Purpose:** fonts/ module
- **Files:** 8
  - `assets/fonts/Nunito-Medium.ttf`
  - `assets/fonts/Nunito-ExtraBold.ttf`
  - `assets/fonts/Nunito-Light.ttf`
  - `assets/fonts/Nunito-Regular.ttf`
  - `assets/fonts/Nunito-SemiBold.ttf`
  - `assets/fonts/Nunito-Bold.ttf`
  - `assets/fonts/Nunito-Black.ttf`
  - `assets/fonts/Nunito-ExtraLight.ttf`

### `doc/`
- **Purpose:** Project documentation
- **Files:** 4
  - `doc/ARCHITECTURE.md`
  - `doc/CARD_TEMPLATES.md`
  - `doc/ATS_AI_V2.md`
  - `doc/FEATURES.md`

### `lib/`
- **Purpose:** Dart application source
- **Files:** 1
  - `lib/main.dart`

### `lib/controller/`
- **Purpose:** App-wide routing, bindings, controllers
- **Files:** 3
  - `lib/controller/theme_controller.dart`
  - `lib/controller/initial_binding.dart`
  - `lib/controller/routes.dart`

### `lib/core/ai/`
- **Purpose:** ai/ module
- **Files:** 1
  - `lib/core/ai/ai_enhancement_service.dart`

### `lib/core/ats/`
- **Purpose:** ats/ module
- **Files:** 1
  - `lib/core/ats/ats_analyzer_service.dart`

### `lib/core/constants/`
- **Purpose:** constants/ module
- **Files:** 1
  - `lib/core/constants/ats_keywords.dart`

### `lib/core/jd/`
- **Purpose:** jd/ module
- **Files:** 1
  - `lib/core/jd/jd_analyzer_service.dart`

### `lib/features/ats_analysis/presentation/`
- **Purpose:** Screens, pages, and feature UI
- **Files:** 1
  - `lib/features/ats_analysis/presentation/ats_analysis_page.dart`

### `lib/features/biodata/presentation/`
- **Purpose:** Screens, pages, and feature UI
- **Files:** 3
  - `lib/features/biodata/presentation/biodata_picker_page.dart`
  - `lib/features/biodata/presentation/biodata_preview_page.dart`
  - `lib/features/biodata/presentation/biodata_form_page.dart`

### `lib/features/cards/presentation/`
- **Purpose:** Screens, pages, and feature UI
- **Files:** 4
  - `lib/features/cards/presentation/card_form_page.dart`
  - `lib/features/cards/presentation/card_picker_page.dart`
  - `lib/features/cards/presentation/card_preview_page.dart`
  - `lib/features/cards/presentation/categories_page.dart`

### `lib/features/final_validation/presentation/`
- **Purpose:** Screens, pages, and feature UI
- **Files:** 1
  - `lib/features/final_validation/presentation/final_ats_validation_page.dart`

### `lib/features/home/presentation/`
- **Purpose:** Screens, pages, and feature UI
- **Files:** 1
  - `lib/features/home/presentation/home_page.dart`

### `lib/features/jd_optimizer/presentation/`
- **Purpose:** Screens, pages, and feature UI
- **Files:** 1
  - `lib/features/jd_optimizer/presentation/jd_optimizer_page.dart`

### `lib/features/resume/presentation/`
- **Purpose:** Screens, pages, and feature UI
- **Files:** 3
  - `lib/features/resume/presentation/template_picker_page.dart`
  - `lib/features/resume/presentation/resume_preview_page.dart`
  - `lib/features/resume/presentation/form_steps_page.dart`

### `lib/global/constant/`
- **Purpose:** constant/ module
- **Files:** 3
  - `lib/global/constant/routers_const.dart`
  - `lib/global/constant/card_categories.dart`
  - `lib/global/constant/app_constant.dart`

### `lib/global/theme/`
- **Purpose:** theme/ module
- **Files:** 1
  - `lib/global/theme/app_theme.dart`

### `lib/global/utils/`
- **Purpose:** Shared utilities and helpers
- **Files:** 4
  - `lib/global/utils/file_import.dart`
  - `lib/global/utils/card_pdf_generator.dart`
  - `lib/global/utils/pdf_generator.dart`
  - `lib/global/utils/biodata_pdf_generator.dart`

### `lib/global/widgets/`
- **Purpose:** widgets/ module
- **Files:** 4
  - `lib/global/widgets/ai_suggestion_card.dart`
  - `lib/global/widgets/form_widgets.dart`
  - `lib/global/widgets/template_card.dart`
  - `lib/global/widgets/ats_widgets.dart`

### `lib/global/widgets/templates/`
- **Purpose:** templates/ module
- **Files:** 6
  - `lib/global/widgets/templates/card_renderers.dart`
  - `lib/global/widgets/templates/card_template_specs.dart`
  - `lib/global/widgets/templates/biodata_templates.dart`
  - `lib/global/widgets/templates/all_templates.dart`
  - `lib/global/widgets/templates/template_base.dart`
  - `lib/global/widgets/templates/resume_template_specs.dart`

### `lib/model/`
- **Purpose:** model/ module
- **Files:** 6
  - `lib/model/biodata_data.dart`
  - `lib/model/card_data.dart`
  - `lib/model/ai_suggestion.dart`
  - `lib/model/resume_data.dart`
  - `lib/model/jd_analysis.dart`
  - `lib/model/ats_report.dart`

### `test/`
- **Purpose:** Automated tests
- **Files:** 7
  - `test/ats_v2_test.dart`
  - `test/photo_test.dart`
  - `test/templates_test.dart`
  - `test/widget_test.dart`
  - `test/import_test.dart`
  - `test/cards_test.dart`
  - `test/ats_screens_test.dart`

### `web/`
- **Purpose:** Flutter web host and assets
- **Files:** 2
  - `web/index.html`
  - `web/manifest.json`
<!-- END AUTO-GENERATED:folders -->
