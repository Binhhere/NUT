# NUT Docs Index

This folder holds product, design, architecture, and implementation planning.
The runnable app is in `../nut_mvp/`.

## Reading Order

1. `00_project/00_Project_Charter.md` - vision, market, and tech stack.
2. `00_project/01_MVP_Scope.md` - what belongs in v1 and what waits.
3. `04_api_ui/03_Screen_Inventory.md` - screens and navigation.
4. `04_api_ui/01_User_Flows.md` - detailed user flows.
5. `04_api_ui/02_Design_System.md` - visual rules and shared components.
6. `05_implementation/01_Implementation_Roadmap.md` - phased build plan.
7. `../nut_mvp/docs/V1_LAUNCH_CHECKLIST.md` - current v1.0 launch boundary.
8. `../nut_mvp/docs/RELEASE_CHECKLIST.md` - release/store readiness.

## Folder Map

- `00_project/` - charter, MVP scope, product boundaries.
- `01_domain/` - domain assumptions, safety language, policy notes.
- `02_research/` - competitors, ASO, distribution ideas.
- `03_system_design/` - planned backend/database architecture.
- `04_api_ui/` - flows, screen inventory, design system, HTML prototype.
- `05_implementation/` - roadmap, Codex prompts, handoff, build guide, fix log.
- `06_quality_release/` - index for QA, release, and checklist docs.

## Source Of Truth

- Current implementation: `../nut_mvp/lib/`, `../nut_mvp/test/`, and platform files.
- Current v1.0 work boundary: `../nut_mvp/docs/V1_LAUNCH_CHECKLIST.md`.
- Public/internal release prep: `../nut_mvp/docs/RELEASE_CHECKLIST.md`.
- Future product direction: this `nut_docs/` folder.

If an older planning file says a feature exists but the app does not implement it,
treat the app as current and update the planning/checklist docs.
