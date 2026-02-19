@echo off
:: Request Admin Privileges and run PowerShell script in the same folder
setlocal
set "scriptPath=%~dp0theme-service.ps1"
powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Process -FilePath 'powershell.exe' -ArgumentList '-NoExit','-ExecutionPolicy','Bypass','-File','\"%scriptPath%\"' -Verb RunAs"
endlocal
exit /b
