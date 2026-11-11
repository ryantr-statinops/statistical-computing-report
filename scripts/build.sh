#!/usr/bin/env bash
set -euo pipefail
project_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
if ! command -v xelatex >/dev/null 2>&1; then
    echo 'XeLaTeX not found. Install MiKTeX and add its bin directory to PATH.' >&2
    exit 1
fi
missing=0
for file in \
    assets/fonts/LiberationSerif-Regular.ttf \
    assets/fonts/LiberationSerif-Bold.ttf \
    assets/fonts/LiberationSerif-Italic.ttf \
    assets/fonts/LiberationSerif-BoldItalic.ttf \
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
if [[ "$missing" -ne 0 ]]; then
    echo 'Check shared assets and the report snapshot in assets/simulate-results/.' >&2
    exit 1
fi
cd "$project_root/tex-report/code"
for pass in 1 2 3; do
    xelatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 main.tex
done
echo 'Built tex-report/code/main.pdf'
