# Card Document Types (Invitations, Business, Events, Profiles)

This document covers the additional document categories added on top of
Resume and Marriage Biodata. Each category ships **50 designs**
(10 palettes × 5 style variants), built by the same spec-driven engine.

See [`ARCHITECTURE.md`](ARCHITECTURE.md) for the overall structure and
[`FEATURES.md`](FEATURES.md) for resume/biodata.

---

## 1. Categories (17 new types, 4 families)

| Group | Category | id | Family |
|---|---|---|---|
| Invitations | Marriage Invitation | `inv_marriage` | invitation |
| Invitations | Engagement | `inv_engagement` | invitation |
| Invitations | Save the Date | `inv_save_date` | invitation |
| Invitations | Wedding Program | `inv_wedding_program` | invitation |
| Invitations | Funeral / Demise | `inv_demise` | invitation |
| Events | Birthday Invitation | `inv_birthday` | invitation |
| Events | Anniversary Invitation | `inv_anniversary` | invitation |
| Events | Baby Shower | `inv_baby_shower` | invitation |
| Events | Housewarming | `inv_housewarming` | invitation |
| Events | Retirement | `inv_retirement` | invitation |
| Events | Farewell | `inv_farewell` | invitation |
| Events | Event Pass | `event_pass` | eventPass |
| Business | Business Card | `business_card` | businessCard |
| Business | Visiting Card | `visiting_card` | businessCard |
| Profiles | Personal Profile | `personal_profile` | profile |
| Profiles | Student Profile | `student_profile` | profile |
| Profiles | Social Media Bio | `social_bio` | profile |

> Marriage biodata (Traditional / Modern aesthetics) already ships as its own
> 50-design catalogue — see [`FEATURES.md`](FEATURES.md) §5.

**Totals:** 17 categories × 50 = **850 card designs**, plus 50 resume + 50
biodata = **950 designs** across the app.

## 2. The generic card engine

One pattern serves every category — no per-category hand-coding of designs.

- **`model/card_data.dart`** — `CardData` holds values loosely by key
  (`Map<String,String>`) + optional photo, so one form and one renderer family
  handle many categories. `CardFamily` enum; `CardFieldSpec` describes a field.
- **`global/constant/card_categories.dart`** — `DocCategory` registry: per
  category id, label, group, family, icon, accent, **field specs** (with
  contextual labels/hints), `usesPhoto`, default headline, and **sample data**.
- **`global/widgets/templates/card_template_specs.dart`** — generates **50
  `CardTemplateSpec`** per category (10 palettes × 5 variants:
  Ornate / Banner / Classic / Gradient / Minimal). `CardCatalogue` caches the
  catalogues, `TemplateInfo` lists (for picker thumbnails), and id lookup.
- **`global/widgets/templates/card_renderers.dart`** — `buildCardTemplate(data)`
  dispatches by family to one of four shared renderers:
  - **Invitation** — centered ceremonial card: headline, names ("A & B"),
    host line, message, programme lines, date/time/venue/address, RSVP,
    optional photo. Variant changes the frame (double border, top banner,
    hairline, gradient, minimal).
  - **Event pass** — ticket with a gradient body, key/value details, and a
    QR-style stub separated by a dashed perforation.
  - **Business / visiting card** — content-sized card (left accent bar, top
    band, gradient, or minimal) with name, designation, company, contact rows.
  - **Profile** — medallion (photo or initials) header, name + headline,
    about, auto-generated detail rows from the category's extra fields, and
    interest chips.
- **`global/utils/card_pdf_generator.dart`** — generic A4 PDF (accent-tinted,
  bordered) mirroring the card content; reuses the shared `pdfTheme()` (Nunito)
  and `decodablePhoto()` from the resume PDF generator.

Empty fields and sections are hidden everywhere (preview + PDF).

## 3. Flow

```
Home → "More — Invitations, Cards, Events & Profiles"
  └─ Categories page (grouped tiles)
       └─ Card picker (50 designs, ⚡ Load Sample)
            └─ Card form (fields from the category, optional photo)
                 └─ Card preview (design switcher) → Export PDF (print / share)
```

Routes: `/categories`, `/card/templates` (arg: categoryId),
`/card/form` & `/card/preview` (arg: `CardData`).

## 4. Adding a new category

1. Append a `DocCategory` to `CardCategories.all` (id, group, family, icon,
   accent, field specs, sample, optional `usesPhoto`/`headline`).
2. That's it — 50 designs, the picker, form, preview, and PDF all work
   automatically through the generic engine. Pick the closest `CardFamily`
   for its layout (or add a new family + renderer for a genuinely new shape).

## 5. Tests

`test/cards_test.dart`: 17 categories / 4 families, **exactly 50 designs each
(850 unique ids)**, every category renders its sample at 360 dp and 680 dp
without overflow, variant switching, PDF generation per family, and filename
derivation.

Full suite at handoff: **174 tests passing**, analyzer clean, web + Android
builds green.
