param(
    [Parameter(Mandatory = $true)]
    [string]$Title,

    [string]$OutputRoot = "wikibooks/books",

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

function Get-PageTree {
    param(
        [string]$Api,
        [string]$Prefix,
        [hashtable]$Headers
    )

    $all = New-Object System.Collections.Generic.List[string]
    $continue = $null

    $nsId = "0"
    $apPrefix = $Prefix
    if ($Prefix -match "^(?<ns>.+):(?<title>.+)$") {
        $nsName = $Matches.ns
        $apPrefix = $Matches.title
        if ($nsName -eq "Module") { $nsId = "828" }
        elseif ($nsName -eq "Sjabloon" -or $nsName -eq "Template") { $nsId = "10" }
    }

    do {
        $body = @{
            action = "query"
            list = "allpages"
            apnamespace = $nsId
            apprefix = $apPrefix
            aplimit = "max"
            format = "json"
        }
        if ($continue) {
            $body.apcontinue = $continue
        }

        $data = Invoke-RestMethod -Method Post -Headers $Headers -Uri $Api -Body $body -TimeoutSec 60
        if ($data.error) {
            throw "API Error (allpages): $($data.error.code) - $($data.error.info)"
        }
        
        foreach ($page in $data.query.allpages) {
            if ($page.title -eq $Prefix -or $page.title.StartsWith("$Prefix/")) {
                $all.Add([string]$page.title)
            }
        }
        $continue = $data.continue.apcontinue
    } while ($continue)

    if (-not $all.Contains($Prefix)) {
        $all.Insert(0, $Prefix)
    }

    return ,@($all | Sort-Object -Unique)
}

$headers = @{
    "User-Agent" = "Leerpret local Wikibooks mirror/0.1 (https://nl.wikibooks.org/)"
}

$repoRoot = (Resolve-Path ".").Path
$outRootPath = Join-Path $repoRoot $OutputRoot
$bookDirName = ConvertTo-SafeSegment $Title
$bookRoot = Join-Path $outRootPath $bookDirName
New-Item -ItemType Directory -Force -Path $bookRoot | Out-Null

$titles = Get-PageTree -Api $ApiUrl -Prefix $Title -Headers $headers

$manifest = [ordered]@{
    source = ($ApiUrl -replace "/w/api\.php", "/wiki/") + [uri]::EscapeDataString($Title).Replace('%20','_')
    api = $ApiUrl
    title = $Title
    fetched_at_utc = (Get-Date).ToUniversalTime().ToString("o")
    page_count = $titles.Count
    pages = @()
}

$indexLines = New-Object System.Collections.Generic.List[string]
$indexLines.Add("# $Title")
$indexLines.Add("")
$indexLines.Add("Lokale mirror van Wikibooks-pagina's met prefix: " + $Title)
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
        formatversion = "2"
        format = "json"
    }

    $data = Invoke-RestMethod -Method Post -Headers $headers -Uri $ApiUrl -Body $body -TimeoutSec 60
    if ($data.error) {
        Write-Error "API Error (revisions): $($data.error.code) - $($data.error.info)"
        break
    }

    foreach ($page in $data.query.pages) {
        $pageTitle = [string]$page.title
        if ($page.missing) {
            Write-Warning "Page missing: $pageTitle"
            continue
        }
        $relative = $pageTitle
        $extension = ".wiki"
        if ($page.contentmodel -eq "Scribunto") {
            $extension = ".lua"
        }

        if ($relative -eq $Title) {
            $relative = "_module"
        } elseif ($relative.StartsWith("$Title/")) {
            $relative = $relative.Substring($Title.Length + 1)
        }

        $segments = @($relative -split "/" | ForEach-Object { ConvertTo-SafeSegment $_ })
        $target = $bookRoot
        foreach ($segment in $segments) {
            $target = Join-Path $target $segment
        }
        $target = "$target$extension"
        New-Item -ItemType Directory -Force -Path (Split-Path -Parent $target) | Out-Null

        $rev = $page.revisions[0]
        $content = $rev.slots.main.content
        [System.IO.File]::WriteAllText($target, $content, $utf8NoBom)

        $localFile = ($target.Substring($bookRoot.Length + 1) -replace "\\", "/")
        $manifest.pages += [ordered]@{
            title = $pageTitle
            file = $localFile
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

    Start-Sleep -Milliseconds 1200
}

[System.IO.File]::WriteAllText((Join-Path $bookRoot "_manifest.json"), ($manifest | ConvertTo-Json -Depth 8), $utf8NoBom)
[System.IO.File]::WriteAllText((Join-Path $bookRoot "_index.md"), ($indexLines -join [Environment]::NewLine), $utf8NoBom)

Write-Output "Mirrored $($titles.Count) page(s) for '$Title' to $bookRoot"

