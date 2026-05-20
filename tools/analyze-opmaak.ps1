$repoRoot = (Get-Item $PSScriptRoot).Parent.FullName
$booksDir = Join-Path $repoRoot "books"
$collectionsDir = Join-Path $repoRoot "collections"
$reportPath = Join-Path $repoRoot "opmaak-report.html"

$results = @{
    RootNoOpmaak = New-Object System.Collections.Generic.List[PSObject]
    SubNoOpmaak = New-Object System.Collections.Generic.List[PSObject]
    OtherTemplates = New-Object System.Collections.Generic.List[PSObject]
}

function Analyze-Directory {
    param([string]$Dir)
    
    $manifestPath = Join-Path $Dir "_manifest.json"
    if (-not (Test-Path $manifestPath)) { return }
    
    $manifest = Get-Content $manifestPath | ConvertFrom-Json
    foreach ($page in $manifest.pages) {
        $filePath = Join-Path $Dir $page.file
        if (-not (Test-Path $filePath)) { continue }
        
        $content = Get-Content $filePath -Raw
        
        # Regex to find templates: {{TemplateName ...}}
        # We need to handle nested templates eventually, but a simple scan for names is enough here.
        $templates = [regex]::Matches($content, '\{\{\s*([^|{}]+)') | ForEach-Object { $_.Groups[1].Value.Trim() }
        
        $hasOpmaak = $templates | Where-Object { $_ -match "^(Sjabloon:)?Opmaak$" }
        $otherTemplates = $templates | Where-Object { $_ -notmatch "^(Sjabloon:)?Opmaak$" } | Select-Object -Unique
        
        $pageData = [PSCustomObject]@{
            Title = $page.title
            Url = "https://nl.wikibooks.org/wiki/" + ($page.title -replace " ", "_")
            OtherTemplates = $otherTemplates
        }
        
        # Determine if it's a root page
        $isRoot = ($page.title -notmatch "/") -or ($page.title -match "/(Index|_module)$")
        
        if (-not $hasOpmaak) {
            if ($isRoot) {
                $results.RootNoOpmaak.Add($pageData)
            } else {
                $results.SubNoOpmaak.Add($pageData)
            }
        }
        
        if ($otherTemplates.Count -gt 0) {
            $results.OtherTemplates.Add($pageData)
        }
    }
}

Write-Host "Analyzing books..."
Get-ChildItem $booksDir -Directory | ForEach-Object { Analyze-Directory $_.FullName }

Write-Host "Analyzing collections..."
Get-ChildItem $collectionsDir -Directory | ForEach-Object { Analyze-Directory $_.FullName }

# Generate HTML
$html = @"
<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <title>Wikibooks Opmaak Analyse</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; line-height: 1.6; color: #333; max-width: 1200px; margin: 0 auto; padding: 20px; background-color: #f8f9fa; }
        h1 { color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px; }
        h2 { color: #2980b9; margin-top: 40px; background: #e9ecef; padding: 10px; border-radius: 5px; }
        .stats { display: flex; gap: 20px; margin-bottom: 20px; }
        .stat-card { background: white; padding: 15px; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.1); flex: 1; text-align: center; }
        .stat-card .count { font-size: 2em; font-weight: bold; color: #3498db; }
        table { width: 100%; border-collapse: collapse; margin-bottom: 20px; background: white; box-shadow: 0 2px 5px rgba(0,0,0,0.1); }
        th, td { padding: 12px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #3498db; color: white; }
        tr:hover { background-color: #f1f1f1; }
        a { color: #3498db; text-decoration: none; }
        a:hover { text-decoration: underline; }
        .template-tag { display: inline-block; background: #eee; padding: 2px 8px; border-radius: 12px; font-size: 0.85em; margin: 2px; border: 1px solid #ccc; }
    </style>
</head>
<body>
    <h1>Wikibooks Opmaak Analyse Report</h1>
    <div class="stats">
        <div class="stat-card"><div class="count">$($results.RootNoOpmaak.Count)</div> Boeken zonder Opmaak</div>
        <div class="stat-card"><div class="count">$($results.SubNoOpmaak.Count)</div> Subpagina's zonder Opmaak</div>
        <div class="stat-card"><div class="count">$($results.OtherTemplates.Count)</div> Pagina's met andere sjablonen</div>
    </div>

    <h2>1. Boeken & Collecties zonder {{Opmaak}}</h2>
    <table>
        <tr><th>Titel</th><th>Link naar Wikibooks</th></tr>
"@

foreach ($item in ($results.RootNoOpmaak | Sort-Object Title)) {
    $html += "<tr><td>$($item.Title)</td><td><a href='$($item.Url)' target='_blank'>Bekijk op Wiki</a></td></tr>"
}

$html += @"
    </table>

    <h2>2. Subpagina's zonder {{Opmaak}}</h2>
    <table>
        <tr><th>Titel</th><th>Link naar Wikibooks</th></tr>
"@

foreach ($item in ($results.SubNoOpmaak | Sort-Object Title)) {
    $html += "<tr><td>$($item.Title)</td><td><a href='$($item.Url)' target='_blank'>Bekijk op Wiki</a></td></tr>"
}

$html += @"
    </table>

    <h2>3. Pagina's met andere sjablonen</h2>
    <table>
        <tr><th>Titel</th><th>Sjablonen</th><th>Link naar Wikibooks</th></tr>
"@

foreach ($item in ($results.OtherTemplates | Sort-Object Title)) {
    $tags = ""
    foreach ($t in $item.OtherTemplates) {
        $tags += "<span class='template-tag'>$t</span>"
    }
    $html += "<tr><td>$($item.Title)</td><td>$tags</td><td><a href='$($item.Url)' target='_blank'>Bekijk op Wiki</a></td></tr>"
}

$html += @"
    </table>
    <p style='text-align: center; margin-top: 50px; color: #777;'>Gegenereerd op: $(Get-Date)</p>
</body>
</html>
"@

$html | Out-File -FilePath $reportPath -Encoding utf8
Write-Host "Report generated at: $reportPath" -ForegroundColor Green
