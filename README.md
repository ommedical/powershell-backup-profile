# 🔧 PowerShell Backup Profile

A PowerShell profile enhancement that adds intelligent file backup functionality with automatic version control.

## ✨ Features

- 🕐 Automatic timestamp (YYYYMMDD_HHMMSS format)
- 🔢 Auto-incrementing version numbers (01, 02, 03...)
- 🛡️ Prevents overwriting original files
- 📁 Works with any file type
- ⚡ Available in every PowerShell session
- 🎯 Simple command: `bf` or `backup-file`

## 🚀 Quick Start

### Option 1: Automatic Install (Recommended)
1. Download `install/install.ps1`
2. Right-click → "Run with PowerShell"
3. Done!

### Option 2: Manual Install
See [install/manual-install.md](install/manual-install.md)

### Option 3: Add to Existing Profile
See [profile-snippets/add-to-existing-profile.ps1](profile-snippets/add-to-existing-profile.ps1)

## 📖 Usage

```powershell
# Backup default file (sample.py)
backup-file
# or
bf

# Backup specific file
backup-file -file "data_engine.py"
bf -file "market_data.db"

# Backup with spaces in name
bf -file "my script.ps1"
```

##📂 Output Format

```
sample_20250212_143052_01.py
sample_20250212_143055_02.py
sample_20250212_143100_03.py
```

##📋 Requirements

###Windows PowerShell 5.1 or PowerShell 7.x
###Windows 10/11 (macOS/Linux compatible with PowerShell Core)

##📚 Documentation

###Installation Guide
###Troubleshooting
###Advanced Usage
