
Click **"Commit new file"**

---

### FILE 3: `install/install.ps1` (in install FOLDER)

Navigate to `install/` folder first, then:

**Filename:** `install.ps1`

**Content:**
```powershell
<#
.SYNOPSIS
    Installs the backup-file function to PowerShell profile
.DESCRIPTION
    Automatically detects PowerShell version and installs the backup function
    to the appropriate profile location. Creates profile if it doesn't exist.
.NOTES
    Run as Administrator if you want to install for All Users
#>

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  PowerShell Backup Profile Installer" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check PowerShell version
$psVersion = $PSVersionTable.PSVersion.Major
Write-Host "Detected PowerShell Version: $psVersion" -ForegroundColor Yellow

# Determine profile path based on version
if ($psVersion -ge 6) {
    $profileDir = "$env:USERPROFILE\Documents\PowerShell"
    $profileFile = "$profileDir\Microsoft.PowerShell_profile.ps1"
} else {
    $profileDir = "$env:USERPROFILE\Documents\WindowsPowerShell"
    $profileFile = "$profileDir\Microsoft.PowerShell_profile.ps1"
}

Write-Host "Profile will be installed at:" -ForegroundColor Yellow
Write-Host "  $profileFile" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "Do you want to continue? (Y/N)"
if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "Installation cancelled." -ForegroundColor Red
    exit
}

# Create directory if it doesn't exist
if (-not (Test-Path $profileDir)) {
    Write-Host "Creating profile directory..." -ForegroundColor Yellow
    try {
        New-Item -ItemType Directory -Path $profileDir -Force -ErrorAction Stop | Out-Null
        Write-Host "  Directory created" -ForegroundColor Green
    } catch {
        Write-Host "  Failed to create directory: $_" -ForegroundColor Red
        exit
    }
}

# Check if profile already exists
$profileExists = Test-Path $profileFile
if ($profileExists) {
    Write-Host "Existing profile found!" -ForegroundColor Yellow
    $backupExisting = Read-Host "Create backup of existing profile? (Y/N)"
    if ($backupExisting -eq 'Y' -or $backupExisting -eq 'y') {
        $backupName = "profile_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
        Copy-Item $profileFile "$profileDir\$backupName"
        Write-Host "  Existing profile backed up to: $backupName" -ForegroundColor Green
    }
}

# The function code
$functionCode = @'

# ============================================
# BACKUP-FILE FUNCTION
# ============================================

function backup-file {
    <#
    .SYNOPSIS
        Creates a timestamped backup of a file with auto-incrementing version
    .PARAMETER file
        The file to backup (default: sample.py)
    .EXAMPLE
        backup-file
        backup-file -file "script.ps1"
        bf -file "data.txt"
    #>
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

'@

# Install the function
try {
    if ($profileExists) {
        Add-Content -Path $profileFile -Value "`n`n$functionCode" -Encoding UTF8
        Write-Host "  Function appended to existing profile" -ForegroundColor Green
    } else {
        Set-Content -Path $profileFile -Value $functionCode -Encoding UTF8
        Write-Host "  New profile created with function" -ForegroundColor Green
    }
} catch {
    Write-Host "  Failed to write profile: $_" -ForegroundColor Red
    exit
}

# Set execution policy if needed
$currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
if ($currentPolicy -eq 'Restricted') {
    Write-Host "`nExecution Policy is Restricted." -ForegroundColor Yellow
    $setPolicy = Read-Host "Allow running local scripts? (Y/N)"
    if ($setPolicy -eq 'Y' -or $setPolicy -eq 'y') {
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
            Write-Host "  Execution policy updated" -ForegroundColor Green
        } catch {
            Write-Host "  Failed to update policy (run as Administrator)" -ForegroundColor Red
        }
    }
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "  1. Restart PowerShell" -ForegroundColor White
Write-Host "  2. Type 'bf' or 'backup-file' to test" -ForegroundColor White
Write-Host ""
Write-Host "Profile location:" -ForegroundColor Yellow
Write-Host "  $profileFile" -ForegroundColor Gray
Write-Host ""
pause
