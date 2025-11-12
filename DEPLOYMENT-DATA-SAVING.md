# Data-Efficient Deployment Guide

## Problem
The regular deployment scripts run `npm install` on the server every time, which downloads packages and consumes mobile data (can be 100-500MB per deployment).

## Solution
Use these new data-efficient deployment scripts that build locally and only upload the built files.

---

## 🚀 Recommended: `deploy-ultra-quick.ps1` (BEST for saving data)

**Data Usage:** ~500KB - 1MB per deployment (only uploads built files)

**How it works:**
1. Builds the project locally (uses your WiFi/local internet)
2. Uploads only the `dist` folder to server (~500KB-1MB)
3. Deploys on server (no npm install needed!)

**Usage:**
```powershell
.\deploy-ultra-quick.ps1
```

**When to use:**
- ✅ You've already committed and pushed to git
- ✅ You want to save mobile data
- ✅ You're on mobile hotspot and want minimal data usage

---

## 📦 Alternative: `deploy-data-efficient.ps1` (More detailed)

**Data Usage:** ~500KB - 1MB per deployment

**How it works:**
- Same as ultra-quick but with more detailed output
- Shows progress for each step
- Better error messages

**Usage:**
```powershell
.\deploy-data-efficient.ps1
```

---

## ⚡ Updated: `deploy-quick.ps1` (Optimized)

**Data Usage:** Variable (only downloads npm packages if package.json changed)

**How it works:**
- Skips `npm install` if package.json hasn't changed
- Uses `npm ci` (faster, more reliable) when needed
- Still builds on server but avoids unnecessary downloads

**Usage:**
```powershell
.\deploy-quick.ps1
```

**When to use:**
- ✅ You want server-side builds
- ✅ Package.json hasn't changed (saves data)
- ✅ You prefer traditional deployment flow

---

## 📊 Data Usage Comparison

| Script | Data Usage | When npm install runs |
|--------|------------|----------------------|
| `deploy-ultra-quick.ps1` | **~500KB-1MB** | ❌ Never (builds locally) |
| `deploy-data-efficient.ps1` | **~500KB-1MB** | ❌ Never (builds locally) |
| `deploy-quick.ps1` (updated) | **~500KB-1MB** (if no changes) | Only if package.json changed |
| `deploy-quick.ps1` (old) | **100-500MB** | Every time |

---

## 💡 Tips to Save More Data

1. **Use WiFi when building locally:**
   - Connect to WiFi before running `deploy-ultra-quick.ps1`
   - The build happens locally, so it uses WiFi
   - Only the upload uses mobile data (~500KB-1MB)

2. **Build once, deploy multiple times:**
   - If you need to fix server issues, you can re-upload the same dist folder
   - No need to rebuild if code hasn't changed

3. **Check your connection:**
   - Use `.\deploy-ultra-quick.ps1` when on mobile hotspot
   - Use regular scripts when on WiFi (doesn't matter)

---

## 🔧 Troubleshooting

### "SCP command not found"
- Make sure OpenSSH is installed on Windows
- Usually comes pre-installed on Windows 10/11

### "Build failed locally"
- Make sure you have node_modules installed locally
- Run `npm install` once on WiFi, then use the scripts

### "Upload failed"
- Check your internet connection
- Verify PEM key path is correct
- Make sure server is accessible

---

## 📝 Quick Reference

**For maximum data savings:**
```powershell
.\deploy-ultra-quick.ps1
```

**For detailed output:**
```powershell
.\deploy-data-efficient.ps1
```

**For traditional deployment (optimized):**
```powershell
.\deploy-quick.ps1
```

