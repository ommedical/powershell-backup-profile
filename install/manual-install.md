# Manual Installation Guide

## Option 1: No Profile Exists

### Step 1: Create Profile Directory
Open PowerShell and run:

```powershell
# For PowerShell 7+
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\PowerShell" -Force

# For Windows PowerShell 5.1
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\WindowsPowerShell" -Force
```

### Step 2: Create Profile File
```
# For PowerShell 7+
$profilePath = "$env:USERPROFILE\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
"" | Out-File $profilePath -Encoding utf8

# For Windows PowerShell 5.1
$profilePath = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"
"" | Out-File $profilePath -Encoding utf8
```

### Step 3: Add the Function
Open the profile in Notepad:

```
notepad $profilePath
```

Copy the code from profile-snippets/backup-function.ps1 and paste it.
Save and close.

### Step 4: Reload Profile

```
. $profilePath
```

## Option 2: Profile Already Exists

### Step 1: Backup Existing Profile (Recommended)

```
$backupPath = "$env:USERPROFILE\Documents\PowerShell\profile_backup_$(Get-Date -Format 'yyyyMMdd_HHmmss').ps1"
Copy-Item $PROFILE $backupPath
Write-Host "Backed up to: $backupPath"
```

### Step 2: Edit Profile

```
notepad $PROFILE
```

### Step 3: Add Function

Scroll to the bottom and paste the code from profile-snippets/add-to-existing-profile.ps1.
Save and close.

### Step 4: Reload

```
. $PROFILE
```

## Option 3: Quick Copy-Paste

Just want the function without files? Copy this into your profile:

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

### Troubleshooting
### "Running scripts is disabled"

Run as Administrator:

```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Profile not loading

Check if file exists:

```
Test-Path $PROFILE
```

```

Click **"Commit new file"**

---

### FILE 6: `profile-snippets/backup-function.ps1` (in profile-snippets FOLDER)

**Filename:** `backup-function.ps1`

**Content:**
```powershell
# ============================================
# BACKUP-FILE FUNCTION
# ============================================
# Add this entire block to your PowerShell profile
# ============================================

function backup-file {
    <#
    .SYNOPSIS
        Creates a timestamped backup of a file with auto-incrementing version number
    .DESCRIPTION
        Backs up any file with format: filename_YYYYMMDD_HHMMSS_VV.ext
        Automatically finds the next version number if backups already exist
    .PARAMETER file
        Path to the file to backup (default: sample.py)
    .EXAMPLE
        backup-file
        Creates backup of sample.py
    .EXAMPLE
        backup-file -file "script.ps1"
        Creates backup of script.ps1
    .EXAMPLE
        bf -file "data.txt"
        Using the alias to backup data.txt
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$false)]
        [string]$file = "sample.py"
    )

    # Verify source file exists
    if (-not (Test-Path -Path $file -PathType Leaf)) {
        Write-Host "File not found: $file" -ForegroundColor Red
        return
    }

    # Extract file components
    $baseName = [System.IO.Path]::GetFileNameWithoutExtension($file)
    $extension = [System.IO.Path]::GetExtension($file)
    $dateStr = Get-Date -Format 'yyyyMMdd_HHmmss'

    # Pattern to match existing backups: filename_YYYYMMDD_HHMMSS_VV.ext
    $pattern = "$baseName" + "_\d{8}_\d{6}_(\d+)" + [regex]::Escape($extension) + "$"
    
    # Find existing backup versions
    $existing = Get-ChildItem -File | Where-Object { $_.Name -match $pattern }

    # Determine next version number
    $version = 1
    if ($existing) {
        $versions = $existing | ForEach-Object { 
            [int]($_.Name -replace ".*_(\d+)$([regex]::Escape($extension))",'$1') 
        }
        $version = ($versions | Measure-Object -Maximum).Maximum + 1
    }

    # Construct new filename
    $newName = "$baseName`_$dateStr`_$($version.ToString("00"))$extension"

    # Safety check: prevent overwriting source
    if ($newName -eq $file) {
        Write-Host "Cannot overwrite original file" -ForegroundColor Red
        return
    }

    # Create the backup
    try {
        Copy-Item -Path $file -Destination $newName -ErrorAction Stop
        Write-Host "Created: $newName" -ForegroundColor Green
        return $newName
    } catch {
        Write-Host "Error creating backup: $_" -ForegroundColor Red
        return $null
    }
}

# Create short alias for convenience
Set-Alias -Name bf -Value backup-file -Description "Quick backup alias"
```

