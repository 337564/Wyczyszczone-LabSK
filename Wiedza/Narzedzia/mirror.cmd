@echo off
:: mirror
:: Synchronizacja LabSK z \\ftp na \\var
:: ato 2021

:: https://ss64.com/nt/robocopy.html
:: https://ss64.com/nt/xcopy.html

SetLocal

xcopy \\ftp\LabSK C:\LabSK /s/e/h/d  /r/k/b /i /o/x  /y

::robocopy \\ftp\LabSK C:\LabSK /MIR /COPYALL /B /DCOPY:T /SL /XO /XJ

::EoF
