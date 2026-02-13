# Manual Installation Guide

## Option 1: No Profile Exists

### Step 1: Create Profile Directory
Open PowerShell and run:

```powershell
# For PowerShell 7+
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\PowerShell" -Force

# For Windows PowerShell 5.1
New-Item -ItemType Directory -Path "$env:USERPROFILE\Documents\WindowsPowerShell" -Force
