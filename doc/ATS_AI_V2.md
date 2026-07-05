# V2 — ATS Score, AI Enhancement & JD Optimization

This document covers the V2 resume enhancements: ATS scoring, AI-assisted
content, job-description optimization, and the 90+ download gate. For the base
app see [`FEATURES.md`](FEATURES.md) and [`ARCHITECTURE.md`](ARCHITECTURE.md).

---

## 1. Goals

1. Generate an **ATS score** when a resume is uploaded.
2. **Improve resume content with AI** (summary, bullets, skills, certs).
3. **Job-Description based optimization** (extract keywords, gap analysis).
4. Drive the final resume to **ATS score > 90** before download.

## 2. Updated resume flow

```
Resume selected
  └─ Upload existing resume (optional)
       └─ ATS Analysis screen        ← NEW (only when a file was uploaded)
            └─ Template selection
                 └─ AI-assisted form filling   (AI Assist button)
                      └─ Preview
                           └─ Final ATS validation   ← gate
                                └─ Download (unlocks at ≥ 90)
```

If no file is uploaded, the flow skips ATS analysis and goes straight to
template selection (there is nothing to analyse yet); the final validation
gate still applies before download.

## 3. AI provider — important

The spec referenced a hosted "AI API". This app is **offline-first** with no
API key, so V2 ships a **deterministic, on-device engine**
(`LocalAiEnhancementService`) that needs no network: it produces professional
summaries, rewrites bullets with strong action verbs + quantified impact,
recommends skills/certs, and powers JD suggestions — all reproducibly.

It sits behind the `AiEnhancementService` interface via the
`AiEnhancement.instance` seam. To use a hosted LLM (Claude API, etc.):

```dart
// e.g. in InitialBinding
AiEnhancement.instance = MyClaudeEnhancementService();
```

Every screen reads through that seam, so no UI changes are needed to swap it.
The ATS and JD engines are fully deterministic regardless.

## 4. Feature 1 — ATS Resume Analyzer

`core/ats/ats_analyzer_service.dart` — deterministic, on-device. Scores five
weighted categories and emits prioritised, fixable issues.

| Category | Weight | What it measures |
|---|---|---|
| Formatting | 20 | Tables/columns/images in the uploaded file (clean structure scores high) |
| Skills | 25 | Count + in-demand coverage of listed skills |
| Experience | 20 | Action verbs, quantified achievements, weak-phrase penalty |
| Keywords | 20 | Skill density (or JD match % when a JD is supplied) |
| Readability | 15 | Sentence length, first-person pronouns, filler words |

Overall = weighted average (0–100). Bands: red < 60, orange 60–80, green > 80.

**Section validation** adds issues for missing summary, education,
certifications, and incomplete contact details. Each issue carries a
`severity` (critical / warning / minor) and a concrete `fix`.

**ATS Analysis screen** (`features/ats_analysis`): circular score dial,
per-category bars, sorted issue list, an optional "Target a Job Description"
panel, and the **Improve Resume with AI** CTA.

## 5. Feature 2 — AI Resume Enhancement

`core/ai/ai_enhancement_service.dart`:

- **Summary** — synthesised from role, years, top skills, first quantified win.
- **Experience bullet** — strips weak openers ("worked on"), leads with an
  action verb, appends a metric when none is present.
- **Skills** — recommends in-demand skills adjacent to the user's ecosystem.
- **Project** — clarifies scope/tech/outcome.
- **Certifications** — industry-relevant picks based on the resume's skills.

### AI Assist in the form

The form's app bar has an **AI Assist** button (steps 2–6). It generates
suggestion cards above the relevant section. Each card supports
**Accept / Edit / Dismiss** and tracks status
(`pending → accepted | edited | dismissed`). The wizard will not advance to the
next step while any suggestion is still **pending**.

## 6. Feature 3 — Job-Description Optimization

`core/jd/jd_analyzer_service.dart` + `features/jd_optimizer`:

- Extracts **required skills**, **keywords**, **responsibilities**, and
  **soft skills** from a pasted JD.
- Compares against the resume → **matched** vs **missing** keywords (the gap)
  and a **match score**.
- Produces concrete **suggested additions** (Skills / Summary / Experience),
  each with **Accept / Edit / Reject**; accepted ones are applied to the resume.

Reachable from the ATS analysis screen ("Target a Job Description" → Optimize)
and routable directly (`/resume/jd`).

## 7. Final ATS Validation & download gate

`features/final_validation`:

- Recalculates the ATS score on the improved resume.
- Lists **improvements applied** (summary present, keywords added, measurable
  achievements, education, certifications, complete contact).
- **Download rule:** enabled only at **ATS ≥ 90** (`AtsReport.passThreshold`).
  Below 90 the action is replaced by **Improve More** (returns to the form);
  at/above 90, **Download Resume** + **Share** are enabled (on-device PDF).

## 8. Architecture additions

```
lib/
├── core/                          ← NEW V2 engines (deterministic, on-device)
│   ├── constants/ats_keywords.dart    skills / verbs / filler word lists
│   ├── ats/ats_analyzer_service.dart  5-category scoring + issue detection
│   ├── jd/jd_analyzer_service.dart    JD extraction + gap analysis
│   └── ai/ai_enhancement_service.dart interface + LocalAiEnhancementService + seam
├── model/
│   ├── ats_report.dart                AtsReport, AtsIssue, AtsSeverity, weights
│   ├── ai_suggestion.dart             AiSuggestion + SuggestionStatus
│   └── jd_analysis.dart               JdAnalysis + JdSuggestion
├── features/
│   ├── ats_analysis/                  ATS analysis screen
│   ├── jd_optimizer/                  JD optimizer screen
│   └── final_validation/              final ATS gate + download
└── global/widgets/
    ├── ats_widgets.dart               score card, category bars, issue tile, JD summary
    └── ai_suggestion_card.dart        Accept/Edit/Dismiss card
```

New routes: `/resume/ats`, `/resume/jd`, `/resume/final-ats`.
`ResumeData` gained `sourceText` (raw uploaded text, used only for formatting
analysis). `AppTheme` gained `success`/`warning`/`danger` + `scoreColor()`.

## 9. Tests

- `test/ats_v2_test.dart` — weights sum to 100, blank vs rich scoring,
  determinism, JD extraction + gap, AI summary/bullet/skills/cert generation,
  the local-engine seam.
- `test/ats_screens_test.dart` — ATS analysis renders score/issues/CTA, JD
  optimizer analyses + lists the gap, final validation **gates < 90** and
  **unlocks ≥ 90**.

Full suite: **151 tests passing**, analyzer clean, web + Android builds green.

## 10. Notes & limitations

- ATS/JD scoring is heuristic and on-device — directionally aligned with real
  ATS behaviour, not a specific vendor's algorithm.
- AI content is template-based and deterministic; swap in an LLM via the seam
  for free-form generation.
- Persistence remains in-memory (V1 scope).
