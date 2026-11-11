# Repository Guidelines

## Project Structure & Module Organization

- `tex-report/code/main.tex` contains the entire report, packages, fonts, and shared formatting. Keep this single-file layout; do not split it into section or preamble files unless requested.
- `r/Nhom_D_TKTT.R` implements the bootstrap examples and simulations using base R.
- `assets/` holds shared static resources, including fonts, licenses, and checksums.
- `output/figures/`, `output/tables/`, and `output/logs/` receive new R results. `assets/simulate-results/` holds the report snapshot copied from `archive/previous-results/`; LaTeX and build scripts use this snapshot. Validate new results before promoting them into the report snapshot.
- `scripts/` contains platform build commands; `slide/` is reserved for slide sources. No dedicated test directory exists.

## Build, Test, and Development Commands

Run these commands from the repository root:

```text
Rscript r/Nhom_D_TKTT.R
```

Generates figures, CSV tables, and environment logs. The full simulation uses K = 10000 and B = 1999 and may take time.

```powershell
powershell -NoProfile -File scripts/build.ps1
```

Windows build; on macOS use `bash scripts/build.sh`. Both check required inputs and run XeLaTeX three times. The PDF is `tex-report/code/main.pdf`. Alternatively, open `main.tex` in TeXstudio and use Build & View.

## Coding Style & Naming Conventions

Use UTF-8, LF line endings, four spaces for LaTeX, and two for R, following `.editorconfig` and `.gitattributes`. No formatter or linter is configured; avoid unrelated reformatting. Use descriptive ASCII filenames without spaces for new assets and scripts. Preserve unique LaTeX labels. Use relative paths with `/` in LaTeX and `file.path()` in R; match filename case exactly.

## Testing Guidelines

There is no test framework or coverage threshold. Preserve existing R `stopifnot()` checks. For numerical changes, run the simulation, inspect results, and reconcile report tables and conclusions. Preserve seed and quantile conventions unless intentionally changing the experiment. For document changes, compile and inspect the PDF for layout, citations, and unresolved references. Run `git diff --check`. Report untested platforms or unavailable inputs explicitly.

## Commit & Pull Request Guidelines

History currently contains one descriptive commit, without a prescribed prefix. Use short, action-oriented messages such as `Update report introduction`. Work on branches such as `report/update-methods`; open pull requests into `main` and request another member's review. Describe changes, validation, and related issues when applicable; include PDF excerpts for layout changes. Commit regenerated figures, tables, and logs together. Exclude build artifacts and personal editor state; never force-push `main`. See `CONTRIBUTING.md` for setup details.
