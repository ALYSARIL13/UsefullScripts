#Setup the variables#
$UserName = "UserName" #--> It must contains 4 or more characters #
$Password = 'P@$$w0rd1234' #--> It must contains 12 or more characters #

#Creating the user account
$ComputerName = $env:COMPUTERNAME
[ADSI]$ADSIcomp = "WinNT://$ComputerName"
$NewUser = $ADSIcomp.Create("User","$UserName")

#Setting up password on the user account 
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
        Write-Error $Error[0]
    }
}

#User Groups
$AdminGroup = "Administrators"
$RDPgroup = "Remote Desktop Users"

#Adding the account to the Group:"Administartors"
Try{
    [ADSI]$UsersGroup = "WinNT://$ComputerName/$AdminGroup,group"
    $UsersGroup.Add($NewUser.path)
    Write-Host "The user $UserName was added to the group '$AdminGroup'."
}Catch [System.Management.Automation.MethodInvocationException]{
    $text = $Error[0].Exception.Message.Split('"')[-2].Split(".")[0]
    Write-Warning "$text '$AdminGroup'."
}

#Adding the account to the Group:"Remote Desktop Users"
Try{
    [ADSI]$UsersGroup = "WinNT://$ComputerName/$RDPgroup,group"
    $UsersGroup.Add($NewUser.path)
    Write-Host "The user $UserName was added to the group '$RDPgroup'."
}Catch [System.Management.Automation.MethodInvocationException]{
    $text = $Error[0].Exception.Message.Split('"')[-2].Split(".")[0]
    Write-Warning "$text '$RDPgroup'."
}
