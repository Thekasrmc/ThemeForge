

# --- Check for Administrator Privileges ---
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "`n[!] This script needs to be run as Administrator." -ForegroundColor Red
    Start-Sleep -Seconds 5
    exit
}

# --- Unicode/Emoji Handling (Optional: No-Emoji Mode) ---
$NoEmoji = $false
function E { param($emoji, $text) if ($NoEmoji) { $text } else { "$emoji $text" } }

function Show-LoadingBar {
    param (
        [string]$message,
        [int]$totalSteps,
        [int]$duration
    )

    $stepDuration = $duration / $totalSteps
    Write-Host "$message" -ForegroundColor Yellow

    $progressBarLength = 50
    for ($i = 1; $i -le $totalSteps; $i++) {
        $percent = ($i / $totalSteps) * 100
        $completedLength = [math]::Round(($i / $totalSteps) * $progressBarLength)
        $progress = "=" * $completedLength
        $spaces = " " * ($progressBarLength - $completedLength)
        $percentFormatted = "{0:00}%" -f $percent

        Write-Host -NoNewline "`r$message [${progress}${spaces}] $percentFormatted"
        Start-Sleep -Seconds $stepDuration
    }

    Write-Host ""
    Write-Host "✅ Done!" -ForegroundColor Green
}

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
function Get-Wallpaper($name) {
    foreach ($ext in @("png","jpg")) {
        $file = Get-ChildItem "$scriptDir\wallpaper" -Filter "$name.$ext" -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($file) { return $file.FullName }
    }
    return $null
}

$lightWallpaper = Get-Wallpaper "Light"
$darkWallpaper  = Get-Wallpaper "Dark"
$soundPath = Join-Path $scriptDir "sounds\Notification.wav"

# --- Check if Wallpaper and Sound Files Exist ---
if (-not $lightWallpaper) {
    Write-Host "`n❌ Light wallpaper not found (.jpg or .png) in wallpaper folder" -ForegroundColor Red
    exit
}
if (-not $darkWallpaper) {
    Write-Host "`n❌ Dark wallpaper not found (.jpg or .png) in wallpaper folder" -ForegroundColor Red
    exit
}
if (-not (Test-Path $soundPath)) {
    Write-Host "`n⚠️ Sound file not found: $soundPath" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host (E "🌈" "Wallpaper Theme Switcher by Thekasrmc") -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "\nProgram Steps" -ForegroundColor Yellow
Write-Host "1. Check wallpaper and sound files"
Write-Host "2. Select desired theme (Dark/Light)"
Write-Host "3. Apply Windows theme and wallpaper"
Write-Host "4. Set lock screen image"
Write-Host "5. Reload Explorer"
Write-Host "6. Play notification sound (if available)"
Write-Host "7. Check Windows Activation and remove watermark (if needed)"
Write-Host "----------------------------------------" -ForegroundColor Cyan

Write-Host "\n[1/7] Checking wallpaper and sound files..." -ForegroundColor Yellow
if (-not $lightWallpaper) {
    Write-Host "❌ Light wallpaper not found (.jpg or .png) in wallpaper folder" -ForegroundColor Red
    exit
}
if (-not $darkWallpaper) {
    Write-Host "❌ Dark wallpaper not found (.jpg or .png) in wallpaper folder" -ForegroundColor Red
    exit
}
if (-not (Test-Path $soundPath)) {
    Write-Host "⚠️ Sound file not found: $soundPath" -ForegroundColor Yellow
}

Write-Host "\n[2/7] Select theme (0=Dark, 1=Light)" -ForegroundColor Yellow
Write-Host "   0 - Dark Mode"
Write-Host "   1 - Light Mode"
do {
    $selection = Read-Host "Please type 0 or 1 to choose the theme"
    if ($selection -eq "0") {
        Write-Host (E "⚫" "Dark Mode selected") -ForegroundColor Cyan
        $theme = "dark"
        $wallpaper = $darkWallpaper
        $valid = $true
    } elseif ($selection -eq "1") {
        Write-Host (E "⚪" "Light Mode selected") -ForegroundColor Cyan
        $theme = "light"
        $wallpaper = $lightWallpaper
        $valid = $true
    } else {
        Write-Host "❌ Invalid choice! Please type 0 or 1" -ForegroundColor Red
        $valid = $false
    }
} while (-not $valid)
$useLight = if ($theme -eq "light") { 1 } else { 0 }

Write-Host "\n[3/7] Applying Windows theme and wallpaper..." -ForegroundColor Yellow
Show-LoadingBar "Changing Theme..." 20 2
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Value $useLight
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Value $useLight
$themeKey = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes"
if (Test-Path $themeKey) {
    $themeFile = if ($theme -eq "light") { "C:\Windows\Resources\Themes\themea.theme" } else { "C:\Windows\Resources\Themes\themeb.theme" }
    if (Test-Path $themeFile) {
        Set-ItemProperty -Path $themeKey -Name "CurrentTheme" -Value $themeFile
    }
}

Write-Host (E "🖼️" "Changing wallpaper...") -ForegroundColor Yellow
Show-LoadingBar "Setting Wallpaper..." 20 2
$code = @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
Add-Type $code
[Wallpaper]::SystemParametersInfo(20, 0, $wallpaper, 3)

Write-Host "\n[4/7] Setting lock screen image..." -ForegroundColor Yellow
Show-LoadingBar "Setting Lock Screen..." 20 2
try {
    $registryPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\PersonalizationCSP"
    if (-not (Test-Path $registryPath)) {
        New-Item -Path $registryPath -Force | Out-Null
    }
    New-ItemProperty -Path $registryPath -Name "LockScreenImagePath" -PropertyType String -Value $wallpaper -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "LockScreenImageStatus" -PropertyType DWord -Value 1 -Force | Out-Null
    New-ItemProperty -Path $registryPath -Name "LockScreenImageUrl" -PropertyType String -Value $wallpaper -Force | Out-Null
} catch {
    Write-Host (E "⚠️" "Failed to set Lock Screen. Try running as Administrator.") -ForegroundColor Red
    $logPath = Join-Path $scriptDir "lockscreen_error.log"
    "[$(Get-Date)] Failed to set lock screen to $wallpaper" | Out-File -FilePath $logPath -Append
    Write-Host (E "ℹ️" "Please set the lock screen manually via Windows Settings.") -ForegroundColor Yellow
    Write-Host "   Error logged to $logPath" -ForegroundColor Gray
}

Write-Host "\n[5/7] Reloading Explorer..." -ForegroundColor Yellow
Show-LoadingBar "Reloading Explorer..." 20 2
Stop-Process -Name explorer -Force
Start-Process explorer

Write-Host "\n[6/7] Playing notification sound (if available)..." -ForegroundColor Yellow
if (Test-Path $soundPath) {
    Add-Type -AssemblyName presentationCore
    $player = New-Object system.media.soundplayer
    $player.SoundLocation = $soundPath
    $player.Load()
    $player.Play()
    Start-Sleep -Seconds 0.5
}

Write-Host "\n[7/7] Checking Windows Activation and removing watermark (if needed)..." -ForegroundColor Yellow
$isActivated = (Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.LicenseStatus -eq 1 })
if ($isActivated) {
    Write-Host "[INFO] Windows is ACTIVATED." -ForegroundColor Green
} else {
    Write-Host "[INFO] Windows is NOT activated." -ForegroundColor Red
    Write-Host "[!] Attempting to remove watermark..." -ForegroundColor Yellow
    $regPath = "HKLM:\SYSTEM\CurrentControlSet\Services\svsvc"
    $regName = "Start"
    try {
        if (Test-Path $regPath) {
            Set-ItemProperty -Path $regPath -Name $regName -Value 4
            Write-Host "[+] Watermark removal registry key set. Please restart your PC to apply changes." -ForegroundColor Green
        } else {
            Write-Host "[!] Registry path not found: $regPath" -ForegroundColor Red
        }
    } catch {
        Write-Host "[!] Failed to modify registry. Try running as Administrator." -ForegroundColor Red
    }
}

Write-Host "\n========================================" -ForegroundColor Cyan
Write-Host (E "✅" "All steps completed!") -ForegroundColor Green
Write-Host (E "🎉" "Done!") -ForegroundColor Cyan
Write-Host (E "Please restart your computer"‼️"") -ForegroundColor Yellow
Start-Sleep -Seconds 10
exit
