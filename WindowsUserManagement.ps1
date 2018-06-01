#Setup the variables#
$UserName = "username"
$Password = "P@ssw0rd1234" #--> 12 or more characters #
 
#Create the user account
$ComputerName = $env:COMPUTERNAME
[ADSI]$ADSIcomp = "WinNT://$ComputerName"
$NewUser = $ADSIcomp.Create("User","$UserName")
 
#Set password on the account 
Try{
    $NewUser.SetPassword("$Password")
    $NewUser.SetInfo()
    Write-Host "The user '$UserName' was created successfully"
}Catch [System.Management.Automation.MethodInvocationException]{
    Write-Warning $Error[0].Exception.Message.Split('"')[-2]
    Try{
        $ExistingUser = $ADSIcomp.Children|?{$_.Path -eq $NewUser.Path}
        $ExistingUser.SetPassword("$Password")
        $ExistingUser.SetInfo()
        Write-Host "The password for user '$UserName' was changed successfully."
    }Catch [System.Management.Automation.RuntimeException]{
        Write-Warning $Error[0]
    }
}
 
#Add the account to the Groups: "Administartors" & "Remote Desktop Users"
$AdminGroup = "Administrators"
$RDPgroup = "Remote Desktop Users"
Try{
    [ADSI]$UsersGroup = "WinNT://$ComputerName/$AdminGroup,group"
    $UsersGroup.Add($NewUser.path)
    Write-Host "The user $UserName was added to the group '$AdminGroup'."
}Catch [System.Management.Automation.MethodInvocationException]{
    Write-Warning $Error[0].Exception.Message.Split('"')[-2]
}
Try{
    [ADSI]$UsersGroup = "WinNT://$ComputerName/$RDPgroup,group"
    $UsersGroup.Add($NewUser.path)
    Write-Host "The user $UserName was added to the group '$RDPgroup'."
}Catch [System.Management.Automation.MethodInvocationException]{
    Write-Warning $Error[0].Exception.Message.Split('"')[-2]
}