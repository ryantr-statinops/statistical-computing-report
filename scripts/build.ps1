param(
    [ValidateSet('report', 'slides', 'all')]
    [string]$Target = 'report'
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
if (-not (Get-Command xelatex -ErrorAction SilentlyContinue)) {
    throw 'XeLaTeX not found. Install MiKTeX and add its bin directory to PATH.'
}
$sharedFiles = @(
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
$requiredFiles = @($sharedFiles)
if ($Target -in @('report', 'all')) { $requiredFiles += 'tex-report/code/main.tex' }
if ($Target -in @('slides', 'all')) { $requiredFiles += 'slide/beamer.tex' }
$missingFiles = @($requiredFiles | Where-Object {
    -not (Test-Path -LiteralPath (Join-Path $projectRoot $_) -PathType Leaf)
})
if ($missingFiles.Count -gt 0) {
    throw ("Missing report inputs. Check assets/fonts and assets/simulate-results:`n" + ($missingFiles -join "`n"))
}
foreach ($document in @(
    if ($Target -in @('report', 'all')) { 'tex-report/code/main.tex' }
    if ($Target -in @('slides', 'all')) { 'slide/beamer.tex' }
)) {
    $documentDirectory = Split-Path -Parent (Join-Path $projectRoot $document)
    $documentName = Split-Path -Leaf $document
    Push-Location $documentDirectory
    try {
        for ($pass = 1; $pass -le 3; $pass++) {
            & xelatex -interaction=nonstopmode -halt-on-error -file-line-error -synctex=1 $documentName
            if ($LASTEXITCODE -ne 0) { throw "XeLaTeX failed for $document on pass $pass." }
        }
    } finally {
        Pop-Location
    }
    Write-Host "Built $([System.IO.Path]::ChangeExtension($document, '.pdf'))"
}
