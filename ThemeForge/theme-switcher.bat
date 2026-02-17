@echo off
:: Request Admin Privileges and run PowerShell script in the same folder
set "scriptPath=%~dp0theme-switcher.ps1"
powershell.exe -Command "Start-Process powershell -ArgumentList '-ExecutionPolicy Bypass -File \"\"%scriptPath%\"\"' -Verb RunAs"
exit
