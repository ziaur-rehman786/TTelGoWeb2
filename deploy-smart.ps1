# Smart Deployment - Only uploads changed files (REAL data saver!)
# Uses rsync to sync only changed files, not everything
# Usage: .\deploy-smart.ps1

param(
    [string]$PemKeyPath = "C:\Users\Zia\Desktop\Video\ttelgo.pem",
    [string]$ServerUser = "ubuntu",
    [string]$ServerIP = "3.88.101.239",
    [string]$ProjectPath = "C:\Users\Zia\Desktop\TTelGoWeb2"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Smart Deployment (Only Changed Files!)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if PEM key exists
if (-not (Test-Path $PemKeyPath)) {
    Write-Host "ERROR: PEM key file not found!" -ForegroundColor Red
    exit 1
}

Set-Location $ProjectPath

# Build locally
Write-Host "Building locally..." -ForegroundColor Yellow
npm run build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}

# Use rsync to sync only changed files
Write-Host "Syncing only changed files to server..." -ForegroundColor Yellow
Write-Host "This will only upload files that have changed!" -ForegroundColor Green
Write-Host ""

# Convert Windows path to Unix-style for rsync
$distPath = "$ProjectPath\dist".Replace('\', '/').Replace('C:', '/mnt/c').Replace(':', '')

# Use rsync via WSL or directly if available
# rsync options:
# -a: archive mode (preserves permissions, timestamps, etc.)
# -v: verbose
# -z: compress during transfer
# --delete: delete files on server that don't exist locally
# --exclude: exclude patterns
# --progress: show progress

$rsyncCommand = "rsync -avz --delete --exclude='.git' -e `"ssh -i $PemKeyPath -o StrictHostKeyChecking=no`" `"$ProjectPath/dist/`" ${ServerUser}@${ServerIP}:~/TTelGoWeb2/dist-upload/"

# Try using WSL rsync first, fallback to scp if not available
$wslAvailable = $false
try {
    $wslCheck = wsl --list --quiet 2>&1
    if ($LASTEXITCODE -eq 0) {
        $wslAvailable = $true
    }
} catch {
    $wslAvailable = $false
}

if ($wslAvailable) {
    Write-Host "Using WSL rsync (only syncs changed files)..." -ForegroundColor Cyan
    # Convert Windows path to WSL path
    $wslDistPath = $ProjectPath.Replace('C:\', '/mnt/c/').Replace('\', '/') + '/dist'
    
    # Run rsync via WSL
    wsl rsync -avz --delete --exclude='.git' -e "ssh -i /mnt/c/Users/Zia/Desktop/Video/ttelgo.pem -o StrictHostKeyChecking=no" "$wslDistPath/" ${ServerUser}@${ServerIP}:~/TTelGoWeb2/dist-upload/
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "rsync failed, falling back to smart scp..." -ForegroundColor Yellow
        $wslAvailable = $false
    }
}

if (-not $wslAvailable) {
    Write-Host "Using smart file comparison (PowerShell)..." -ForegroundColor Cyan
    Write-Host "Comparing files and uploading only changes..." -ForegroundColor Yellow
    
    # Get list of files in dist
    $localFiles = Get-ChildItem -Path "$ProjectPath\dist" -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Replace("$ProjectPath\dist\", "").Replace('\', '/')
        @{
            Path = $relativePath
            FullPath = $_.FullName
            Size = $_.Length
            LastWrite = $_.LastWriteTime
        }
    }
    
    Write-Host "Found $($localFiles.Count) files locally" -ForegroundColor Gray
    
    # Get list of files on server (if dist-upload exists)
    Write-Host "Checking server files..." -ForegroundColor Gray
    $serverCheck = "test -d ~/TTelGoWeb2/dist-upload && find ~/TTelGoWeb2/dist-upload -type f -exec ls -lh {} \; 2>/dev/null || echo 'NO_DIR'"
    $serverFilesOutput = & ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" $serverCheck
    
    # Parse server files (if directory exists)
    $serverFiles = @{}
    if ($serverFilesOutput -notmatch 'NO_DIR') {
        $serverFilesOutput | ForEach-Object {
            if ($_ -match '\S+\s+\d+\s+\S+\s+\S+\s+(\d+)\s+\S+\s+\d+\s+\S+:\S+\s+(.+)') {
                $size = [int]$matches[1]
                $path = $matches[2].Replace('~/TTelGoWeb2/dist-upload/', '').Trim()
                $serverFiles[$path] = $size
            }
        }
    } else {
        # Create directory if it doesn't exist
        & ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" "mkdir -p ~/TTelGoWeb2/dist-upload"
    }
    
    # Find files that need uploading (new or changed)
    $filesToUpload = @()
    foreach ($file in $localFiles) {
        $needsUpload = $true
        if ($serverFiles.ContainsKey($file.Path)) {
            if ($serverFiles[$file.Path] -eq $file.Size) {
                $needsUpload = $false
            }
        }
        if ($needsUpload) {
            $filesToUpload += $file
        }
    }
    
    Write-Host "Files to upload: $($filesToUpload.Count) out of $($localFiles.Count)" -ForegroundColor Green
    
    if ($filesToUpload.Count -eq 0) {
        Write-Host "No changes detected! Skipping upload." -ForegroundColor Green
    } else {
        # Upload only changed files
        $totalSize = ($filesToUpload | Measure-Object -Property Size -Sum).Sum / 1MB
        Write-Host "Uploading $($filesToUpload.Count) files (~$([math]::Round($totalSize, 2)) MB)..." -ForegroundColor Yellow
        
        foreach ($file in $filesToUpload) {
            $remotePath = "~/TTelGoWeb2/dist-upload/$($file.Path.Replace('\', '/'))"
            $remoteDir = Split-Path $remotePath -Parent
            & ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" "mkdir -p `"$remoteDir`""
            & scp.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$($file.FullPath)" "${ServerUser}@${ServerIP}:$remotePath"
        }
    }
}

# Deploy
Write-Host ""
Write-Host "Deploying to web server..." -ForegroundColor Yellow
$deployCommand = "sudo rm -rf /var/www/ttelgo/* && sudo cp -r ~/TTelGoWeb2/dist-upload/* /var/www/ttelgo/ && sudo chown -R www-data:www-data /var/www/ttelgo && sudo chmod -R 755 /var/www/ttelgo && sudo systemctl reload nginx && echo '✅ SUCCESS!'"
& ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" $deployCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Deployment Successful!" -ForegroundColor Green
    Write-Host "Website: https://www.ttelgo.com" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Data saved: Only uploaded changed files!" -ForegroundColor Green
} else {
    Write-Host "❌ Deployment Failed!" -ForegroundColor Red
    exit 1
}

