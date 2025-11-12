# Ultra-Quick Deployment (No Git, No npm install on server)
# Builds locally and uploads only dist folder
# Use this when you've already committed/pushed and want to save data
# Usage: .\deploy-ultra-quick.ps1

param(
    [string]$PemKeyPath = "C:\Users\Zia\Desktop\Video\ttelgo.pem",
    [string]$ServerUser = "ubuntu",
    [string]$ServerIP = "3.88.101.239",
    [string]$ProjectPath = "C:\Users\Zia\Desktop\TTelGoWeb2"
)

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Ultra-Quick Deployment (Data Efficient)" -ForegroundColor Cyan
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

# Smart upload - only changed files
Write-Host "Checking for changed files..." -ForegroundColor Yellow

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

# Get list of files on server
Write-Host "Comparing with server files..." -ForegroundColor Gray
$serverCheck = "test -d ~/TTelGoWeb2/dist-upload && find ~/TTelGoWeb2/dist-upload -type f -exec stat -c '%s %n' {} \; 2>/dev/null | sed 's|~/TTelGoWeb2/dist-upload/||' || echo 'NO_DIR'"
$serverFilesOutput = & ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" $serverCheck

# Parse server files
$serverFiles = @{}
if ($serverFilesOutput -notmatch 'NO_DIR') {
    $serverFilesOutput | ForEach-Object {
        if ($_ -match '^(\d+)\s+(.+)') {
            $size = [int]$matches[1]
            $path = $matches[2].Trim()
            $serverFiles[$path] = $size
        }
    }
} else {
    & ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" "mkdir -p ~/TTelGoWeb2/dist-upload"
}

# Find files that need uploading
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
    Write-Host "✅ No changes detected! Skipping upload." -ForegroundColor Green
} else {
    $totalSize = ($filesToUpload | Measure-Object -Property Size -Sum).Sum / 1MB
    Write-Host "Uploading $($filesToUpload.Count) files (~$([math]::Round($totalSize, 2)) MB)..." -ForegroundColor Yellow
    
    foreach ($file in $filesToUpload) {
        $remotePath = "~/TTelGoWeb2/dist-upload/$($file.Path.Replace('\', '/'))"
        $remoteDir = $remotePath.Substring(0, $remotePath.LastIndexOf('/'))
        & ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" "mkdir -p `"$remoteDir`""
        & scp.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$($file.FullPath)" "${ServerUser}@${ServerIP}:$remotePath"
    }
}

# Deploy
$deployCommand = "sudo rm -rf /var/www/ttelgo/* && sudo cp -r ~/TTelGoWeb2/dist-upload/* /var/www/ttelgo/ && sudo chown -R www-data:www-data /var/www/ttelgo && sudo chmod -R 755 /var/www/ttelgo && sudo systemctl reload nginx && echo '✅ SUCCESS!'"
& ssh.exe -i $PemKeyPath -o StrictHostKeyChecking=no "$ServerUser@$ServerIP" $deployCommand

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Deployment Successful!" -ForegroundColor Green
    Write-Host "Website: https://www.ttelgo.com" -ForegroundColor Cyan
} else {
    Write-Host "❌ Deployment Failed!" -ForegroundColor Red
    exit 1
}

