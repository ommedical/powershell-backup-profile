# Troubleshooting Guide

## Common Issues

### "Cannot be loaded because running scripts is disabled"

**Fix:**
```
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### "File not found" when running backup-file

#### Cause: Default file sample.py doesn't exist.

#### Fix:

```
backup-file -file "yourexistingfile.txt"
```

#### Profile not loading automatically

#### Check:

```
Test-Path $PROFILE
```

#### If false, create it:

```
New-Item -Path $PROFILE -ItemType File -Force
```

#### "Could not find file" when creating profile

#### Fix:

```
$dir = Split-Path $PROFILE -Parent
New-Item -ItemType Directory -Path $dir -Force
```

#### Getting Help
#### 1. Check PowerShell version: $PSVersionTable.PSVersion

#### 2. Verify profile path: $PROFILE

| **URL** | `https://github.com/YOUR_USERNAME/powershell-backup-profile` |

Your repo is ready! Users can now download `install.ps1` and run it to automatically install the backup function to their PowerShell profile.
