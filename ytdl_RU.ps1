#   winget install yt-dlp
#   winget install ffmpeg

function Download-YouTube {
    $url = Read-Host "Введите URL YouTube видео/плейлиста"
    
    Write-Host "`nВыберите формат загрузки:" -ForegroundColor Cyan
    Write-Host "1. Видео (MP4 с аудио)"
    Write-Host "2. Только аудио (MP3)"
    Write-Host "3. Только видео (без звука)"
    $choice = Read-Host "`nВаш выбор (1-3)"

    $qualityParam = ""
    $height = $null

    if ($choice -eq "1" -or $choice -eq "3") {
        Write-Host "`nВыберите качество видео:" -ForegroundColor Cyan
        Write-Host "1. Наилучшее автоматически"
        Write-Host "2. 2160p (4K)"
        Write-Host "3. 1440p (2K)"
        Write-Host "4. 1080p (Full HD)"
        Write-Host "5. 720p (HD)"
        Write-Host "6. 480p"
        Write-Host "7. 360p"
        Write-Host "8. 240p"
        Write-Host "9. 144p"
        $qualityChoice = Read-Host "`nВаш выбор качества (1-9)"
        
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
                Write-Host "`nОшибка: Некорректный выбор качества! Используется наилучшее" -ForegroundColor Yellow
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
            Write-Host "`nЗагружаю видео ($height)..." -ForegroundColor Yellow
            yt-dlp -o "$videoDir/%(title)s.%(ext)s" $qualityParam -f "bestvideo[ext=mp4]+bestaudio[ext=m4a]/best[ext=mp4]/best" $url
            $finalPath = $videoDir
        }
        "2" {
            Write-Host "`nКонвертирую в MP3..." -ForegroundColor Yellow
            yt-dlp -x --audio-format mp3 -o "$audioDir/%(title)s.%(ext)s" $url
            $finalPath = $audioDir
        }
        "3" {
            Write-Host "`nЗагружаю видео без звука ($height)..." -ForegroundColor Yellow
            yt-dlp -o "$videoDir/%(title)s.%(ext)s" $qualityParam -f "bestvideo[ext=mp4]" $url
            $finalPath = $videoDir
        }
        default {
            Write-Host "`nОшибка: Некорректный выбор формата!" -ForegroundColor Red
            exit
        }
    }

    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n✔ Загрузка завершена успешно!" -ForegroundColor Green
        Write-Host "Файлы сохранены в: $finalPath" -ForegroundColor Cyan
        Invoke-Item $finalPath
    } else {
        Write-Host "`n❌ Ошибка при загрузке!" -ForegroundColor Red
        Write-Host "Возможные причины:" -ForegroundColor Yellow
        Write-Host " - Неправильная ссылка"
        Write-Host " - Отсутствие интернета"
        Write-Host " - Требуется обновление yt-dlp (yt-dlp -U)"
        Write-Host " - Выбранное качество недоступно для этого видео"
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
        Write-Host "`n⚠ Требуются следующие компоненты:" -ForegroundColor Red
        $missing | ForEach-Object {
            Write-Host "  - $_" -ForegroundColor Yellow
        }
        
        Write-Host "`nУстановите их с помощью команд:" -ForegroundColor Cyan
        Write-Host "  winget install yt-dlp" -ForegroundColor Green
        Write-Host "  winget install ffmpeg" -ForegroundColor Green
        
        Write-Host "`nЗапустите PowerShell от имени администратора и выполните команды выше" -ForegroundColor Yellow
        exit
    }
}

Clear-Host
Write-Host "`n🟢 YouTube Downloader PowerShell Script`n" -ForegroundColor Green
Write-Host "Поддерживаемые форматы: MP4 (с выбором качества) | MP3 | Видео без звука`n" -ForegroundColor Cyan

Check-Dependencies
Download-YouTube

if ($Host.Name -match "ISE") {
    Write-Host "`nНажмите любую клавишу для продолжения..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}
