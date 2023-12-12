@echo off
@chcp 65001>nul

@REM for /f "usebackq delims=" %%A in (`dir base\ /ad /b /s ^| findstr /e /i "eset-log"`) do rd /S /Q %%A

for /f "usebackq delims=" %%I in (`dir base\ /b /s ^| find /i "eset-log.zip"`) do (
   if not exist %%~dpI\eset-log (
      tool\7za.exe x %%I -o%%~dpI\eset-log ESET\Logs\* -r
      for /f "usebackq delims=" %%J in (`dir %%~dpI\eset-log\ESET\Logs\ /b /s ^| find /i ".dat"`) do (
         start /wait tool\ESETLogCollector.exe /accepteula /Lang:UKR /Bin2Txt /All %%J %%~dpIeset-log\%%~nJ.txt
         @REM start /wait tool\ESETLogCollector.exe /accepteula /Lang:UKR /Bin2Xml /All %%J %%~dpIeset-log\%%~nJ.xml
      )
      for /f "usebackq delims=" %%X in (`dir base\ /ad /b /s ^| findstr /e /i "eset-log\ESET"`) do rd /S /Q %%X
   )
)

pause