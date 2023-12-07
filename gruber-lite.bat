mkdir base\new
C:\Windows\System32\wbem\wmic.exe bios get serialnumber > base\new\serial.txt
C:\Windows\System32\wbem\wmic.exe computersystem get "Model","Manufacturer", "Name", "UserName" > base\new\info.txt
C:\Windows\System32\wbem\wmic.exe bios get serialnumber >> base\new\info.txt
C:\Windows\System32\wbem\wmic.exe nic where PhysicalAdapter=True get MACAddress,Name >> base\new\info.txt
C:\Windows\System32\wbem\wmic.exe NICCONFIG where IPEnabled=True get Caption,IPAddress,MACAddress >> base\new\info.txt
C:\Windows\System32\wbem\wmic.exe UserAccount where "Disabled=FALSE" get Caption,Name >> base\new\info.txt
tool\USBDeview_x32.exe /stext base\new\usb.txt
tool\NetworkInterfacesView_x32.exe /stext base\new\net1.txt
tool\WifiHistoryView.exe /stext base\new\net2.txt
start /wait tool\ESETLogCollector.exe /accepteula /Age:30 /NoTargets:Fw base\new\eset-log.zip
tool\WinAudit.exe /r=gsoPxuTUeERNtnzDaIbMpmidcSArHG /f=base\new\audit.html /L=en
pause