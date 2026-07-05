# Features — ResumeKit Pro

A feature-level reference: what the app does, the template catalogues, the
form/section model, the import pipeline, and export behaviour. For *how* it's
built, see [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## 1. Document types

ResumeKit Pro creates two document types from one app:

1. **Resume** — 50 templates, 11 content sections, 6-step wizard.
2. **Marriage Biodata** — 50 designs, Indian-style sections, 4-step wizard.

Both share the same engine: pick a design, fill a guided form, preview live,
switch designs freely, export a PDF.

## 2. Home screen — type & optional import

The entry screen (`features/home`) does two things:

- **Choose a document type** via radio-style cards (Resume / Marriage Biodata).
- **Optionally attach a file** (PDF or DOCX) to auto-fill the form. This is
  **not mandatory** — "No file? Skip this — you can type everything in."

On **Continue**, if a file was attached it's parsed and the extracted fields
pre-fill the working model; a toast reports *"Auto-filled N fields from
&lt;file&gt;"*. Then the matching template picker opens.

## 3. Template picker

- Responsive grid (2–5 columns by width) of every template for the chosen
  type, each card showing an abstract **miniature preview** of the layout
  (header shape, accent placement, sample text bars).
- **"⚡ Load Sample"** jumps straight to the preview with realistic sample
  data — great for a quick look.
- **"Fill In My Details"** opens the form wizard.
- The selected template is highlighted (accent border + check). Selection is
  carried into the form and preview.

## 4. Resume — templates & sections

### 4.1 Template catalogue (50)

**10 hand-crafted** (PRD Appendix 13):

| id | Name | Style |
|---|---|---|
| `modern_dark` | Modern Dark | Left accent border, crimson highlights |
| `clean_minimal` | Clean Minimal | White, thin rules, green accents |
| `corporate` | Corporate Blue | Solid blue header band, boxed labels |
| `creative_side` | Creative Split | Dark sidebar with avatar/skills |
| `bold_yellow` | Bold Accent | Dark bg, heavy name, yellow rule |
| `teal_elegant` | Teal Elegant | Centred header, soft teal rule |
| `two_column` | Two Column | Purple band, balanced 2-column grid |
| `tech_mono` | Tech Mono | Monospace, code-style header |
| `executive` | Executive | Centred serif name, diamond dividers |
| `gradient` | Gradient Header | Purple→pink banner, pill contacts |

**40 generated** = **8 palettes** (Sapphire, Emerald, Crimson, Violet, Amber,
Slate, Lagoon, Rosewood) × **5 header variants**:

| Variant | Header treatment |
|---|---|
| Band | Solid accent header band |
| Edge | Thick accent border on the left edge |
| Classic | Centred header with a thin rule |
| Line | Left-aligned header with a full-width rule |
| Flow | Accent → secondary gradient band |

Ids follow `gen_<palette>_<variant>` (e.g. `gen_sapphire_band`).

### 4.2 Form wizard — 6 steps / 11 sections

| Step | Sections | Fields |
|---|---|---|
| 1 — Personal & Contact | Header, Contact | **Profile photo**, full name*, job title*, tagline, phone*, email*, location, website, LinkedIn, GitHub, other link |
| 2 — Summary & Expertise | Summary, Expertise | Multi-line summary; dynamic expertise list |
| 3 — Work Experience | Experience | Repeatable: role*, company*, start*, end*, location, dynamic bullets |
| 4 — Skills & Projects | Tech Skills, Projects | Skill groups (category + CSV); repeatable projects (name*, role, tech, description, link) |
| 5 — Education | Education | Repeatable: degree*, institution*, years, grade/CGPA |
| 6 — More Info | Personal, Certificates, Patents | Address, DOB, languages, hobbies; repeatable certificates & patents |

\* required to advance / recommended. Repeatable entries support add/remove.
Empty entries and sections are automatically hidden in preview and PDF.

## 5. Marriage Biodata — designs & sections

### 5.1 Design catalogue (50)

**10 palettes** (Maroon, Royal Blue, Saffron, Emerald, Royal Purple, Peacock,
Antique Gold, Coral, Burgundy, Rose Pink) × **5 frame styles**:

| Frame | Treatment |
|---|---|
| Heritage | Ornamental double-line border |
| Classic | Single solid border |
| Regal | Accent corner brackets |
| Banner | Solid accent header band |
| Simple | Minimal, rule under the name |

Ids follow `bio_<palette>_<frame>` (e.g. `bio_maroon_heritage`). Each design
shows an optional **invocation line** (e.g. "॥ Shree Ganeshaya Namah ॥") and an
**initials/photo medallion**.

### 5.2 Form wizard — 4 steps

| Step | Section | Fields |
|---|---|---|
| 1 — Personal Details | Personal + Horoscope | **Profile photo**, invocation, name*, DOB, time & place of birth, height, complexion, blood group, marital status, diet, hobbies, religion, caste, gotra, manglik, rashi, nakshatra |
| 2 — Education & Career | Career | Education, occupation, company, annual income, work location |
| 3 — Family Details | Family | Father/mother name & occupation, brothers, sisters, family type, family values, native place |
| 4 — Contact & Expectations | Expectations, Contact | Partner expectations paragraph; phone, email, address |

Only `name` is required. Empty fields and whole empty sections are hidden.

## 6. Profile photo

- Added in **step 1** of either wizard via `PhotoPickerField` (uses
  `image_picker`, gallery source; resized to 800 px / 85% quality; bytes held
  in memory so it works on web too). Add / change / remove supported.
- **Rendered everywhere**: all resume template headers, all generated header
  variants, the Creative Split sidebar avatar (initials → photo swap), and the
  biodata medallion.
- **Embedded in PDF** (circular, accent-ringed). Undecodable image bytes are
  validated and silently skipped so export never fails.

## 7. Live preview & template switching

- Renders the full document in the selected template, scrollable, capped at
  **680 dp** wide for readability on large screens.
- A **horizontal template switcher** (toggled from the app bar) re-renders the
  document **instantly** in any other template — **no data is re-entered**.
- The active template name shows in the app-bar subtitle.
- **Edit** returns to the form wizard with all data intact.

## 8. File import / auto-fill

Optional, on-device, never uploads:

- **Pick:** PDF or DOCX (`file_picker`, `withData: true` for web).
- **PDF text:** `syncfusion_flutter_pdf` (`extractTextLines`).
- **DOCX text:** unzip with `archive`, read `word/document.xml`.
- **Resume parsing:** reliable regex for email/phone/LinkedIn/GitHub; heuristic
  extraction of name, job title, summary, and skills.
- **Biodata parsing:** maps ~50 `Label : value` aliases (DOB, height, gotra,
  manglik, father's name, family type, …) plus email/phone regex and a name
  fallback.
- Corrupt/unreadable files → blank form, no crash.

> Contact fields (regex-based) are highly reliable; name/title/summary are
> best-effort heuristics — always reviewable in the form before export.

## 9. PDF export

- **Print / Save as PDF** — system print dialog via `printing`.
- **Share PDF** — native share sheet via `share_plus`.
- Generated **on-device, offline**, A4, accent-tinted to the chosen template.
- All filled sections included; empty ones omitted.
- Filenames: `<Name>_resume.pdf` / `<Name>_biodata.pdf`.

## 10. Cross-cutting behaviour

- **Empty-section hiding** is uniform across preview and PDF.
- **Responsive** layouts down to 360 dp and up to web/desktop widths.
- **Offline & private** — no analytics, no network calls for core features, no
  account; data stays on the device.
- **Bundled Nunito** typography (weights 200–900) in both UI and PDFs.

## 11. Sample data

"⚡ Load Sample" populates realistic demos:

- **Resume:** *Deepak Sharma*, Technical Lead — full 11-section example.
- **Biodata:** *Ananya Sharma* — full Indian-style example with horoscope and
  family details.

## 12. Not in v1.0 (roadmap)

Local save/restore · multiple saved profiles · custom accent-colour picker ·
ATS score · AI summary/bullet suggestions · cloud sync · cover-letter builder.
Persistence is currently **in-memory** (data is lost when the app closes).
