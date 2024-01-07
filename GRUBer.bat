@REM  GRUBer - версия 0.9 от 07.11.2024
@echo off
@chcp 65001>nul
setlocal EnableDelayedExpansion

@rem если вдруг не работает wmic
@REM SET PATH="C:\Windows\System32\wbem\;%PATH%"

@REM переменые даты и времени
for /f "tokens=2 delims==" %%a in ('C:\Windows\System32\wbem\wmic.exe OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%" & set "ministamp=%DD%.%MM%.%YY%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

@REM ручной ввод данных
set /p "num=Num PC: " & if "%num%" == "" set num=00
set /p "dep=Viddil: " & if "%dep%" == "" set dep=---
set /p "cat=Kategr: " & if "%cat%" == "" set cat=БезК
set /p "res=Vidpov: " & if "%res%" == "" set res=Черговий
echo ============================================ & echo.

for /f "usebackq tokens=2 delims==" %%i in (`C:\Windows\System32\wbem\wmic.exe bios get serialnumber /value`) do set serial=%%i
@REM FOR /F "usebackq" %%a IN (`tool\GetInfo.exe`) DO set "serial=%%a"
set age=30
set "dir=[%num%][date]viddil#serialnumber#kategoriya"
set "dirF=[%num%][%ministamp%]%dep%#%serial%#%cat%"
set dirF=%dirF: =% && set dir=%dir: =%
set "dir=base\%dir%"
set file

@REM удаление пробелов в переменной dir

@REM создание папки для данных
echo Create new dir "%dir%"...
if not exist base mkdir base
if not exist base\[%ministamp%] mkdir base\[%ministamp%]
mkdir %dir% & echo COMPLETE! & echo.

@REM сбор данных
echo Save devices stat to fille...
set file=%dir%\info.txt
C:\Windows\System32\wbem\wmic.exe computersystem get "Manufacturer"/format:list > %file%
C:\Windows\System32\wbem\wmic.exe computersystem get "Model" /format:list >> %file%
C:\Windows\System32\wbem\wmic.exe computersystem get "Name"/format:list >> %file%
C:\Windows\System32\wbem\wmic.exe bios get serialnumber /format:list >> %file%
C:\Windows\System32\wbem\wmic.exe nic where PhysicalAdapter=True get MACAddress,Name >> %file%
C:\Windows\System32\wbem\wmic.exe NICCONFIG where IPEnabled=True get Caption,IPAddress,MACAddress >> %file%
C:\Windows\System32\wbem\wmic.exe UserAccount where "Disabled=FALSE" get Caption,Name >> %file%

set file=%dir%\descr.txt
echo %res% > %file%

set file=%dir%\serial.txt
C:\Windows\System32\wbem\wmic.exe bios get serialnumber > %file% & echo COMPLETE! & echo.

echo Scan remote devices stat..
set file=%dir%\usb.txt
tool\USBDeview_x32.exe /stext %dir%\usb.txt & echo COMPLETE! & echo.

echo Scan net stat...
set file=%dir%\net1.txt
tool\NetworkInterfacesView_x32.exe /stext %dir%\net1.txt
set file=%dir%\net2.txt
tool\WifiHistoryView.exe /stext %dir%\net2.txt & echo COMPLETE! & echo.

choice /c 10 /t 10 /d 0 /m "Run ESET LogCollector and PCsysStat? (1-Yes, 0-No)"
if %errorlevel%==1 (
   set file=%dir%\eset-log.zip
   echo ESET LogCollector run...
   start /wait cmd.exe /c "start /wait tool\ESETLogCollector.exe /accepteula /Lang:UKR /Age:%age% /NoTargets:Fw %dir%\eset-log.zip"
   echo COMPLETE! & echo.

   set file=%dir%\audit.html
   echo Scan PCsysStat...
   tool\WinAudit.exe /r=gsoPxuTUeERNtnzDaIbMpmidcSArHG /f=%dir%\audit.html /L=en
   echo COMPLETE!
)
echo.

echo ALL COMPLETE!!! & echo.

@rename %dir% %dirF%
@move base\%dirF% base\[%ministamp%]\

pause