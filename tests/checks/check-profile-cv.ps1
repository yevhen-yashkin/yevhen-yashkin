$ErrorActionPreference = 'Stop'

$repositoryRoot = Resolve-Path (Join-Path $PSScriptRoot '..\..')
$readmePath = Join-Path $repositoryRoot 'README.md'
$lebenslaufPath = Join-Path $repositoryRoot 'assets\cv\Yevhen_Yashkin_Lebenslauf_2026.pdf'
$englishCvPath = Join-Path $repositoryRoot 'assets\cv\Yevhen_Yashkin_CV_2026.pdf'
$expectedLebenslaufHash = 'B396DEB284A5DFEABED75A19E1428B7C8A453D4A0D17304D0204761EDB77F1C4'

$readme = Get-Content -LiteralPath $readmePath -Raw

if ($readme -match 'Yevhen_Yashkin_CV_2026\.pdf|CV\s*[—-]\s*English') {
    throw 'README still contains the English CV entry.'
}

$lebenslaufLinkCount = ([regex]::Matches(
    $readme,
    'assets/cv/Yevhen_Yashkin_Lebenslauf_2026\.pdf'
)).Count

if ($lebenslaufLinkCount -ne 1) {
    throw "Expected exactly one Lebenslauf link in README; found $lebenslaufLinkCount."
}

if (-not (Test-Path -LiteralPath $lebenslaufPath -PathType Leaf)) {
    throw 'The German Lebenslauf PDF is missing.'
}

if (Test-Path -LiteralPath $englishCvPath) {
    throw 'The English CV PDF is still present.'
}

$actualHash = (Get-FileHash -LiteralPath $lebenslaufPath -Algorithm SHA256).Hash
if ($actualHash -ne $expectedLebenslaufHash) {
    throw "Unexpected Lebenslauf SHA256: $actualHash"
}

$stream = [System.IO.File]::OpenRead($lebenslaufPath)
try {
    $headerBytes = New-Object byte[] 5
    $bytesRead = $stream.Read($headerBytes, 0, $headerBytes.Length)
}
finally {
    $stream.Dispose()
}

$header = [System.Text.Encoding]::ASCII.GetString($headerBytes, 0, $bytesRead)
if ($header -ne '%PDF-') {
    throw "Invalid PDF header: $header"
}

Write-Output 'Profile CV checks passed.'
