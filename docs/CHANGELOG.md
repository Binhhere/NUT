# NUT Changelog

Track work sessions here so README/checklists do not become the only record.

## 2026-06-19 - Project organization pass

- Added a top-level `NUT/README.md` to explain the project layout.
- Added `nut_docs/README.md` as the documentation index.
- Added `nut_docs/01_domain/` and `nut_docs/06_quality_release/` placeholders.
- Moved root-level build/fix logs into `nut_docs/05_implementation/`.
- Removed an empty brace-named folder that was accidentally created under `nut_docs/`.
- Added this changelog and `docs/V1_LAUNCH_CHECKLIST.md`.
- No app code changes were intentionally made in this organization pass.

Validation observed during review:

- `flutter analyze` completed with 2 issues: one unused import and one override parameter naming lint.
- `flutter test` ran 9 tests; 7 passed and 2 timed out at `pumpAndSettle`.
