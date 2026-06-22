# NUT Project Overview

This repository is now the single home for the runnable Flutter app and the
product/planning documentation that used to live next to it.

## Start Here

- `README.md` - setup, run, build, test, and current app status.
- `docs/README.md` - documentation map.
- `docs/V1_LAUNCH_CHECKLIST.md` - current v1.0 code/product scope boundary.
- `docs/RELEASE_CHECKLIST.md` - store and release readiness.
- `docs/planning/README.md` - older product, design, implementation, and handoff docs.

## Current Shape

```text
nut_mvp/
  README.md
  AGENTS.md
  CLAUDE.md
  lib/                     Flutter app source
  test/                    Unit and widget tests
  android/ ios/ ...        Platform projects
  docs/
    README.md              Documentation map
    V1_LAUNCH_CHECKLIST.md Current v1.0 boundary
    RELEASE_CHECKLIST.md   Store and release readiness
    CHANGELOG.md           Session-by-session change notes
    planning/              Product/design/architecture planning archive
```

## Working Rule

Use the app code and active checklists as the truth for what exists today. Use
`docs/planning/` for intent, roadmap, design direction, and later phases. If an
older planning file conflicts with the current app or `V1_LAUNCH_CHECKLIST.md`,
the current app/checklist wins until the plan is deliberately updated.

## Normal Workflow

1. Check `git status --short --branch`.
2. Review `docs/V1_LAUNCH_CHECKLIST.md` before adding v1.0 work.
3. Run `flutter analyze` and `flutter test` after code changes.
4. Update `docs/CHANGELOG.md` at the end of a meaningful work session.

## Current Notes

- The app is still local-first: no backend, no login requirement, no real billing.
- Feed/community is not production-ready moderation-wise.
- Premium screens are placeholders/previews unless billing is integrated.
- Store launch work belongs in `docs/RELEASE_CHECKLIST.md`.
