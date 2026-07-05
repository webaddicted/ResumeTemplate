# ResumeKit Pro

> Professional resumes & marriage biodata — built, previewed, and exported as
> PDF entirely on your device.

ResumeKit Pro is a cross-platform **Flutter** app (Android + Web, fully
responsive) that lets you create polished **resumes** and **marriage biodatas**
in minutes. Pick from **50 resume templates** and **50 biodata designs**, switch
between them at any time **without re-entering your data**, optionally **auto-fill
from an existing PDF/DOCX**, add a **profile photo**, and export a print-ready PDF
— no servers, no sign-in, no internet required.

---

## ✨ Highlights

- **100 templates** — 50 resume + 50 biodata, switchable with zero data loss.
- **Content / presentation decoupled** — type once, render in any template.
- **Auto-fill from a file** — import a PDF or DOCX and the form pre-fills
  (optional; you can always type everything by hand).
- **Profile photo** — pick from gallery; shown in templates and exported PDFs.
- **On-device PDF export** — print, save, or share. Works offline.
- **Empty sections auto-hide** — both on screen and in the PDF.
- **Responsive** — phones, tablets, and web; 2–5 column template grids.
- **Offline-first & private** — all data stays on the device.

## 🚀 Getting Started

```bash
flutter pub get

# Run
flutter run -d chrome      # Web
flutter run                # Android device/emulator

# Build
flutter build web --release
flutter build apk --debug

# Verify
flutter analyze
flutter test
```

> **Note:** `pubspec.yaml` declares a `.env` asset — keep an (even empty) `.env`
> file at the project root or builds will warn/fail.

## 🧭 User Flow

```
Home  ──▶  pick type (Resume | Marriage Biodata)
       │   + optional: attach a PDF / DOCX to auto-fill
       ▼
Template Picker  (50 designs, "⚡ Load Sample" for a quick demo)
       ▼
Form Wizard  (Resume: 6 steps · Biodata: 4 steps · photo picker in step 1)
       ▼
Live Preview  (switch templates instantly · Edit)
       ▼
Export PDF   (Print / Save · Share)
```

## 🧱 Tech Stack

| Concern | Package |
|---|---|
| Framework | Flutter (Dart 3) |
| App shell / routing | `get` (GetMaterialApp, bindings, routes) |
| PDF generation & print/share | `pdf`, `printing`, `share_plus` |
| File import | `file_picker` **(pinned ^10.3.10)**, `syncfusion_flutter_pdf` (PDF text), `archive` (DOCX) |
| Profile photo | `image_picker`, `image` (byte validation) |
| Typography | Bundled **Nunito** font (offline; no `google_fonts`) |

## 📁 Project Structure (GetX feature-first)

```
lib/
├── main.dart                 # GetMaterialApp + InitialBinding + routes
├── controller/               # routes, bindings, theme controller
├── features/
│   ├── home/                 # type selector + file import
│   ├── resume/               # picker · 6-step form · preview
│   └── biodata/              # picker · 4-step form · preview
├── global/
│   ├── constant/             # app + route constants
│   ├── theme/                # dark theme + template catalogues
│   ├── utils/                # PDF generators · file import/parse
│   └── widgets/              # form widgets · template engine
└── model/                    # ResumeData · BiodataData
```

## 🤖 V2 — ATS Score, AI Enhancement & JD Optimization

Uploaded resumes now flow through an **ATS analysis** screen (score + fixable
issues), an **AI Assist** workflow in the form (Accept / Edit / Dismiss
suggestions for summary, bullets, skills, certs), **Job-Description
optimization** (keyword gap + suggested additions), and a **final validation
gate** that unlocks download only at **ATS ≥ 90**. The ATS/JD engines are
deterministic and on-device; AI runs through a pluggable engine
(`AiEnhancement.instance`) with an offline default and a one-line seam for a
hosted LLM. See [`doc/ATS_AI_V2.md`](doc/ATS_AI_V2.md).

## 📚 Documentation

- [`doc/ARCHITECTURE.md`](doc/ARCHITECTURE.md) — layered structure, routing,
  the template engine, data flow, and key engineering decisions.
- [`doc/FEATURES.md`](doc/FEATURES.md) — full feature breakdown, template
  catalogues, the import pipeline, and the form/section model.
- [`doc/ATS_AI_V2.md`](doc/ATS_AI_V2.md) — ATS scoring, AI enhancement, JD
  optimization, and the 90+ download gate.
- [`doc/CARD_TEMPLATES.md`](doc/CARD_TEMPLATES.md) — invitations, business
  cards, event passes, and profiles (850 card designs).
- [`PROJECT_CONTEXT.md`](PROJECT_CONTEXT.md) — build-session context & gotchas.

## 🗂️ Document types

Resume (50) · Marriage Biodata (50) · plus **17 card types × 50 designs**
(invitations — marriage, engagement, save-the-date, wedding program, funeral;
events — birthday, anniversary, baby shower, housewarming, retirement,
farewell, event pass; business & visiting cards; personal, student & social
profiles). **950 designs total**, all switchable without re-entering data.
See [`doc/CARD_TEMPLATES.md`](doc/CARD_TEMPLATES.md).

## ✅ Status

Analyzer clean · **174 tests passing** · web + Android builds green.

Tests live in `test/`: `widget_test.dart` (flow + catalogue integrity),
`templates_test.dart` (all 100 templates render at 360 dp & 680 dp + PDF
generation), `import_test.dart` (PDF/DOCX extraction + parser round-trip),
`photo_test.dart` (photo rendering + PDF embedding).

## 🔒 Privacy

No analytics, no network calls for core features, no account. Documents are
generated locally and only leave the device if **you** share them.

## 🗺️ Roadmap (not in v1.0)

Local save/restore · multiple profiles · accent-colour picker · ATS score ·
AI bullet suggestions · cloud sync. (Persistence is currently in-memory.)
