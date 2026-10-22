$root = $PSScriptRoot

$wc = New-Object System.Net.WebClient

if (!(Test-Path "$root\minify.exe"))
{
    $minifyRepo = "tdewolff/minify"

    $minifyReleases = "https://api.github.com/repos/$minifyRepo/releases"

    $minifyTag = (Invoke-WebRequest $minifyReleases -UseBasicParsing | ConvertFrom-Json)[0].tag_name

    $minifyDownloadURL = "https://github.com/$minifyRepo/releases/download/$minifyTag/minify_windows_amd64.zip"

    $wc.DownloadFile($minifyDownloadURL, "$root\minify.zip")

    New-Item -ItemType Directory -Path $root\temp

    Expand-Archive -Path "$root\minify.zip" -Destination "$root\temp"

    Copy-Item -Path "$root\temp\minify.exe" -Destination "$root"

    Remove-Item -Path "$root\minify.zip"

    Get-ChildItem -Path "$root\temp" -Recurse | Remove-Item -force -recurse

    Remove-Item "$root\temp" -Force 
}

$minifier = Join-Path $root "minify.exe"
$outputDirectory = Join-Path $root "build\v3"
New-Item -ItemType Directory -Path $outputDirectory -Force -ErrorAction Stop | Out-Null

# naat-min is the separate minimal theme, so build each source to its matching file.
foreach ($file in @("naat.v3.css", "naat-min.v3.css"))
{
    $source = Join-Path $root "css\v3\$file"
    $output = Join-Path $outputDirectory $file

    & $minifier -o $output $source
    if ($LASTEXITCODE -ne 0)
    {
        throw "Minification failed for $file (exit code $LASTEXITCODE)."
    }
}
