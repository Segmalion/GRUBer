@echo off
@chcp 65001>nul
setlocal EnableDelayedExpansion
call :setESC
set grubver=0.13 & set grubDate=02.04.2024

::===MAIN-RUN===
cls
call :logo
call :variableSystem
call :variableManual
call :createDir
call :collect
call :moveDir
goto :exit

::===JOBS===
:createDir
   for /f "usebackq tokens=2 delims==" %%i in (`C:\Windows\System32\wbem\wmic.exe bios get serialnumber /value`) do set serial=%%i
   @REM FOR /F "usebackq" %%a IN (`tool\GetInfo.exe`) DO set "serial=%%a"
   set age=30
   set "dirT=[%num%][date]viddil#serialnumber#kategoriya"
   set "dirF=[%num%][%ministamp%]%dep%#%serial%#%cat%"
   set dirF=%dirF: =% && set dirT=%dirT: =%
   set "dir=base\temp\%dirT%"
   ::****** создание папки для данных
   if not exist base mkdir base
   if not exist base\temp mkdir base\temp
   if not exist base\[%ministamp%] mkdir base\[%ministamp%]
   mkdir %dir%
   goto :EOF

:collect
   call :cInfo
   call :cCom
   call :cSerial
   call :cUSB
   call :cNET
   call :cEsetAudit
   goto :EOF

:cInfo
   ::****** сбор данных info.txt
   call :setFile info.txt
   echo Save mini devices stat to fille %Esc%[93m%file%%Esc%[0m...
   C:\Windows\System32\wbem\wmic.exe computersystem get "Manufacturer"/format:list > %fDir%
   C:\Windows\System32\wbem\wmic.exe computersystem get "Model" /format:list >> %fDir%
   C:\Windows\System32\wbem\wmic.exe computersystem get "Name"/format:list >> %fDir%
   C:\Windows\System32\wbem\wmic.exe bios get serialnumber /format:list >> %fDir%
   C:\Windows\System32\wbem\wmic.exe nic where PhysicalAdapter=True get MACAddress,Name >> %fDir%
   C:\Windows\System32\wbem\wmic.exe NICCONFIG where IPEnabled=True get Caption,IPAddress,MACAddress >> %fDir%
   C:\Windows\System32\wbem\wmic.exe UserAccount where "Disabled=FALSE" get Caption,Name >> %fDir%
   call :COMPLETE
   goto :EOF

:cCom
   ::****** сбор данных coment.txt
   call :setFile coment.txt
   echo Save coment to fille %Esc%[93m%file%%Esc%[0m...
   echo %com% > %fDir%
   echo %dirF% >> %fDir%
   call :COMPLETE
   goto :EOF

:cSerial
   ::****** сбор данных serial.txt
   call :setFile serial.txt
   echo Save all serial info to fille %Esc%[93m%file%%Esc%[0m...
   call tool\Info.exe >> %fDir%
   call :COMPLETE
   goto :EOF

:cUSB
   ::****** сбор данных usb.txt
   call :setFile usb.txt
   echo Save USBDeview output to fille %Esc%[93m%file%%Esc%[0m..
   tool\USBDeview_x32.exe /stext %fDir%
   call :COMPLETE
   goto :EOF

:cNET
   ::****** сбор данных net1.txt & net2.txt
   call :setFile net1.txt
   echo Save NetworkInterfacesView output to fille %Esc%[93m%file%%Esc%[0m...
   tool\NetworkInterfacesView_x32.exe /stext %fDir%
   call :setFile net2.txt
   echo Scan WifiHistoryView output to fille %Esc%[93m%file%%Esc%[0m...
   tool\WifiHistoryView.exe /stext %fDir%
   call :COMPLETE
   goto :EOF

:cEsetAudit
   ::****** сбор данных eset-log.zip & audit.html
   choice /c 10 /t 10 /d 0 /m "Run ESET LogCollector and PCsysStat? (1-Yes, 0-No)"
   if %errorlevel%==1 (
      call :setFile eset-log.zip
      echo Seve ESET LogCollector to fille %Esc%[93m!file!%Esc%[0m...
      start /wait cmd.exe /c "start /wait tool\ESETLogCollector.exe /accepteula /Lang:UKR /Age:%age% /NoTargets:Fw %WD%%fDir%"
      call :COMPLETE
      call :setFile audit.html
      echo Save WinAudit output to fille %Esc%[93m!file!%Esc%[0m...
      tool\WinAudit.exe /r=gsoPxuTUeERNtnzDaIbMpmidcSArHG /f=%WD%%fDir% /L=en
      call :COMPLETE
   )
   echo %ESC%[92mALL COMPLETE^^!^^!^^!%ESC%[0m & echo.
   goto :EOF

:moveDir
   rename %dir% %dirF% >nul
   move base\temp\%dirF% base\[%ministamp%]\ >nul
   goto :EOF

:setFile
   set file=%1
   set fDir=%dir%\%file%
   goto :EOF

:variableSystem
   ::****** переменые даты и времени
   for /f "tokens=2 delims==" %%a in ('C:\Windows\System32\wbem\wmic.exe OS Get localdatetime /value') do set "dt=%%a"
   set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
   set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
   set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%" & set "ministamp=%DD%.%MM%.%YY%"
   set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
   set WD=%~dp0
   cd %WD%
   goto :EOF

:variableManual
   ::****** ручной ввод данных
   set /p num="  %ESC%[0mNum PC: %ESC%[92m"
   if "%num%"=="" (set num=--)
   set /p "dep=  %ESC%[0mViddil: %ESC%[92m"
   if "%dep%"=="" (set dep=БезВідділу)
   set /p "cat=  %ESC%[0mKategr: %ESC%[92m"
   if "%cat%"=="" (set cat=НТ)
   set /p "com=  %ESC%[0mComent: %ESC%[92m"
   echo %ESC%[0m-------------------------------------
   goto :EOF

:logo
   echo %Esc%[34m=====================================%Esc%[0m
   echo %Esc%[33m=====================================%Esc%[0m
   echo ---  %Esc%[91mGRUBer v.%grubver% (%grubDate%)%Esc%[0m  ---
   echo %Esc%[34m=====================================%Esc%[0m
   echo %Esc%[33m=====================================%Esc%[0m
   goto :EOF

:COMPLETE
   echo %ESC%[92mDONE^^!%ESC%[0m
   echo -------------------------------------
   goto :EOF

:setESC
   for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
   set ESC=%%b
   exit /B 0
   )
   exit /B 0

:exit
   pause