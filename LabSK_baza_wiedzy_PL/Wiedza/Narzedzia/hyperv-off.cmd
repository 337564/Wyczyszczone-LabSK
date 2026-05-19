@echo off
rem Hyper-V off
:: Wyłączenie wirtualizatora Hyper-V w systemie Windows
:: Wykonać w oknie konsoli DOS (cmd.exe) jako administrator !

bcdedit /set {current} hypervisorlaunchtype off

:: Powoduje reset maszynyi (reboot) !:
shutdown.exe /r
