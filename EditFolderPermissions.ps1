	#=====>Setting up variable#
	$folder = "<FolderPath>"
	 
	#=====>Change the owner to "BUILTIN/Administrators, in order to grant permissions#
	TAKEOWN /A /F $folder
	 
	#=====>Removing old folder permissions#
	$folderAcl = (Get-ACL $folder).Access
	While($folderAcl -ne $null){
	    $acl = Get-Acl $folder
	    $acl.Access | ForEach{$acl.RemoveAccessRule($_)}
	    $acl | ForEach{$acl.SetAccessRuleProtection($true,$true)}
	    icacls $folder /reset
	    Set-Acl $folder $acl
	    $folderAcl = (Get-ACL $folder).Access
	}
	#=====>Setting up new folder Permissions
	$acl = Get-Acl $folder
	$rule = New-Object  system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow") 
	$acl.SetAccessRule($rule)
	icacls $folder /reset
	Set-Acl $folder $acl
	 
	$acl = Get-Acl $folder
	$rule = New-Object  system.security.accesscontrol.filesystemaccessrule("Everyone","Write,Read,Synchronize","Allow") 
	$acl.SetAccessRule($rule) 
	icacls $folder /reset
	Set-Acl $folder $acl
	 
	#=====>Giving back permissions to "NT AUTHORITY\SYSTEM"#
	icacls $folder /setowner "NT AUTHORITY\SYSTEM"
	 
	#=====>Removing old file permissions#
	$objectsAcl = Get-ChildItem $folder
	ForEach ($object in $objectsAcl){
	    TAKEOWN /A /F $object.FullName
	    $acl = Get-Acl $object.FullName
	    While($acl -ne $null){
	        $acl = Get-Acl $object.FullName
	        $acl.Access | ForEach{$acl.RemoveAccessRule($_)}
	        $acl | ForEach{$acl.SetAccessRuleProtection($true,$true)}
	        icacls $object.FullName /reset
	        Set-Acl $object.FullName $acl
	        $acl = (Get-ACL $object.FullName).Access
	    }
	    #=====>Setting up new file Permissions#
	    $acl = Get-Acl $object.FullName
	    $rule = New-Object  system.security.accesscontrol.filesystemaccessrule("SYSTEM","FullControl","Allow") 
	    $acl.SetAccessRule($rule)
	    icacls $object.FullName /reset
	    Set-Acl $object.FullName $acl
	 
	    $acl = Get-Acl $object.FullName
	    $rule = New-Object  system.security.accesscontrol.filesystemaccessrule("Administrators","FullControl","Allow") 
	    $acl.SetAccessRule($rule)
	    icacls $object.FullName /reset 
	    Set-Acl $object.FullName $acl
	 
	    $acl = Get-Acl $object.FullName
	    $rule = New-Object  system.security.accesscontrol.filesystemaccessrule("NETWORK SERVICE","Write,Read,Synchronize","Allow") 
	    $acl.SetAccessRule($rule)
	    icacls $object.FullName /reset 
	    Set-Acl $object.FullName $acl
	 
	    icacls $object.FullName /setowner "NT AUTHORITY\SYSTEM"
	}
	 
	#=====>Showing results of execution
	$Output = @()
	$Output = $Output + (Get-ACL $Folder)
	ForEach($object in $objectsAcl){
	    $Output = $Output + (Get-ACL $object.FullName)
	}
	$Output | Out-GridView
	 
	#=====>Restart TermService#
	Get-Service -ServiceName TermService | Stop-Service –Force
	Get-Service -ServiceName TermService | Start-Service
