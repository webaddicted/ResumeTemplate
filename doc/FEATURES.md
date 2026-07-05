# Features — ResumeKit Pro

---

## Core Flows

### Home
- Mode picker: Resume, Biodata, or Cards
- Import existing resume files (PDF/DOCX)

### Resume Builder
- Multi-step form (personal info, experience, education, skills)
- 100+ template picker with live preview
- ATS analysis with keyword scoring
- JD optimizer — paste a job description for gap analysis
- Final ATS validation before export
- PDF export and share

### Biodata Builder
- Marriage biodata templates
- Structured form (family, education, horoscope, photos)
- Preview and PDF export

### Cards
- Categories: invitations, business cards, event passes, profile cards
- Template picker per category
- Form + preview + PDF export

---

## Feature Matrix

| Feature | Route | Flow | Status |
|---------|-------|------|--------|
| Home | `/home` | Initial | ✅ |
| Resume ATS Analysis | `/resume/ats` | Resume | ✅ |
| Resume JD Optimizer | `/resume/jd` | Resume | ✅ |
| Resume Final ATS | `/resume/final-ats` | Resume | ✅ |
| Resume Templates | `/resume/templates` | Resume | ✅ |
| Resume Form | `/resume/form` | Resume | ✅ |
| Resume Preview | `/resume/preview` | Resume | ✅ |
| Biodata Templates | `/biodata/templates` | Biodata | ✅ |
| Biodata Form | `/biodata/form` | Biodata | ✅ |
| Biodata Preview | `/biodata/preview` | Biodata | ✅ |
| Card Categories | `/categories` | Cards | ✅ |
| Card Templates | `/card/templates` | Cards | ✅ |
| Card Form | `/card/form` | Cards | ✅ |
| Card Preview | `/card/preview` | Cards | ✅ |

---

## Cross-Cutting

| Capability | Implementation |
|------------|----------------|
| Dark theme | `AppTheme.dark()` + `ThemeController` |
| Local persistence | `SPHelper` + `EncryptedSpHelper` |
| Encryption service | `EncryptionService` (init in `initSDK`) |
| PDF generation | `pdf_generator`, `biodata_pdf_generator`, `card_pdf_generator` |
| AI suggestions | `AiEnhancementService` (on-device heuristics) |
| ATS scoring | `AtsAnalyzerService`, `JdAnalyzerService` |
| File import | `file_import.dart` |
| Responsive UI | `responsive_framework` |

---

## Optional / Roadmap

See [ROADMAP.md](ROADMAP.md).
