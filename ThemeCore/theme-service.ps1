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

    $stepDuration = ($duration * 1000) / $totalSteps
    Write-Host "$message" -ForegroundColor Yellow

    $progressBarLength = 50
    for ($i = 1; $i -le $totalSteps; $i++) {
        $percent = ($i / $totalSteps) * 100
        $completedLength = [math]::Round(($i / $totalSteps) * $progressBarLength)
        $progress = "=" * $completedLength
        $spaces = " " * ($progressBarLength - $completedLength)
        $percentFormatted = "{0:00}%" -f $percent

        Write-Host -NoNewline "`r$message [${progress}${spaces}] $percentFormatted"
        Start-Sleep -Milliseconds $stepDuration
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
if (-not (Test-Path $soundPath)) {
    Write-Host "`n⚠️ Sound file not found: $soundPath" -ForegroundColor Yellow
}

Write-Host "========================================" -ForegroundColor Cyan
Write-Host (E "🌈" "Wallpaper Theme Switcher by Thekasrmc") -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan

Write-Host "\nProgram Steps" -ForegroundColor Yellow
Write-Host "1. Check wallpaper and sound files"
Write-Host "2. Check Windows Activation"
Write-Host "3. Select desired theme"
Write-Host "4. Set Ambient Lighting"
Write-Host "5. Apply Windows theme"
Write-Host "6. Set lock screen image"
Write-Host "7. Reload Explorer"
Write-Host "8. Play notification sound"
Write-Host "9. Remove watermark (if selected)"
Write-Host "----------------------------------------" -ForegroundColor Cyan

Write-Host "\n[1/9] Checking wallpaper and sound files..." -ForegroundColor Yellow
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


# --- [2/9] Check Windows Activation FIRST ---
Write-Host "\n[2/9] Checking Windows Activation status..." -ForegroundColor Yellow
$isActivated = (Get-CimInstance -ClassName SoftwareLicensingProduct | Where-Object { $_.PartialProductKey -and $_.LicenseStatus -eq 1 })
if ($isActivated) {
    Write-Host "[INFO] Windows is ACTIVATED." -ForegroundColor Green
    $showWatermarkOption = $false
} else {
    Write-Host "[INFO] Windows is NOT activated." -ForegroundColor Red
    $showWatermarkOption = $true
}

# --- [3/9] Select theme and watermark option (if needed) ---

Write-Host "\n[3/9] Select options:" -ForegroundColor Yellow
Write-Host "   0  - Dark"
Write-Host "   1  - Light"
if ($showWatermarkOption) {
    Write-Host "   2  - Remove watermark"
    Write-Host "   02 - Dark + Remove watermark"
    Write-Host "   12 - Light + Remove watermark"
}

do {
    if ($showWatermarkOption) {
        $selection = (Read-Host "Please type 0, 1, 2, 02, or 12").Trim()
        $valid = $selection -match '^(0|1|2|02|12)$'
    } else {
        $selection = (Read-Host "Please type 0 or 1").Trim()
        $valid = $selection -match '^(0|1)$'
    }
    $theme = $null
    $wallpaper = $null
    $doWatermark = $false
    if ($valid) {
        # Theme selection
        if ($selection -eq "0" -or $selection -eq "02") {
            $theme = "dark"
            $wallpaper = $darkWallpaper
            Write-Host (E "⚫" "Dark selected") -ForegroundColor Cyan
        } elseif ($selection -eq "1" -or $selection -eq "12") {
            $theme = "light"
            $wallpaper = $lightWallpaper
            Write-Host (E "⚪" "Light selected") -ForegroundColor Cyan
        }
        # Watermark selection
        if ($selection -eq "2" -or $selection -eq "02" -or $selection -eq "12") {
            $doWatermark = $true
            Write-Host (E "🚫" "Remove watermark selected") -ForegroundColor Cyan
        }
    } else {
        if ($showWatermarkOption) {
            Write-Host "❌ Invalid choice! Please type 0, 1, 2, 02, or 12" -ForegroundColor Red
        } else {
            Write-Host "❌ Invalid choice! Please type 0 or 1" -ForegroundColor Red
        }
    }
} while (-not $valid)

# --- [4/9] Ambient Lighting Option ---
Write-Host "\n[4/9] Ambient Lighting Option" -ForegroundColor Yellow
Write-Host "   0 - Disable Ambient Lighting"
Write-Host "   1 - Enable Ambient Lighting"
do {
    $ambientSelection = Read-Host "Please type 0 (Disable) or 1 (Enable) for Ambient Lighting"
    if ($ambientSelection -eq "0" -or $ambientSelection -eq "1") {
        $ambientValue = [int]$ambientSelection
        $validAmbient = $true
    } else {
        Write-Host "❌ Invalid choice! Please type 0 or 1" -ForegroundColor Red
        $validAmbient = $false
    }
} while (-not $validAmbient)


# Set AmbientLightingEnabled registry value
$ambientRegPath = "HKCU:\Software\Microsoft\Lighting"
if (-not (Test-Path $ambientRegPath)) {
    New-Item -Path $ambientRegPath -Force | Out-Null
}
Try {
    Set-ItemProperty -Path $ambientRegPath -Name "AmbientLightingEnabled" -Value $ambientValue
} catch {
    Write-Host "Failed to set Ambient Lighting registry." -ForegroundColor Red
}



# --- [5/9] Apply theme/wallpaper and/or watermark removal ---
if ($theme) {
    $useLight = if ($theme -eq "light") { 1 } else { 0 }
    Write-Host "\n[5/9] Applying Windows theme and wallpaper..." -ForegroundColor Yellow
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
}

if ($wallpaper) {
    Write-Host (E "🖼️" "Changing wallpaper...") -ForegroundColor Yellow
    Show-LoadingBar "Setting Wallpaper..." 20 2
    $code = @"
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
    if (-not ("Wallpaper" -as [type])) {
        Add-Type $code
    }
    [Wallpaper]::SystemParametersInfo(20, 0, $wallpaper, 3)
}

if ($wallpaper) {
    Write-Host "\n[6/9] Setting lock screen image..." -ForegroundColor Yellow
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
}

Write-Host "\n[7/9] Reloading Explorer..." -ForegroundColor Yellow
Show-LoadingBar "Reloading Explorer..." 20 2
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Start-Sleep -Milliseconds 500
Start-Process explorer.exe

Write-Host "\n[8/9] Playing notification sound (if available)..." -ForegroundColor Yellow
if (Test-Path $soundPath) {
    Add-Type -AssemblyName presentationCore
    $player = New-Object system.media.soundplayer
    $player.SoundLocation = $soundPath
    $player.Load()
    $player.Play()
    Start-Sleep -Seconds 0.5
}
# --- [9/9] Watermark removal (user choice only) ---
Write-Host "\n[9/9] Watermark removal (user choice only)..." -ForegroundColor Yellow
if ($doWatermark) {
    Write-Host "[!] Attempting to remove watermark as requested..." -ForegroundColor Yellow
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
} else {
    Write-Host "[i] Watermark removal not selected. Skipping this step." -ForegroundColor Gray
}

Write-Host "\n========================================" -ForegroundColor Cyan
Write-Host (E "✅" "All steps completed!") -ForegroundColor Green
Write-Host (E "🎉" "Done!") -ForegroundColor Cyan
Write-Host (E "‼️" "Please restart your computer") -ForegroundColor Yellow
Start-Sleep -Seconds 9
exit



