# ============================================
# ADD TO EXISTING PROFILE
# ============================================
# Copy everything below this line and paste at the END of your existing profile
# ============================================

# --- BACKUP-FILE FUNCTION START ---
```
function backup-file {
    param([string]$file = "sample.py")
    
    if (-not (Test-Path $file)) {
        Write-Host "File not found: $file" -ForegroundColor Red
        return
    }
    
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $extension = [System.IO.Path]::GetExtension($file)
    $dateStr = Get-Date -Format 'yyyyMMdd_HHmmss'
    
    $pattern = "$baseName" + "_\d{8}_\d{6}_(\d+)" + [regex]::Escape($extension) + "$"
    $existing = Get-ChildItem -File | Where-Object { $_.Name -match $pattern }
    
    $version = 1
    if ($existing) {
        $versions = $existing | ForEach-Object { 
            [int]($_.Name -replace ".*_(\d+)$([regex]::Escape($extension))",'$1') 
        }
        $version = ($versions | Measure-Object -Maximum).Maximum + 1
    }
    
    $newName = "$baseName`_$dateStr`_$($version.ToString("00"))$extension"
    
    if ($newName -eq $file) {
        Write-Host "Cannot overwrite original file" -ForegroundColor Red
        return
    }
    
    Copy-Item $file $newName
    Write-Host "Created: $newName" -ForegroundColor Green
}

Set-Alias -Name bf -Value backup-file
```
# --- BACKUP-FILE FUNCTION END ---
