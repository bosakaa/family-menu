# ────────────────────────────────────────────────
#  update-menu.ps1 — оновлення меню (Windows)
#  Запуск: .\update-menu.ps1
#  Або:    .\update-menu.ps1 -File "C:\Downloads\menu.html" -Message "Тиждень 3"
# ────────────────────────────────────────────────

param(
    [string]$File = "",
    [string]$Message = ""
)

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue
Write-Host "   🍽️  Оновлення меню на GitHub Pages    " -ForegroundColor Blue
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Blue

# Перевірка git
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git не знайдено. Встановіть: https://git-scm.com" -ForegroundColor Red
    exit 1
}

# Пошук файлу
if (-not $File) {
    $downloadsPath = "$env:USERPROFILE\Downloads"
    $latestFile = Get-ChildItem "$downloadsPath\menu-*.html" -ErrorAction SilentlyContinue |
                  Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestFile) {
        Write-Host "🔍 Знайдено: $($latestFile.FullName)" -ForegroundColor Yellow
        $confirm = Read-Host "   Використати? (Enter = так, або введіть шлях)"
        $File = if ($confirm) { $confirm } else { $latestFile.FullName }
    } else {
        $File = Read-Host "📂 Вкажіть шлях до HTML файлу"
    }
}

if (-not (Test-Path $File)) {
    Write-Host "❌ Файл не знайдено: $File" -ForegroundColor Red
    exit 1
}

# Коментар
if (-not $Message) {
    $week = Get-Date -UFormat "%V"
    $year = Get-Date -Format "yyyy"
    $date = Get-Date -Format "dd.MM.yyyy"
    $Message = "🍽️ Меню тиждень $week/$year ($date)"
    Write-Host "📝 Коментар: $Message" -ForegroundColor Yellow
    $custom = Read-Host "   Змінити? (Enter = залишити)"
    if ($custom) { $Message = $custom }
}

# Копіюємо файл
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "`n📋 Копіюємо меню..." -ForegroundColor Blue
Copy-Item $File "$scriptDir\index.html" -Force
Write-Host "✅ index.html оновлено" -ForegroundColor Green

# Оновлюємо HISTORY.md
$dateTime = Get-Date -Format "dd.MM.yyyy HH:mm"
Add-Content "$scriptDir\HISTORY.md" "- **$dateTime** — $Message"
Write-Host "✅ Історія оновлена" -ForegroundColor Green

# Git push
Write-Host "`n🚀 Публікуємо на GitHub..." -ForegroundColor Blue
Set-Location $scriptDir
git add index.html HISTORY.md
git commit -m $Message
git push

Write-Host "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "   ✅ Готово! Меню опубліковано          " -ForegroundColor Green
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor Green
Write-Host "⏱️  Оновлення на сайті займе ~1-2 хвилини" -ForegroundColor Yellow
