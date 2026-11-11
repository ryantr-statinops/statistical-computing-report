$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command xelatex -ErrorAction SilentlyContinue)) {
    throw 'XeLaTeX not found. Install MiKTeX and add its bin directory to PATH.'
}
$requiredFiles = @(
    'assets/fonts/LiberationSerif-Regular.ttf',
    'assets/fonts/LiberationSerif-Bold.ttf',
    'assets/fonts/LiberationSerif-Italic.ttf',
    'assets/fonts/LiberationSerif-BoldItalic.ttf',
    'assets/fonts/NotoSans-Regular.ttf',
    'assets/fonts/NotoSans-Bold.ttf',
    'assets/fonts/NotoSans-Italic.ttf',
    'assets/fonts/NotoSans-BoldItalic.ttf',
    'assets/fonts/NotoSansMono-Regular.ttf',
    'assets/fonts/NotoSansMono-Bold.ttf',
    'assets/tdtu-logo.jpg',
    'assets/simulate-results/example-bootstrap-distributions.pdf',
    'assets/simulate-results/simulation-coverage.pdf',
    'assets/simulate-results/simulation-average-length.pdf',
    'assets/simulate-results/invariance-log-comparison.pdf'
)
$missingFiles = @($requiredFiles | Where-Object {
    -not (Test-Path -LiteralPath (Join-Path $projectRoot $_) -PathType Leaf)
})
if ($missingFiles.Count -gt 0) {
    throw ("Missing report inputs. Check assets/fonts and assets/simulate-results:`n" + ($missingFiles -join "`n"))
}
Push-Location (Join-Path $projectRoot 'tex-report/code')
try {
    for ($pass = 1; $pass -le 3; $pass++) {
        & xelatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 main.tex
        if ($LASTEXITCODE -ne 0) { throw "XeLaTeX failed on pass $pass. See main.log." }
    }
} finally {
    Pop-Location
}
Write-Host 'Built tex-report/code/main.pdf'
