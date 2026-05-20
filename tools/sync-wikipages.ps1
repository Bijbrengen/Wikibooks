param(
    [Parameter(Mandatory = $true)]
    [string]$ListPath,

    [string]$OutputRoot = "wikibooks/collections/leerpret-bronnen",

    [string]$ApiUrl = "https://nl.wikibooks.org/w/api.php"
)

$ErrorActionPreference = "Stop"

# Helper for BOM-less UTF-8
$utf8NoBom = New-Object System.Text.UTF8Encoding $false

function ConvertTo-SafeSegment {
    param([string]$Segment)
    if ([string]::IsNullOrWhiteSpace($Segment)) {
        return "_"
    }
    return ($Segment -replace '[<>:"\\|?*]', "_").Trim()
}

function Get-RootTitle {
    param([string]$Title)
    return ($Title -split "/", 2)[0]
}

$repoRoot = (Resolve-Path ".").Path
$resolvedListPath = Resolve-Path -LiteralPath $ListPath
$outputRootPath = Join-Path $repoRoot $OutputRoot
New-Item -ItemType Directory -Force -Path $outputRootPath | Out-Null

$seen = [ordered]@{}
foreach ($line in Get-Content -LiteralPath $resolvedListPath -Encoding UTF8) {
    $title = $line.Trim()
    if ($title.Length -eq 0 -or $title.StartsWith("#")) {
        continue
    }
    if (-not $seen.Contains($title)) {
        $seen[$title] = $true
    }
}
$titles = @($seen.Keys)

$headers = @{
    "User-Agent" = "Leerpret local Wikibooks exact-page mirror/0.1 (https://nl.wikibooks.org/)"
}

$manifest = [ordered]@{
    source = ($ApiUrl -replace "/w/api\.php", "/wiki/")
    api = $ApiUrl
    list = $resolvedListPath.Path
    fetched_at_utc = (Get-Date).ToUniversalTime().ToString("o")
    requested_count = $titles.Count
    fetched_count = 0
    missing_count = 0
    pages = @()
    missing = @()
    redirects = @()
}

$indexLines = New-Object System.Collections.Generic.List[string]
$indexLines.Add("# Leerpret-bronnen")
$indexLines.Add("")
$indexLines.Add("Exacte lokale mirror van de opgegeven Wikibooks-pagina's.")
$indexLines.Add("")
$indexLines.Add("Bronlijst: " + $resolvedListPath.Path)
$indexLines.Add("")
$indexLines.Add("Opgehaald: " + $manifest.fetched_at_utc)
$indexLines.Add("")
$indexLines.Add("## Pagina's")
$indexLines.Add("")

for ($i = 0; $i -lt $titles.Count; $i += 40) {
    $batch = @($titles[$i..([Math]::Min($i + 39, $titles.Count - 1))])
    $body = @{
        action = "query"
        prop = "info|revisions"
        titles = ($batch -join "|")
        rvprop = "ids|timestamp|user|comment|content|sha1"
        rvslots = "main"
        redirects = "1"
        formatversion = "2"
        format = "json"
    }

    $data = Invoke-RestMethod -Method Post -Headers $headers -Uri $ApiUrl -Body $body -TimeoutSec 90
    
    if ($data.error) {
        Write-Error "API Error: $($data.error.code) - $($data.error.info)"
        break
    }

    if ($data.query.redirects) {
        foreach ($redirect in $data.query.redirects) {
            $manifest.redirects += [ordered]@{
                from = $redirect.from
                to = $redirect.to
            }
        }
    }

    foreach ($page in $data.query.pages) {
        $pageTitle = [string]$page.title
        if ($page.missing) {
            $manifest.missing += [ordered]@{
                title = $pageTitle
                pageid = $page.pageid
            }
            continue
        }

        $root = Get-RootTitle $pageTitle
        $rootDir = Join-Path $outputRootPath (ConvertTo-SafeSegment $root)

        $relative = $pageTitle
        if ($relative -eq $root) {
            $relative = "_index"
        } elseif ($relative.StartsWith("$root/")) {
            $relative = $relative.Substring($root.Length + 1)
        }

        $segments = @($relative -split "/" | ForEach-Object { ConvertTo-SafeSegment $_ })
        $target = $rootDir
        foreach ($segment in $segments) {
            $target = Join-Path $target $segment
        }
        $target = "$target.wiki"
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null

        $rev = $page.revisions[0]
        $content = $rev.slots.main.content
        [System.IO.File]::WriteAllText($target, $content, $utf8NoBom)

        $localFile = ($target.Substring($outputRootPath.Length + 1) -replace "\\", "/")
        $manifest.pages += [ordered]@{
            title = $pageTitle
            file = $localFile
            root = $root
            pageid = $page.pageid
            contentmodel = $page.contentmodel
            revid = $rev.revid
            parentid = $rev.parentid
            timestamp = $rev.timestamp
            user = $rev.user
            comment = $rev.comment
            sha1 = $rev.sha1
            bytes = (Get-Item -LiteralPath $target).Length
        }
        $indexLines.Add("- [$pageTitle]($localFile)")
    }

    Start-Sleep -Milliseconds 1500
}

$manifest.fetched_count = @($manifest.pages).Count
$manifest.missing_count = @($manifest.missing).Count

[System.IO.File]::WriteAllText((Join-Path $outputRootPath "_manifest.json"), ($manifest | ConvertTo-Json -Depth 8), $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $outputRootPath "_index.md"), ($indexLines -join [Environment]::NewLine), $utf8NoBom)

$grouped = $manifest.pages | Group-Object root | Sort-Object Name
foreach ($group in $grouped) {
    $rootDir = Join-Path $outputRootPath (ConvertTo-SafeSegment $group.Name)
    New-Item -ItemType Directory -Force -Path $rootDir | Out-Null
    $lines = New-Object System.Collections.Generic.List[string]
    $lines.Add("# $($group.Name)")
    $lines.Add("")
    $lines.Add("Onderdeel van de collectie `leerpret-bronnen`.")
    $lines.Add("")
    foreach ($page in ($group.Group | Sort-Object title)) {
        $lines.Add("- [$($page.title)]($($page.file.Substring($page.file.IndexOf('/') + 1)))")
    }
    [System.IO.File]::WriteAllText((Join-Path $rootDir "_index.md"), ($lines -join [Environment]::NewLine), $utf8NoBom)
}

Write-Output "Requested $($manifest.requested_count), fetched $($manifest.fetched_count), missing $($manifest.missing_count) into $outputRootPath"

