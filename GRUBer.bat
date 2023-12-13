@echo off
@chcp 65001>nul

@rem если вдруг не работает wmic
@REM SET PATH="C:\Windows\System32\wbem\;%PATH%"

@REM переменые даты и времени
for /f "tokens=2 delims==" %%a in ('C:\Windows\System32\wbem\wmic.exe OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%" & set "ministamp=%DD%.%MM%.%YY%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"

@REM ручной ввод данных
set /p "num=Number PC: "
set /p "dep=Viddil: "
set /p "cat=Kategoria: "
set /p "respp=Vidpovidalniy: "
for /f "usebackq tokens=2 delims==" %%i in (`C:\Windows\System32\wbem\wmic.exe bios get serialnumber /value`) do set serial=%%i
@REM FOR /F "usebackq" %%a IN (`tool\GetInfo.exe`) DO set "serial=%%a"
set age=30
set "dir=[%num%]"
set "dirF=[%num%][%ministamp%]%dep%#%serial%#%cat%"

@REM удаление пробелов в переменной dir
set dirF=%dirF: =%

@REM создание папки для данных
echo. & echo ============================================ & echo.
echo Create new dir "base\%dir%"...
if not exist base mkdir base
mkdir base\%dir% & echo COMPLETE! & echo.

@REM сбор данных
echo Save devices stat to fille...
wmic computersystem get "Manufacturer"/format:list > base\%dir%\info.txt
wmic computersystem get "Model" /format:list >> base\%dir%\info.txt
wmic computersystem get "Name"/format:list >> base\%dir%\info.txt
wmic bios get serialnumber /format:list >> base\%dir%\info.txt
wmic nic where PhysicalAdapter=True get MACAddress,Name >> base\%dir%\info.txt
wmic NICCONFIG where IPEnabled=True get Caption,IPAddress,MACAddress >> base\%dir%\info.txt
wmic UserAccount where "Disabled=FALSE" get Caption,Name >> base\%dir%\info.txt

echo %respp% > base\%dir%\descr.txt
C:\Windows\System32\wbem\wmic.exe bios get serialnumber > base\%dir%\serial.txt & echo COMPLETE! & echo.

echo Scan remote devices stat..
tool\USBDeview_x32.exe /stext base\%dir%\usb.txt & echo COMPLETE! & echo.

echo Scan net stat...
tool\NetworkInterfacesView_x32.exe /stext base\%dir%\net1.txt
tool\WifiHistoryView.exe /stext base\%dir%\net2.txt & echo COMPLETE! & echo.

echo ESET LogCollector run...
start /wait cmd.exe /c "start /wait tool\ESETLogCollector.exe /accepteula /Lang:UKR /Age:%age% /NoTargets:Fw base\%dir%\eset-log.zip"
echo COMPLETE! & echo.

echo Scan pc sys stat...
tool\WinAudit.exe /r=gsoPxuTUeERNtnzDaIbMpmidcSArHG /f=base\%dir%\audit.html /L=en
echo ALL COMPLETE!!! & echo.

rename base\%dir% %dirF%

pause