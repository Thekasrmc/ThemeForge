![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Platform](https://img.shields.io/badge/Platform-Windows_10|11-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

# 🎨 ThemeForge

Forge your Windows experience — switch between Dark Mode and Light Mode, change wallpapers, set lock screen images, and reload Windows Explorer automatically using PowerShell.
>**Note:** The tool works on both activated and non-activated Windows installations.

## Features (Latest Version)
- 🌙 Instant Dark / Light Mode switching
- 🖼️ Automatic Desktop & Lock Screen sync
- 💡 Control Windows 11 Dynamic Lighting (On / Off)
- 🧠 Smart image detection (.png priority, fallback to .jpg)
- 🔄 Auto-reload Windows Explorer
- ⚡ One-click launch via .bat (UAC confirmation required)
## ⚡Quick Start

1. Download ZIP from 🌐[Releases](https://github.com/Thekasrmc/ThemeForge/releases)
2. Extract the folder
3. Double-click theme-switcher.bat
4. Click Yes when Windows asks for Administrator permission
5. Select:
- 0 — Dark Mode
- 1 — Light Mode

Wait for the process to complete.

✅ Done!

## ⚠️ Requirements
- Windows 10 / 11
- PowerShell
- Run as Administrator
> **Note:** The Lock Screen feature may work on certain Windows 10/11 editions (Home or Pro) depending on system policies and user permissions. Some devices may restrict lock screen customization. When supported, the lock screen image will match the selected wallpaper.
## 🎛️ Usage
When the script starts, choose:

0 — Dark Mode

1 — Light Mode

Press Enter and wait for the process to complete.

✅ Done!
## 🖼️ Use Your Own Wallpaper
To customize your wallpapers, replace the images inside the folder:
ThemeForge\wallpaper
### Dark Mode
Rename your image to: Dark.png
- Supported formats: `.png` or `.jpg`
### Light Mode
Rename your image to: Light.png
- Supported formats: `.png `or `.jpg`
### Make sure to delete or replace any old images to avoid conflicts. ‼️
Example structure:

```
ThemeForge
├── wallpaper
│   ├── Dark.png
│   └── Light.jpg
├── sounds
│   └── Notification.wav
├── theme-service.ps1
└── theme-switcher.bat
```
## 🛡️ Disclaimer
This tool modifies certain Windows personalization settings. It has been tested on Windows 11 Pro without issues; however, system behavior may vary.

By using this software, you accept full responsibility for any changes made to your system. The developer is not liable for any damages or system issues resulting from its use.

> **Note:**This tool does not bypass or modify Windows activation mechanisms.  
>Please activate Windows through official Microsoft channels.
> 
## 📦 Installation
Clone the repository:
git clone https://github.com/Thekasrmc/ThemeForge.git

Or download from:
### 🌐[Releases](https://github.com/Thekasrmc/ThemeForge/releases)  (Zip)
### Then:
1. Navigate into the folder
2. Double-click theme-switcher.bat
3. Approve Administrator permission when prompted
## 🔐 Administrator Permission
The batch file launches PowerShell with Administrator privileges using Windows’ built-in UAC prompt.
- No UAC bypass techniques are used
- No system exploitation
- User confirmation is always required
## 📜 License
MIT License © 2026

## 👨‍💻 Author
Created as a PowerShell learning project and shared as open source by TechAsRmc.
