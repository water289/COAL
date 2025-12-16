# Clean Build Script
# Removes all build artifacts (.obj, .exe, .lst, .pdb, .ilk, .map)

Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Cleaning Build Artifacts" -ForegroundColor Cyan
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Define file types to remove
$extensions = @("*.obj", "*.lst", "*.pdb", "*.ilk", "*.map")

# Remove from root directory
Write-Host "Cleaning root directory..." -ForegroundColor Yellow
foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path . -Filter $ext -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force
        Write-Host "  Removed: $($file.Name)" -ForegroundColor Gray
    }
}

# Remove from src directory
Write-Host "Cleaning src directory..." -ForegroundColor Yellow
foreach ($ext in $extensions) {
    $files = Get-ChildItem -Path .\src -Filter $ext -ErrorAction SilentlyContinue
    foreach ($file in $files) {
        Remove-Item $file.FullName -Force
        Write-Host "  Removed: $($file.Name)" -ForegroundColor Gray
    }
}

# Optionally remove executables from bin
$removeExe = Read-Host "`nRemove executables from bin directory? (y/N)"
if ($removeExe -eq 'y' -or $removeExe -eq 'Y') {
    Write-Host "Cleaning bin directory..." -ForegroundColor Yellow
    $exeFiles = Get-ChildItem -Path .\bin -Filter "*.exe" -ErrorAction SilentlyContinue
    foreach ($file in $exeFiles) {
        Remove-Item $file.FullName -Force
        Write-Host "  Removed: $($file.Name)" -ForegroundColor Gray
    }
}

Write-Host ""
Write-Host "============================================" -ForegroundColor Green
Write-Host "  Cleanup Complete!" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Green
