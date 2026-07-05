# ResumeKit Pro — Project Context

> Development context captured from the Claude Code build session (June 2026).
> Use this file to onboard a new chat/session or teammate to the project state.

---

## 1. What This App Is

**ResumeKit Pro** — a Flutter app (Android + Web, responsive) for creating
**resumes** and **marriage biodatas**:

- 50 resume templates + 50 biodata templates, switchable at any time
  **without re-entering data** (content is fully decoupled from presentation).
- Optional auto-fill from an existing **PDF / DOCX** file.
- Optional **profile photo** rendered in templates and exported PDFs.
- On-device **PDF export** (print / share) — no server, fully offline.
- Built per the "ResumeKit Pro" PRD v0.1 (10 templates, 11 resume sections,
  6-step wizard), then extended well beyond it on user request.

## 2. Current Project Structure

The project was restructured (by the user, after the initial build) into a
**GetX feature-first layout**:

```
lib/
├── main.dart                          # GetMaterialApp + InitialBinding + routes
├── controller/
│   ├── initial_binding.dart
│   ├── routes.dart                    # GetX route table
│   └── theme_controller.dart
├── features/
│   ├── home/presentation/home_page.dart           # type selector + file import
│   ├── resume/presentation/
│   │   ├── template_picker_page.dart              # 50-template grid
│   │   ├── form_steps_page.dart                   # 6-step wizard
│   │   └── resume_preview_page.dart               # live preview + switcher + export
│   └── biodata/presentation/
│       ├── biodata_picker_page.dart               # 50-style grid
│       ├── biodata_form_page.dart                 # 4-step wizard
│       └── biodata_preview_page.dart
├── global/
│   ├── constant/  (app_constant.dart, routers_const.dart)
│   ├── theme/app_theme.dart           # dark app chrome, TemplateInfo, catalogues
│   ├── utils/
│   │   ├── pdf_generator.dart         # resume PDF + shared pdfTheme()/decodablePhoto()
│   │   ├── biodata_pdf_generator.dart
│   │   └── file_import.dart           # PDF/DOCX text extraction + parsers
│   └── widgets/
│       ├── form_widgets.dart          # FormField2, StepIndicator, PhotoPickerField…
│       ├── template_card.dart         # shared picker card + MiniPreview
│       └── templates/
│           ├── template_base.dart     # TemplateStyle + shared blocks + ResumePhoto
│           ├── all_templates.dart     # 10 hand-crafted resume templates + dispatcher
│           ├── resume_template_specs.dart  # 40 generated resume specs + renderer
│           └── biodata_templates.dart      # 50 biodata specs + renderer
└── model/
    ├── resume_data.dart               # ResumeData + sub-models + sample()
    └── biodata_data.dart              # BiodataData + sample()
```

State management: plain mutable data objects passed between screens
(`setState` in forms); GetX is used for app shell (routing, theme,
bindings) after the user's restructure.

## 3. User Flow

```
HomePage
  ├─ select type: Resume | Marriage Biodata (radio cards)
  ├─ optional: attach PDF/DOCX → parsed on Continue (auto-fill toast)
  └─ Continue
       └─ Template picker (50 designs, responsive 2–5 column grid,
          "⚡ Load Sample" → straight to preview)
            └─ Form wizard (resume: 6 steps, biodata: 4 steps; photo picker
               in step 1; pre-filled when a file was imported)
                 └─ Preview (live render, max width 680 dp, horizontal
                    template switcher, Edit)
                      └─ Export PDF (Print / Save, Share) — on-device
```

## 4. Template System

- **Resume (50)** = 10 hand-crafted widgets (PRD Appendix 13 ids:
  `modern_dark`, `clean_minimal`, `corporate`, `creative_side`,
  `bold_yellow`, `teal_elegant`, `two_column`, `tech_mono`, `executive`,
  `gradient`) **+ 40 generated** from `ResumeTemplateSpec` =
  8 palettes (Sapphire, Emerald, Crimson, Violet, Amber, Slate, Lagoon,
  Rosewood) × 5 header variants (Band, Edge, Classic, Line, Flow).
  Generated ids: `gen_<palette>_<variant>`.
- **Biodata (50)** = `BiodataTemplateSpec`: 10 palettes (Maroon, Royal Blue,
  Saffron, Emerald, Royal Purple, Peacock, Antique Gold, Coral, Burgundy,
  Rose Pink) × 5 frames (Heritage double-line, Classic single border,
  Regal corner brackets, Banner header band, Simple). Ids:
  `bio_<palette>_<frame>`. Includes editable invocation line and an
  initials/photo medallion.
- All templates share content blocks (`StandardBody`, `ExpBlock`,
  `ProjBlock`, `EduBlock`, `SkillsTable`, `ContactWrap`, `TailSections`)
  driven by a `TemplateStyle` config. **Empty fields/sections are hidden**
  everywhere (UI + PDF).
- Catalogues live in `AppTheme.templates` / `AppTheme.biodataTemplates`
  (`TemplateInfo` + `TemplateHint` enum drives the miniature card previews).

## 5. Key Decisions & Gotchas (learned the hard way)

| Topic | Decision / Fix |
|---|---|
| Fonts | **Bundled Nunito only** (assets/fonts/Nunito-*.ttf, weights 200–900). google_fonts was removed for offline reliability. PDFs embed Nunito via shared `pdfTheme()` — Helvetica lacks `–` and `₹` glyphs. |
| `Center` in `bottomNavigationBar` | Expands to consume all body height (body got 0 px). Use `Align(heightFactor: 1)` instead. |
| Syncfusion PDF text | `extractText()` drops word spacing with embedded fonts → use `extractTextLines().map((l) => l.text).join('\n')`. |
| file_picker version | **Pinned to ^10.3.10.** v11 requires AGP 9 built-in Kotlin, but this project's `android/gradle.properties` has `android.builtInKotlin=false` → `FilePickerPlugin` class not found at Android build. v10 applies the Kotlin plugin itself. API differs: v10 = `FilePicker.platform.pickFiles`, v11 = static `FilePicker.pickFiles`. |
| Photo bytes validation | pdf package throws `ImageException` mid-paint on undecodable bytes → `decodablePhoto()` (package:image `decodeImage`) validates and skips the photo instead of failing the export. |
| Template overflows at 360 dp | Diamond-rule section titles and gradient contact pills needed `Flexible`; caught by per-template render tests at phone + wide widths. |
| Widget tests + lazy grids | A 0-height grid still builds ~1 row via cache extent — `find.text` can flakily pass. Test sizes/offsets when layout matters. |
| Responsive | Picker grid 2/3/4/5 columns at 600/900/1200 px; `creative_side` & `two_column` stack panes below 480 dp; resume preview capped at 680 dp; forms capped at 560 dp. |

## 6. File Import (auto-fill)

`global/utils/file_import.dart` — everything on-device:

- **Pick**: `FilePicker.platform.pickFiles` (pdf/docx, `withData: true` for web).
- **PDF**: Syncfusion `PdfTextExtractor.extractTextLines()`.
- **DOCX**: unzip (`archive`), regex `<w:t>` runs from `word/document.xml`,
  `</w:p>` = newline.
- **Resume parse**: regex for email/phone/linkedin/github; heuristics for
  name (first name-like line), job title (next line), summary & skills
  (heading-anchored paragraphs).
- **Biodata parse**: maps ~50 `Label : value` aliases (dob, height, gotra,
  manglik, father's name, family type, …) + email/phone regex + name fallback.
- Corrupt/unreadable files degrade to a blank form (no crash); a toast
  reports "Auto-filled N fields from <file>".

## 7. Data Models (all plain mutable strings; file is optional)

- `ResumeData` — 11 PRD sections: header/contact, summary, expertise[],
  experience[] (with bullets[]), techSkills[] (category+csv), projects[],
  education[], personal info, certificates[], patents[]; `photo: Uint8List?`;
  `templateId`; `filled*` getters implement hide-empty; `sample()`.
- `BiodataData` — invocation, personal (dob/height/complexion/blood group/
  religion/caste/diet/hobbies…), horoscope (rashi/nakshatra/gotra/manglik/
  birth time+place), education & career, family, partner expectations,
  contact; `photo`; section row getters skip empties; `sample()` (Ananya
  Sharma, Indian-style data).
- Persistence: **in-memory only** (v1.0 per PRD; save/restore is a v1.1 item).

## 8. Dependencies that matter

`pdf` + `printing` (export), `share_plus`, `image_picker` (photo),
`file_picker ^10.3.10` (import — do not bump to 11 without fixing Gradle),
`syncfusion_flutter_pdf` (PDF text extraction), `archive` (DOCX),
`image` (photo byte validation), `get` (routing/bindings after restructure).
`pubspec` also declares `.env` asset (empty file must exist) and Nunito fonts.

## 9. Tests (132 passing at handoff)

- `test/widget_test.dart` — home flow (type select → continue → pickers),
  catalogue integrity (50+50, unique ids), model/sample/initials units.
- `test/templates_test.dart` — **all 100 templates** render with sample data
  at 360 dp and 680 dp without exceptions; empty-section hiding; all 100
  PDFs generate; filename rules (`<Name>_resume.pdf`, `<Name>_biodata.pdf`).
- `test/import_test.dart` — DOCX extraction (in-memory zip fixture),
  resume/biodata parsers, **PDF round-trip** (generate → extract → parse),
  corrupt-input resilience.
- `test/photo_test.dart` — photo across header treatments, medallion
  initials↔photo swap, photo embedded in PDFs, undecodable-photo safety.
  PNG fixture must be generated with `package:image` (hand-rolled bytes
  fail pdf's strict IDAT checksum).

Commands: `flutter analyze` (clean), `flutter test`,
`flutter build web --release`, `flutter build apk --debug` — all green at
handoff (before the GetX restructure; re-verify after it).

## 10. Session Timeline (what was asked, in order)

1. **Implement PRD** — Flutter app, Android + web, responsive (10 templates,
   6-step wizard, preview, PDF export).
2. **Use Nunito from assets** — removed google_fonts everywhere, later also
   embedded Nunito into PDFs.
3. **50 resume + 50 biodata templates** — spec-driven generation + full
   biodata feature (model, wizard, preview, PDF) + home mode selector.
4. **New entry flow** — first page selects type (resume/biodata) **and**
   optional PDF/DOCX file; template page next; form pre-filled from file
   (file not mandatory).
5. **User image picker in templates** — photo picker in step 1; photo in all
   templates and both PDF exporters.
6. *(after session)* User restructured to GetX feature-first layout
   (`features/`, `global/`, `model/`, `controller/`) — imports in tests
   already updated to the new paths.

## 11. Known Open Items

- Re-run the full suite + both builds after the GetX restructure.
- PDF visual fidelity is a standardized A4 layout tinted by template accent —
  not a pixel-faithful copy of the on-screen template (PRD open question Q3).
- Resume parsing is heuristic — name/title/summary are best-effort;
  contact fields (regex) are reliable.
- v1.1+ candidates per PRD: local save/restore, multiple profiles,
  accent color picker, ATS score, AI suggestions.
