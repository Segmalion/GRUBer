@echo off
@chcp 65001>nul
setlocal EnableDelayedExpansion

:: переменые даты и времени
for /f "tokens=2 delims==" %%a in ('C:\Windows\System32\wbem\wmic.exe OS Get localdatetime /value') do set "dt=%%a"
set "YY=%dt:~2,2%" & set "YYYY=%dt:~0,4%" & set "MM=%dt:~4,2%" & set "DD=%dt:~6,2%"
set "HH=%dt:~8,2%" & set "Min=%dt:~10,2%" & set "Sec=%dt:~12,2%"
set "datestamp=%YYYY%%MM%%DD%" & set "timestamp=%HH%%Min%%Sec%" & set "ministamp=%DD%.%MM%.%YY%"
set "fullstamp=%YYYY%-%MM%-%DD%_%HH%-%Min%-%Sec%"
set debag=0

:: MAIN-RUN
set WD=%~dp0
set DIRin=%WD%\base
set OUT=%WD%\outPCtoCSV.txt
call :find
goto :exit

:: JOB
:find
   @REM echo sep =, > %WD%\out.txt
   echo Start fill "out.txt"
   echo ======================================
   echo Номер;Дата;Відділ;Серійний номер;Категорія;Імя АРМ;Коментар>%OUT%
   for /f "usebackq delims=" %%I in (`dir %DIRin% /b /s /ad ^| findstr /i /r "\[.*\]\[.*\]" ^| findstr /i /r /V "eset-log"`) do (
      if debag==1 echo 0
      cd %%I
      if debag==1 echo Start - %%I
      call :findInDirName %%~nxI
      call :findInInfo %%I
      call :findInDescr %%I
      echo DONE - %%~nxI
      echo !number: =!;!date: =!;!dep: =!;!serial: =!;!cat: =!;!name: =!;!descr!>>%OUT%
      if debag==1 echo --------------------------------------
   )
   echo ======================================
   echo ^!^!^! ALL DONE ^!^!^!
   goto :EOF

:findInDirName
	set dir="%1"
	for /f "usebackq delims=[]# tokens=2-6" %%a in ('%dir%') do (
		set number=%%a & set date=%%b & set dep=%%c & set serial=%%d & set cat=%%e
		set cat=!cat:"=!
	)
   if debag==1 echo 1
	goto :EOF
	
:findInInfo
   set doc="%1\info.txt"
   for /f "usebackq delims=" %%K in (`type %doc% ^| findstr /i /r "Name=.*"`) do (
      set name=%%K
      set name=!name:Name=! && set name=!name:~1!
   )
   if debag==1 echo 2
	goto :EOF
   
:findInDescr
   if exist "%1\descr.txt" set doc="%1\descr.txt"
   if exist "%1\coment.txt" set doc="%1\coment.txt"
   set /p descr=<%doc%
   if debag==1 echo %descr%
   goto :EOF

:exit
   cd %WD%
   pause