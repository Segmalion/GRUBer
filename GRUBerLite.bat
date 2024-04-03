@echo off
@chcp 65001>nul

set "dir=[num][date]viddil#serialnumber#kategoriya"
set "dir=base\%dir%"

mkdir %dir%

C:\Windows\System32\wbem\wmic.exe bios get serialnumber > %dir%\serial.txt
C:\Windows\System32\wbem\wmic.exe computersystem get "Model","Manufacturer", "Name", "UserName" > %dir%\info.txt
C:\Windows\System32\wbem\wmic.exe bios get serialnumber >> %dir%\info.txt
C:\Windows\System32\wbem\wmic.exe nic where PhysicalAdapter=True get MACAddress,Name >> %dir%\info.txt
C:\Windows\System32\wbem\wmic.exe NICCONFIG where IPEnabled=True get Caption,IPAddress,MACAddress >> %dir%\info.txt
C:\Windows\System32\wbem\wmic.exe UserAccount where "Disabled=FALSE" get Caption,Name >> %dir%\info.txt
tool\USBDeview_x32.exe /stext %dir%\usb.txt
tool\NetworkInterfacesView_x32.exe /stext %dir%\net1.txt
tool\WifiHistoryView.exe /stext %dir%\net2.txt
start /wait tool\ESETLogCollector.exe /accepteula /Age:30 /NoTargets:Fw %dir%\eset-log.zip
tool\WinAudit.exe /r=gsoPxuTUeERNtnzDaIbMpmidcSArHG /f=%dir%\audit.html /L=en

pause