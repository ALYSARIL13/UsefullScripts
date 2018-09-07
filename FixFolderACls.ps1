#====================> FixMachineKeysV5.ps1 <====================#
#=====>Machine Keys path
$Folder = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"
#=====>Users and Groups
$Owner = New-Object System.Security.Principal.NTAccount("NT AUTHORITY", "SYSTEM")
#=====>Access Rule set
$SYSTEM = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow") 
$Everyone = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","Write,Read,Synchronize","Allow")
$Administrators = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$NETWORK_SERVICE = New-Object System.Security.AccessControl.FileSystemAccessRule("NETWORK SERVICE","Write,Read,Synchronize","Allow") 
#=====>Change the owner to "BUILTIN/Administrators, in order to grant permissions#
TAKEOWN /A /F $Folder /R /D Y
#=====>Repairing MachineKeys folder permissions
$FolderAcl = Get-Acl $Folder
$FolderAcl.SetOwner($Owner)
$FolderAcl.AddAccessRule($Administrators), $FolderAcl.AddAccessRule($Everyone)
Set-Acl $Folder $FolderAcl -Verbose
#=====>Repairing Keys permissions
$Keys = Get-ChildItem $Folder -Force
ForEach($Key in $Keys){
    $KeyAcl = Get-Acl $Key.FullName
    $KeyAcl.SetOwner($Owner)
    $KeyAcl.AddAccessRule($SYSTEM), $KeyAcl.AddAccessRule($Administrators), $KeyAcl.AddAccessRule($NETWORK_SERVICE), $KeyAcl.AddAccessRule($Everyone)
    Set-Acl $Key.FullName $KeyAcl -Verbose
}
#=====>Restart TermService#
Stop-Service TermService –Force -Verbose
Start-Service TermService -Verbose
