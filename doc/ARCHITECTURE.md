# Architecture — ResumeKit Pro

This document describes how the app is structured, how data and navigation
flow, how the template engine works, and the key engineering decisions behind
it.

---

## 1. Overview

ResumeKit Pro is a single Flutter codebase targeting **Android** and **Web**.
It is **offline-first**: all document creation, rendering, file import, and PDF
export happen on-device with no backend.

The app shell uses **GetX** (`GetMaterialApp`, bindings, named routes). Inside
each feature, screens use plain Flutter `StatefulWidget` + `setState` over a
mutable data model — GetX is intentionally **not** used for per-field form
state, only for app-level wiring (routing, theme, DI).

The defining design principle is **separation of content from presentation**:
one data object (`ResumeData` / `BiodataData`) can be rendered by any of the
100 templates, so switching templates never loses data.

## 2. Layered, feature-first structure

```
lib/
├── main.dart                       # composition root (GetMaterialApp)
│
├── controller/                     # ── App shell (GetX) ──
│   ├── routes.dart                 # GetPage table; reads Get.arguments → data
│   ├── initial_binding.dart        # Get.lazyPut(ThemeController, fenix:true)
│   └── theme_controller.dart       # dark theme + system UI overlay
│
├── features/                       # ── Presentation, grouped by feature ──
│   ├── home/presentation/
│   │   └── home_page.dart          # type selector + optional file import
│   ├── resume/presentation/
│   │   ├── template_picker_page.dart
│   │   ├── form_steps_page.dart    # 6-step wizard
│   │   └── resume_preview_page.dart
│   └── biodata/presentation/
│       ├── biodata_picker_page.dart
│       ├── biodata_form_page.dart  # 4-step wizard
│       └── biodata_preview_page.dart
│
├── global/                         # ── Cross-feature shared code ──
│   ├── constant/
│   │   ├── app_constant.dart       # name, tagline, version, storage prefix
│   │   └── routers_const.dart      # route name constants
│   ├── theme/
│   │   └── app_theme.dart          # ThemeData + TemplateInfo + catalogues
│   ├── utils/
│   │   ├── pdf_generator.dart      # resume PDF + shared pdfTheme()/decodablePhoto()
│   │   ├── biodata_pdf_generator.dart
│   │   └── file_import.dart        # PDF/DOCX text extraction + heuristic parsers
│   └── widgets/
│       ├── form_widgets.dart       # FormField2, StepIndicator, PhotoPickerField, …
│       ├── template_card.dart      # picker card + MiniPreview (hint-driven)
│       └── templates/
│           ├── template_base.dart        # TemplateStyle + shared blocks + ResumePhoto
│           ├── all_templates.dart        # 10 hand-crafted resume templates + dispatcher
│           ├── resume_template_specs.dart# 40 generated specs + GenericResumeTemplate
│           └── biodata_templates.dart    # 50 specs + GenericBiodataTemplate
│
└── model/                          # ── Data ──
    ├── resume_data.dart            # ResumeData + sub-models + sample()
    └── biodata_data.dart           # BiodataData + sample()
```

**Dependency direction:** `features/ → global/ → model/`. Features never
import each other; shared rendering/util/widget code lives in `global/`; the
`model/` layer depends on nothing app-specific.

## 3. Composition root & routing

`main.dart` builds a `GetMaterialApp`:

```dart
GetMaterialApp(
  title: AppConstant.appName,
  theme: AppTheme.dark(),
  initialBinding: InitialBinding(),
  initialRoute: RoutersConst.initialRoute,   // '/home'
  getPages: routes(),
)
```

Routes are declared in `controller/routes.dart`. Because the app carries a
**mutable working document** between screens, routes read `Get.arguments` and
pass the typed model into each page (falling back to a fresh instance):

| Route constant | Path | Page | Argument |
|---|---|---|---|
| `home` | `/home` | `HomePage` | — |
| `resumeTemplatePicker` | `/resume/templates` | `TemplatePickerPage` | `ResumeData?` (pre-filled from import) |
| `resumeForm` | `/resume/form` | `FormStepsPage` | `ResumeData` |
| `resumePreview` | `/resume/preview` | `ResumePreviewPage` | `ResumeData` |
| `biodataTemplatePicker` | `/biodata/templates` | `BiodataPickerPage` | `BiodataData?` |
| `biodataForm` | `/biodata/form` | `BiodataFormPage` | `BiodataData` |
| `biodataPreview` | `/biodata/preview` | `BiodataPreviewPage` | `BiodataData` |

`InitialBinding` lazily provides `ThemeController` (`fenix: true` so it
survives route disposal). The app ships a single dark theme today; the
controller leaves room for a light theme later.

## 4. State management strategy

- **App level (GetX):** routing, theme, dependency injection.
- **Screen level (`setState`):** the form wizards mutate a single
  `ResumeData`/`BiodataData` instance and call `setState` to re-render. The
  same instance is forwarded to preview and PDF export.

Why not GetX/Provider for form state? The working document is a linear,
short-lived, single-owner object passed down the navigation stack. A plain
mutable model + `setState` is the lowest-ceremony approach and keeps the
template renderers pure (`(data) → widget`). Persistence is **in-memory only**
in v1.0 (see Roadmap).

### Data flow

```
HomePage
  │  builds empty ResumeData/BiodataData
  │  (optional) FileImport.parse*(extractText(file)) → pre-filled model
  ▼
PickerPage(initial)         sets model.templateId
  ▼
FormPage(data)              mutates fields in place (setState)
  ▼
PreviewPage(data)           buildTemplate(id, data)  → live widget tree
  ▼
PdfGenerator.generate(data) → Uint8List  → printing / share_plus
```

## 5. The template engine

The headline requirement — *switch among 100 designs without re-typing* — is
met by rendering the **same data** through interchangeable, **pure** template
widgets.

### 5.1 Shared rendering primitives (`template_base.dart`)

- **`TemplateStyle`** — a value object describing one template's look:
  background, accent, ink colours, and flags (`serifHeadings`, `mono`,
  `sectionTitleBoxed`, `sectionRuleFull`, `diamondRule`, …). All text styles
  resolve through it, always using the bundled **Nunito** family.
- **Shared content blocks** — `StandardBody`, `ExpBlock`, `ProjBlock`,
  `EduBlock`, `SkillsTable`, `ChipsWrap`, `ContactWrap`, `TailSections`,
  `ResumeSection`, `SectionTitle`, and `ResumePhoto`. Written once, reused by
  every template. `ResumeSection` renders nothing when its data is empty —
  this is how **empty-section hiding** is implemented uniformly.

### 5.2 Resume templates (50 = 10 + 40)

- **10 hand-crafted** widgets in `all_templates.dart` (the PRD catalogue:
  `modern_dark`, `clean_minimal`, `corporate`, `creative_side`, `bold_yellow`,
  `teal_elegant`, `two_column`, `tech_mono`, `executive`, `gradient`).
- **40 generated** from `ResumeTemplateSpec` in `resume_template_specs.dart`:
  **8 palettes** (Sapphire, Emerald, Crimson, Violet, Amber, Slate, Lagoon,
  Rosewood) × **5 header variants** (`band`, `edge`, `classic`, `line`,
  `flow`). One `GenericResumeTemplate` renders all 40 by selecting a header
  layout and reusing `StandardBody`.

Dispatch is centralized:

```dart
Widget buildTemplate(String templateId, ResumeData data) {
  final spec = resumeSpecById[templateId];
  if (spec != null) return GenericResumeTemplate(spec: spec, data: data);
  return switch (templateId) { /* 10 hand-crafted ids */ };
}
```

### 5.3 Biodata templates (50)

`BiodataTemplateSpec` in `biodata_templates.dart`: **10 palettes** (Maroon,
Royal Blue, Saffron, Emerald, Royal Purple, Peacock, Antique Gold, Coral,
Burgundy, Rose Pink) × **5 frame styles** (`heritage` double-line, `classic`
single border, `regal` corner brackets, `banner` header band, `simple`). A
single `GenericBiodataTemplate` renders a centered header (invocation +
initials/photo medallion) and key-value sections, hiding empty rows.

### 5.4 Catalogues (`app_theme.dart`)

`AppTheme.templates` (50) and `AppTheme.biodataTemplates` (50) expose
`TemplateInfo` entries (id, name, colours, `TemplateHint`). `TemplateHint`
drives the abstract **miniature preview** drawn on each picker card by
`MiniPreview`, so all 100 entries get a representative thumbnail without
rendering a full template.

### 5.5 Why spec-driven generation

Hand-writing 100 template widgets would be unmaintainable. Encoding the
variation as *(palette × layout)* data means a new palette adds 5 resume
designs (or 5 biodata designs) in a few lines, and shared blocks guarantee
consistent behaviour (spacing, empty-hiding, photo placement) across all of
them.

## 6. PDF export

Two generators (`pdf_generator.dart`, `biodata_pdf_generator.dart`) build A4
documents with the `pdf` package, tinted by the selected template's accent
colour. They are **separate from the on-screen templates**: the PDF is a clean,
standardized A4 layout rather than a pixel-faithful copy of the widget tree.

Shared helpers live in `pdf_generator.dart`:

- **`pdfTheme()`** — loads and caches the bundled **Nunito** TTFs as the PDF
  base font. Required because the `pdf` default (Helvetica) cannot draw glyphs
  like `–` and `₹`.
- **`decodablePhoto(bytes)`** — validates image bytes with `package:image`
  before embedding; undecodable photos are skipped so export never crashes.

Output is `Uint8List`, handed to `printing` (print / save dialog) or
`share_plus` (native share). Filenames: `<Name>_resume.pdf`,
`<Name>_biodata.pdf`.

## 7. File import pipeline (`file_import.dart`)

Optional auto-fill, fully on-device:

```
pick (file_picker, pdf/docx, withData:true)
   │
   ├─ PDF  → syncfusion_flutter_pdf: extractTextLines().map(.text).join('\n')
   └─ DOCX → archive: unzip word/document.xml, regex <w:t> runs, </w:p> = newline
   │
   ▼
parseResume(text)   regex: email/phone/linkedin/github;
                    heuristics: name, job title, summary, skills
parseBiodata(text)  maps ~50 "Label : value" aliases + regex + name fallback
   │
   ▼
pre-filled ResumeData / BiodataData  → handed to the picker route
```

Corrupt or unreadable files degrade to a blank model (never throw); the home
screen surfaces an "auto-filled N fields" toast.

## 8. Responsiveness

- Template picker grids: **2 / 3 / 4 / 5** columns at 600 / 900 / 1200 px.
- Two-pane templates (`creative_side`, `two_column`) **stack vertically**
  below 480 dp.
- Resume preview width capped at **680 dp**; form content capped at **560 dp**.
- Home screen mode cards sit side-by-side ≥ 700 px, stacked below.

## 9. Key engineering decisions

| Decision | Rationale |
|---|---|
| Bundled **Nunito**, no `google_fonts` | Offline reliability; consistent app/PDF typography; avoids runtime font fetches. |
| Pure, data-driven template widgets | Enables loss-less template switching and trivial PDF/preview parity of *data*. |
| Spec-driven template generation | 100 designs from a few palette/layout specs; consistent shared behaviour. |
| Separate PDF layout (not widget-to-PDF) | Predictable, paginated A4 output; avoids fragile screenshot/rasterization. |
| `setState` for form state | Simplest fit for a single-owner, linear working document. |
| `file_picker` pinned to ^10.3.10 | v11 needs AGP 9 built-in Kotlin, disabled in this project's Gradle config. |
| In-memory persistence (v1.0) | Matches PRD scope; save/restore deferred to v1.1. |

See [`FEATURES.md`](FEATURES.md) for the feature-level catalogue and the data
model, and [`../PROJECT_CONTEXT.md`](../PROJECT_CONTEXT.md) for build-session
gotchas.
