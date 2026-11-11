# Repository Guidelines

## Project Structure & Module Organization

- `tex-report/code/main.tex` contains the entire report, packages, fonts, and shared formatting. Keep this single-file layout; do not split it into section or preamble files unless requested.
- `r/Nhom_D_TKTT.R` implements the bootstrap examples and simulations using base R.
- `assets/` holds shared static resources, including fonts, licenses, and checksums.
- `output/figures/`, `output/tables/`, and `output/logs/` receive new R results. `assets/simulate-results/` holds the report snapshot copied from `archive/previous-results/`; LaTeX and build scripts use this snapshot. Validate new results before promoting them into the report snapshot.
- `slide/beamer.tex` is the single-file Beamer deck; `slide/README.md` maps frames to report sources. `scripts/` contains Windows and macOS build commands. No dedicated test directory exists.

## Build, Test, and Development Commands

Run these commands from the repository root:

```text
Rscript r/Nhom_D_TKTT.R
```

Generates figures, CSV tables, and environment logs. The full simulation uses K = 10000 and B = 1999 and may take time.

```powershell
powershell -NoProfile -File scripts/build.ps1
```

Windows build; on macOS use `bash scripts/build.sh`. Add `-Target slides` or `slides` to build Beamer, `all` to build both; default remains report. Each selected target checks inputs and runs XeLaTeX three times. PDFs are `tex-report/code/main.pdf` and `slide/beamer.pdf`; both are tracked. Alternatively, open a source in TeXstudio and use Build & View.

## Coding Style & Naming Conventions

Use UTF-8, LF line endings, four spaces for LaTeX, and two for R, following `.editorconfig` and `.gitattributes`. No formatter or linter is configured; avoid unrelated reformatting. Use descriptive ASCII filenames without spaces for new assets and scripts. Preserve unique LaTeX labels. Use relative paths with `/` in LaTeX and `file.path()` in R; match filename case exactly.

## Testing Guidelines

There is no test framework or coverage threshold. Preserve existing R `stopifnot()` checks. For numerical changes, run the simulation, inspect results, and reconcile report tables and conclusions. Preserve seed and quantile conventions unless intentionally changing the experiment. For document changes, compile and inspect the PDF for layout, citations, and unresolved references. Run `git diff --check`. Report untested platforms or unavailable inputs explicitly.

## Commit & Pull Request Guidelines

Only the repository owner (`ryantr-statinops`) is permitted to work, commit, and push directly on the `main` branch (including directing the AI assistant to work directly on `main`). For all other contributors, every change must go on a dedicated branch and through a pull request to `main`; no one else may push directly to `main` or merge their own PR. The repository owner `ryantr-statinops` reviews and merges. Name branches `report/<task>`, `slides/<task>`, or `docs/<task>`. Describe scope and validation in the PR; attach updated PDFs for document/layout changes. Commit relevant generated figures, tables, logs, and PDFs with source changes. Exclude auxiliary build files and personal editor state; never force-push `main`. See `CONTRIBUTING.md` and `.github/pull_request_template.md`.
