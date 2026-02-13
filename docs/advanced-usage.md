# Advanced Usage

## Customizing the Default File

Edit your profile and change:

```
param([string]$file = "your-default-file.txt")
```

### Backup to Different Directory

Add a destination parameter:

```
param(
    [string]$file = "sample.py",
    [string]$destination = ".\backups"
)
```

###  Batch Backup Multiple Files

```
function backup-multiple {
    param([string[]]$files)
    foreach ($f in $files) {
        backup-file -file $f
    }
}
```

### Integration with Git

```
function backup-and-commit {
    param([string]$file = "sample.py")
    $newFile = backup-file -file $file
    git add $newFile
    git commit -m "Backup: $newFile"
}
```

