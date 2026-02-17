![PowerShell](https://img.shields.io/badge/PowerShell-5.1+-blue)
![Platform](https://img.shields.io/badge/Platform-Windows_10|11-lightgrey)
![License](https://img.shields.io/badge/License-MIT-green)

# 🎨 ThemeForge

Forge your Windows experience — switch between **Dark Mode** and **Light Mode**, change wallpapers, set lock screen images, and reload Windows Explorer automatically using PowerShell.


## 🚀 Features
- 🌙 Switch Dark / Light Mode
- 🖼️ Change Desktop Wallpaper
- 🔒 Set Lock Screen Image
- 🔄 Reload Windows Explorer
- 🔊 Optional Notification Sound
- 📊 Visual Loading Progress Bar

## ⚠️ Requirements
- Windows 10 / 11
- PowerShell
- Run as Administrator
> Note: The Lock Screen feature may work only on Windows 11 Pro and may not function on some devices due to system restrictions.

## 📦 Installation
Clone the repository:
git clone https://github.com/YOUR-USERNAME/ThemeForge.git or download as ZIP.

Then
1. Navigate into the folder.
2. Double-click `theme-switcher.bat`
3. Click **Yes** when Windows asks for Administrator permission

## 🎛️ Usage
When the script starts, choose:

0 — Dark Mode

1 — Light Mode

Press Enter and wait for the process to complete.

✅ Done!
## 🖼️ Use Your Own Wallpaper
Replace the images inside:
\ThemeForge\wallpaper
### Dark Mode
- Rename your image to:
  `ROG G15.png`
- Must be `.png` or `.jpg`
### Light Mode
- Rename your image to:
  `ROGDARE.jpg`
- Must be `.png` or `.jpg`

Example structure:

```
ThemeForge
├── wallpaper
│   ├── ROG G15.png
│   └── ROGDARE.jpg
├── sounds
│   └── nalak.wav
├── theme-switcher.ps1
└── theme-switcher.bat
```
## 🛡️ Disclaimer

This tool does not bypass or modify Windows activation mechanisms.  
Please activate Windows through official Microsoft channels.
## 📜 License
MIT License © 2026

## 👨‍💻 Author
Created as a PowerShell learning project and shared as open source.
## 🔐 Administrator Permission

The batch file launches PowerShell with Administrator privileges using Windows' built-in UAC prompt.
No UAC bypass techniques are used.
User confirmation is required.

