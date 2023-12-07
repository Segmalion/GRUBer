@ECHO OFF
C:\Windows\System32\wbem\wmic.exe computersystem get "Model","Manufacturer", "Name", "UserName"
echo =======================
C:\Windows\System32\wbem\wmic.exe bios get serialnumber
echo =======================
C:\Windows\System32\wbem\wmic.exe nic where PhysicalAdapter=True get MACAddress,Name
echo =======================
C:\Windows\System32\wbem\wmic.exe NICCONFIG where IPEnabled=True get Caption,IPAddress,MACAddress
echo =======================
C:\Windows\System32\wbem\wmic.exe UserAccount where "Disabled=FALSE" get Caption,Name
slmgr.vbs -dlv
pause