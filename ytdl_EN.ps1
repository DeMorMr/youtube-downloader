# Requires yt-dlp and FFmpeg
# Install (in PowerShell as admin):
#   winget install yt-dlp
#   winget install ffmpeg

function Download-YouTube {
    $url = Read-Host "Enter YouTube video/playlist URL"
    
    Write-Host "`nSelect download format:" -ForegroundColor Cyan
    Write-Host "1. Video (MP4 with audio)"
    Write-Host "2. Audio only (MP3)"
    Write-Host "3. Video only (no audio)"
    $choice = Read-Host "`nYour choice (1-3)"

    $qualityParam = ""
    $height = $null

    if ($choice -eq "1" -or $choice -eq "3") {
        Write-Host "`nSelect video quality:" -ForegroundColor Cyan
        Write-Host "1. Best available (auto)"
        Write-Host "2. 2160p (4K)"
        Write-Host "3. 1440p (2K)"
        Write-Host "4. 1080p (Full HD)"
        Write-Host "5. 720p (HD)"
        Write-Host "6. 480p"
        Write-Host "7. 360p"
        Write-Host "8. 240p"
        Write-Host "9. 144p"
        $qualityChoice = Read-Host "`nQuality selection (1-9)"
        
        switch ($qualityChoice) {
            "1" { $qualityParam = ""; $height = "best" }
            "2" { $qualityParam = "-S res:2160"; $height = "2160p" }
            "3" { $qualityParam = "-S res:1440"; $height = "1440p" }
            "4" { $qualityParam = "-S res:1080"; $height = "1080p" }
            "5" { $qualityParam = "-S res:720"; $height = "720p" }
            "6" { $qualityParam = "-S res:480"; $height = "480p" }
            "7" { $qualityParam = "-S res:360"; $height = "360p" }
            "8" { $qualityParam = "-S res:240"; $height = "240p" }
            "9" { $qualityParam = "-S res:144"; $height = "144p" }
            default { 
                Write-Host "`nWarning: Invalid quality selection! Using best available" -ForegroundColor Yellow
                $qualityParam = ""
                $height = "best"
            }
        }
    }

    $downloadDir = "YouTube_Downloads"
    $audioDir = "$downloadDir\Audio"
    $videoDir = "$downloadDir\Video"
    
    New-Item -ItemType Directory -Path $audioDir -Force | Out-Null
    New-Item -ItemType Directory -Path $videoDir -Force | Out-Null

    switch ($choice) {
        "1" {
            Write-Host "`nDownloading video ($height)..." -ForegroundColor Yellow
            yt-dlp -o "$videoDir/%(title)s.%(ext)s" $qualityParam -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" $url
            $finalPath = $videoDir
        }
        "2" {
            Write-Host "`nConverting to MP3..." -ForegroundColor Yellow
            yt-dlp -x --audio-format mp3 -o "$audioDir/%(title)s.%(ext)s" $url
            $finalPath = $audioDir
        }
        "3" {
            Write-Host "`nDownloading video without audio ($height)..." -ForegroundColor Yellow
            yt-dlp -o "$videoDir/%(title)s.%(ext)s" $qualityParam -f "bestvideo[ext=mp4]" $url
            $finalPath = $videoDir
        }
        default {
            Write-Host "`nError: Invalid format selection!" -ForegroundColor Red
            exit
        }
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✔ Download completed successfully!" -ForegroundColor Green
        Write-Host "Files saved to: $finalPath" -ForegroundColor Cyan
        Invoke-Item $finalPath
    } else {
        Write-Host "`n❌ Download failed!" -ForegroundColor Red
        Write-Host "Possible reasons:" -ForegroundColor Yellow
        Write-Host " - Invalid URL"
        Write-Host " - No internet connection"
        Write-Host " - Update required (run: yt-dlp -U)"
        Write-Host " - Selected quality not available for this video"
    }
}

function Check-Dependencies {
    $deps = @("yt-dlp", "ffmpeg")
    $missing = @()

    foreach ($dep in $deps) {
        if (-not (Get-Command $dep -ErrorAction SilentlyContinue)) {
            $missing += $dep
        }
    }

    if ($missing.Count -gt 0) {
        Write-Host "`n⚠ Required components missing:" -ForegroundColor Red
        $missing | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Yellow
        }
        
        Write-Host "`nInstall using these commands:" -ForegroundColor Cyan
        Write-Host "  winget install yt-dlp" -ForegroundColor Green
        Write-Host "  winget install ffmpeg" -ForegroundColor Green
        
        Write-Host "`nRun PowerShell as administrator and execute the commands above" -ForegroundColor Yellow
        exit
    }
}

Clear-Host
Write-Host "`n🟢 YouTube Downloader PowerShell Script`n" -ForegroundColor Green
Write-Host "Supported formats: MP4 (quality selectable) | MP3 | Video without audio`n" -ForegroundColor Cyan

Check-Dependencies
Download-YouTube

if ($Host.Name -match "ISE") {
    Write-Host "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
