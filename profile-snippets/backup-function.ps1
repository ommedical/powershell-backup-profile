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
