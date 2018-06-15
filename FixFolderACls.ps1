#====================> FixMachineKeysV5.ps1 <====================#
 
#=====>Machine Keys path
$Folder = "C:\ProgramData\Microsoft\Crypto\RSA\MachineKeys"
 
#=====>Access Rule set
$SYSTEM = New-Object System.Security.AccessControl.FileSystemAccessRule("SYSTEM","FullControl","Allow") 
$Everyone = New-Object System.Security.AccessControl.FileSystemAccessRule("Everyone","Write,Read,Synchronize","Allow")
$Administrators = New-Object System.Security.AccessControl.FileSystemAccessRule("Administrators","FullControl","Allow")
$NETWORK_SERVICE = New-Object System.Security.AccessControl.FileSystemAccessRule("NETWORK SERVICE","Write,Read,Synchronize","Allow") 
 
#=====>Change the owner to "BUILTIN/Administrators, in order to grant permissions#
TAKEOWN /A /F $Folder /R /D Y
 
#=====>Repairing MachineKeys folder permissions
$FolderAcl = Get-Acl $Folder
While($FolderAcl.Access -ne $null){
    $FolderAcl.Access | %{$FolderAcl.RemoveAccessRule($_)} | Out-Null
    $FolderAcl | %{$FolderAcl.SetAccessRuleProtection($true,$true)}
    Set-Acl $Folder $FolderAcl -Verbose
    $FolderAcl = Get-Acl $Folder
}
$FolderAcl.AddAccessRule($Administrators), $FolderAcl.AddAccessRule($Everyone)
Set-Acl $Folder $FolderAcl -Verbose
 
#=====>Repairing Keys permissions
$Keys = Get-ChildItem $Folder -Force
ForEach($Key in $Keys){
    $KeyAcl = Get-Acl $Key.FullName
    While($KeyAcl.Access -ne $null){
        $KeyAcl.Access | %{$KeyAcl.RemoveAccessRule($_)} | Out-Null
        $KeyAcl | %{$KeyAcl.SetAccessRuleProtection($true,$true)}
        Set-Acl $Key.FullName $KeyAcl
        $KeyAcl = Get-Acl $Key.FullName
    }
    $KeyAcl.AddAccessRule($SYSTEM), $KeyAcl.AddAccessRule($Administrators), $KeyAcl.AddAccessRule($NETWORK_SERVICE)
    Set-Acl $Key.FullName $KeyAcl -Verbose
}
 
ICACLS $Folder /setowner SYSTEM /T
 
#=====>Showing results of execution
$Output = @()
$Output = $Output + (Get-ACL $Folder)
ForEach($Key in $Keys){
    $Output = $Output + (Get-ACL $Key.FullName)
}
$Output | Out-GridView
