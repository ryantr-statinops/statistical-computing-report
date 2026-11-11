#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
target="${1:-report}"
case "$target" in
    report|slides|all) ;;
    *) echo "Usage: $0 [report|slides|all]" >&2; exit 2 ;;
esac
if ! command -v xelatex >/dev/null 2>&1; then
    echo 'XeLaTeX not found. Install MiKTeX and add its bin directory to PATH.' >&2
    exit 1
fi
missing=0
documents=()
if [[ "$target" == report || "$target" == all ]]; then
    documents+=("tex-report/code/main.tex")
fi
if [[ "$target" == slides || "$target" == all ]]; then
    documents+=("slide/beamer.tex")
fi
for file in \
    assets/fonts/Arial-Regular.ttf \
    assets/fonts/Arial-Bold.ttf \
    assets/fonts/Arial-Italic.ttf \
    assets/fonts/Arial-BoldItalic.ttf \
    assets/fonts/NotoSans-Regular.ttf \
    assets/fonts/NotoSans-Bold.ttf \
    assets/fonts/NotoSans-Italic.ttf \
    assets/fonts/NotoSans-BoldItalic.ttf \
    assets/fonts/NotoSansMono-Regular.ttf \
    assets/fonts/NotoSansMono-Bold.ttf \
    assets/tdtu-logo.jpg \
    assets/simulate-results/example-bootstrap-distributions.pdf \
    assets/simulate-results/simulation-coverage.pdf \
    assets/simulate-results/simulation-average-length.pdf \
    assets/simulate-results/invariance-log-comparison.pdf; do
    if [[ ! -f "$project_root/$file" ]]; then
        echo "Missing input: $file" >&2
        missing=1
    fi
done
for file in "${documents[@]}"; do
    if [[ ! -f "$project_root/$file" ]]; then
        echo "Missing source: $file" >&2
        missing=1
    fi
done
if [[ "$missing" -ne 0 ]]; then
    echo 'Check shared assets and the report snapshot in assets/simulate-results/.' >&2
    exit 1
fi
for document in "${documents[@]}"; do
    document_dir="$(dirname "$document")"
    document_name="$(basename "$document")"
    (cd "$project_root/$document_dir" && {
        for pass in 1 2 3; do
            xelatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 "$document_name"
        done
    })
    echo "Built ${document%.tex}.pdf"
done
