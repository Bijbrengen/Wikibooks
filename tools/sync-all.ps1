$repoRoot = (Resolve-Path ".").Path
$toolsDir = Join-Path $repoRoot "wikibooks/tools"
$booksDir = Join-Path $repoRoot "wikibooks/books"
$collectionsDir = Join-Path $repoRoot "wikibooks/collections"

$syncBookScript = Join-Path $toolsDir "sync-wikibook.ps1"
$syncPagesScript = Join-Path $toolsDir "sync-wikipages.ps1"

Write-Host "--- Syncing Books ---" -ForegroundColor Cyan
Get-ChildItem $booksDir -Directory | ForEach-Object {
    $manifestPath = Join-Path $_.FullName "_manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath | ConvertFrom-Json
        $title = $manifest.title
        if ($title) {
            Write-Host "Syncing Book: $title" -ForegroundColor Yellow
            & $syncBookScript -Title $title -OutputRoot "wikibooks/books"
        }
    }
}

Write-Host "--- Syncing Collections ---" -ForegroundColor Cyan
Get-ChildItem $collectionsDir -Directory | ForEach-Object {
    $manifestPath = Join-Path $_.FullName "_manifest.json"
    if (Test-Path $manifestPath) {
        $manifest = Get-Content $manifestPath | ConvertFrom-Json
        if ($manifest.list) {
            Write-Host "Syncing Collection from list: $($_.Name)" -ForegroundColor Yellow
            $relativePath = $_.FullName.Replace($repoRoot, "").TrimStart("\")
            & $syncPagesScript -ListPath $manifest.list -OutputRoot $relativePath
        } elseif ($manifest.title) {
            Write-Host "Syncing Collection by title: $($manifest.title)" -ForegroundColor Yellow
            $relativePath = $_.FullName.Replace($repoRoot, "").TrimStart("\")
            & $syncBookScript -Title $manifest.title -OutputRoot $relativePath
        }
    }
}

Write-Host "--- Sync Complete ---" -ForegroundColor Green
