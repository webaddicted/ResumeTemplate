# aaresumeTemplate — Architecture

<!-- AUTO-GENERATED:architecture -->
## Pattern

GetX feature-based (features/ + global/ + controller/)

## Layers

| Layer | Location | Notes |
|-------|----------|-------|
| Presentation | `lib/features/**/presentation`, `lib/view/` | Screens and widgets |
| Controllers | `lib/features/**/controller`, `lib/controller/` | GetX / flow control |
| Data | `lib/features/**/data`, repositories | API and persistence |
| Domain | `lib/features/**/domain`, models | Entities and constants |
| Global | `lib/global/` | Shared API, theme, SP, utils |

## State management

- Primary: **GetX**
- Bindings: `lib/controller/initial_binding.dart` (if present)

## Network layer

- API helpers under `lib/global/apiutils/` or project-specific API utils
- Endpoints documented in `api-reference.md`

## Services

- AiEnhancement (lib/core/ai/ai_enhancement_service.dart)
- AiEnhancementService (lib/core/ai/ai_enhancement_service.dart)
- AtsAnalyzerService (lib/core/ats/ats_analyzer_service.dart)
- JdAnalyzerService (lib/core/jd/jd_analyzer_service.dart)
- LocalAiEnhancementService (lib/core/ai/ai_enhancement_service.dart)

## Repositories

- AtsCategoryScore (lib/model/ats_report.dart)
- AtsIssue (lib/model/ats_report.dart)
- AtsReport (lib/model/ats_report.dart)
- AtsWeights (lib/model/ats_report.dart)
<!-- END AUTO-GENERATED:architecture -->
