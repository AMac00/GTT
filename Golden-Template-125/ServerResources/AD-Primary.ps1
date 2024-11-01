 Param (

	[parameter(Mandatory=$true)]
	[String]$SystemID,
    [parameter(Mandatory=$true)]
	[String]$DomainName,
    [parameter(Mandatory=$true)]
	[String]$UserName,
    [parameter(Mandatory=$true)]
	[String]$UserPass,
    [parameter(Mandatory=$true)]
	[String]$CustName,
    [parameter(Mandatory=$true)]
	[String]$DnsNatIP,
    [parameter(Mandatory=$true)]
	[String]$KMSHostname,
    [parameter(Mandatory=$true)]
	[String]$ManagementDomain,
    [parameter(Mandatory=$true)]
	[String]$ManagementDomainDNSServers,
    [parameter(Mandatory=$true)]
	[String]$PublicDomain,
    [parameter(Mandatory=$true)]
	[String]$PublicDomainDNSServers,
    [parameter(Mandatory=$true)]
	[String]$GeneralGPOName,
    [parameter(Mandatory=$true)]
	[String]$NTPGPOName,
    [parameter(Mandatory=$true)]
	[String]$SiteGPOPrefix,
    [parameter(Mandatory=$true)]
	[String]$ManagementEnterpriseDomainsGroup,
    [parameter(Mandatory=$true)]
	[String]$ManagementDomainPDC,
    [parameter(Mandatory=$true)]
	[String]$ManagementDomainSecurityGroupPath,
    [parameter(Mandatory=$true)]
	[String]$ADSites,
    [parameter(Mandatory=$true)]
	[String]$ADFSAccountPass,
    [parameter(Mandatory=$false)]
	[String]$MTDomain,
    [parameter(Mandatory=$false)]
	[String]$MTDomainDNSServers
)

$Logfile = "C:\Software\Setup Scripts\AD-Primary.log"
$LogFileTest = Test-Path $Logfile
if (-Not $LogFileTest) {
        New-Item $Logfile -ItemType file
}

Function Write-Log {
    [CmdletBinding()]
    Param(
    [Parameter(Mandatory=$False)]
    [ValidateSet("INFO","WARN","ERROR","FATAL","DEBUG")]
    [String]
    $Level = "INFO",

    [Parameter(Mandatory=$True)]
    [string]
    $Message
    )

    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
    $Line = "$Stamp $Level $Message"
    Add-Content $logfile -Value $Line
    Write-Host $Line
}

Function Failure-Message {
    Write-Output ""
    Write-Log "ERROR" "A failure occurred.  Please review any error messages that exist above."
    Write-Log "WARN" "If you choose to continue without fixing the issue other downstream errors may be encountered"
    
}

Function Press-Enter-To-Continue {
    Write-Host ""
    Write-Host "Press ENTER to continue"
    $continue = Read-Host
}

Function Create-New-Parameter {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Parameter,
        [parameter(Mandatory=$true)]
        [String]$Value,
        [parameter(Mandatory=$false)]
        [Boolean]$Encrypted
        
    )

    $LineToAdd = "$Parameter=$Value"

    $ParametersPath = Test-Path "C:\Software\Setup Scripts\passwords.txt"

    if (-Not $ParametersPath) {
        Write-Log "INFO" "Parameters file doesn't exist. Creating it"
        New-Item "C:\Software\Setup Scripts\passwords.txt" -ItemType file
    }

    if ($Encrypted) {
        Write-Log "INFO" "Creating new parameter.  Name: $Parameter, Value: *******"
    } else {
        Write-Log "INFO" "Creating new parameter.  Name: $Parameter, Value: $Value"
    }

    Get-Content "C:\Software\Setup Scripts\passwords.txt" | Where-Object {$_ -notmatch "$Parameter="} | Set-Content "C:\Software\Setup Scripts\passwords-new.txt"
    $LineToAdd | Add-Content 'C:\Software\Setup Scripts\passwords-new.txt'

    Remove-Item 'C:\Software\Setup Scripts\passwords.txt'
    Rename-Item 'C:\Software\Setup Scripts\passwords-new.txt' 'passwords.txt'
}

Function Delete-Parameter {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Parameter
        
    )

    $ParametersPath = Test-Path "C:\Software\Setup Scripts\parameters.txt"

    if ($ParametersPath) {
        Write-Log "INFO" "Deleting parameter.  Name: $Parameter"

        Get-Content "C:\Software\Setup Scripts\parameters.txt" | Where-Object {$_ -notmatch "$Parameter="} | Set-Content "C:\Software\Setup Scripts\parameters-new.txt"
    
        Remove-Item 'C:\Software\Setup Scripts\parameters.txt'
        Rename-Item 'C:\Software\Setup Scripts\parameters-new.txt' 'parameters.txt'
        
    } else {
        Write-Log "WARN" "Delete parameter was called but the Parameters file doesn't exist.  This could create a downstream issue"
    }

}

Function Get-Parameter {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$ParameterName

    )
        

        if (Test-Path 'C:\Software\Setup Scripts\parameters.txt') {
            Get-Content 'C:\Software\Setup Scripts\parameters.txt' | ForEach-Object {
                
                if ($_ -match "$ParameterName=") {
                
                    $newvar = $_.split("=")
                    
                }
            }
        }

        if ($newvar) {
            $newvar[1]
        } else {
            $null
        }
}

Function Prompt-User-Multiple-Options {
    Param
	(
        [parameter(Mandatory=$true)]
	    [String]$Prompt,
        [parameter(Mandatory=$true)]
	    [String]$NumberOfOptions,
        [parameter(Mandatory=$true)]
	    [String]$Option1,
        [parameter(Mandatory=$true)]
	    [String]$Option2,
        [parameter(Mandatory=$false)]
	    [String]$Option3,
        [parameter(Mandatory=$false)]
	    [String]$Option4,
        [parameter(Mandatory=$false)]
	    [String]$Option5,
        [parameter(Mandatory=$false)]
	    [String]$Option6,
        [parameter(Mandatory=$false)]
	    [String]$Option7,
        [parameter(Mandatory=$false)]
	    [String]$Option8,
        [parameter(Mandatory=$false)]
	    [String]$Option9,
        [parameter(Mandatory=$false)]
	    [String]$Option10
    )
        
    $Answer = $args[0]
    while (!$Done) {
        Write-Host ""
        Write-Host $Prompt
        Write-Host "1) $Option1"
        Write-Host "2) $Option2"
        if ($NumberOfOptions -gt 2) {
            Write-Host "3) $Option3"
        }
        if ($NumberOfOptions -gt 3) {
            Write-Host "4) $Option4"
        }
        if ($NumberOfOptions -gt 4) {
            Write-Host "5) $Option5"
        }
        if ($NumberOfOptions -gt 5) {
            Write-Host "6) $Option6"
        }
        if ($NumberOfOptions -gt 6) {
            Write-Host "7) $Option7"
        }
        if ($NumberOfOptions -gt 7) {
            Write-Host "8) $Option8"
        }
        if ($NumberOfOptions -gt 8) {
            Write-Host "9) $Option9"
        }
        if ($NumberOfOptions -gt 9) {
            Write-Host "10) $Option10"
        }
       
        $Answer = Read-Host
        
        if ($Answer -ge 1 -and $Answer -le $NumberOfOptions) {
            $Done = $true
        }
        
    }

    $Answer
}

Function Collect-Information {
    Param
	(
        [parameter(Mandatory=$true)]
	    [String]$Prompt,
        [parameter(Mandatory=$true)]
		[ValidateSet("Yes", "No")]
		[String]$Confirm

    )

    while ($Done -ne 1) {
        $Answer = $args[0]
        while (!$Answer) {
            Write-Host ""
            Write-Host $Prompt
            $Answer = Read-Host
        }

        if ($Confirm -eq "Yes") {
            Write-Host ""
            Write-Host "You entered: $Answer - Is this correct? Enter 1 or 2"
            $ConfirmSelection = $args[0]
            while ($ConfirmSelection -ne "1" -and $ConfirmSelection -ne "2") {

                Write-Host "1) Yes"
                Write-Host "2) No"
                $ConfirmSelection = Read-Host
            }

            if ($ConfirmSelection -eq 1) {
                $Done = 1
                $Answer
            }

        } else {

            $Done = 1    
            $Answer
        }
        
    }
}

Function New-AD-Install {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$DomainName,
        [parameter(Mandatory=$true)]
	    [String]$NetBiosName,
        [parameter(Mandatory=$true)]
	    [String]$SafeModePassword
    )

    try {
        Import-Module ADDSDeployment

        Install-ADDSForest `
            -CreateDnsDelegation:$false `
            -DatabasePath "D:\Windows\NTDS" `
            -SafeModeAdministratorPassword (ConvertTo-SecureString $SafeModePassword -AsPlainText -Force) `
            -DomainMode "Win2012R2" `
            -DomainName $DomainName `
            -DomainNetbiosName $NetBiosName `
            -ForestMode "Win2012R2" `
            -InstallDns:$true `
            -LogPath "D:\Windows\NTDS" `
            -NoRebootOnCompletion:$true `
            -SysvolPath "D:\Windows\SYSVOL" `
            -Force:$true 

        Write-Log "INFO" "Setting DefaultUserName, DefaultPassword & AutoAdminLogon registry keys"
        Push-Location
        $reglocation = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"
        Set-Location $reglocation
        New-ItemProperty -Path . -Name 'DefaultUserName' -PropertyType 'String' -Value 'Administrator' -Force
        New-ItemProperty -Path . -Name 'DefaultPassword' -PropertyType 'String' -Value 'password@123' -Force
        Set-ItemProperty . 'AutoAdminLogon' '1'
        Pop-Location
    
    } catch {
        Write-Host ""
        Write-Host $_.Exception.Message
        Failure-Message
    }
}

Function Get-Domain-Info {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$DomainName
    )

    $NetBiosNamePos = $DomainName.IndexOf(".")
    $NetBiosName = $DomainName.Substring(0, $NetBiosNamePos)
    
    $DCPath = "DC="
	$OUPath = ""
    $counter = 1
    $DomainName.Split(".") | ForEach { 
        if ($counter -eq "1") {
            $DCPath = "DC="+$_ 
        } else {
            $DCPath = $DCPath+",DC="+$_
        }
        $counter++
    }

    $DomainName
    $NetBiosName
    $DCPath

}

Function Set-Default-DNS-Properties {

    $Result = "Success"
    try {
        Set-DnsServerDiagnostics -EventLogLevel 1
        #$a = (get-dnsserverroothint | where-object {$_.Nameserver.recorddata.nameserver -eq "h.root-servers.net."})
        #$a.IPAddress[0].RecordData.Ipv4address = "198.97.190.53"
        #Set-DnsServerRootHint $a
        Write-Log "INFO" "Successfully set Default DNS Properties"
    } catch {

        Write-Log "ERROR" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
    }

    $Result

}

Function Update-DNSForwarders {

    Param (
        [parameter(Mandatory=$true)]
        [IPAddress[]]$DNSForwarderIPs

    )

    $Result = "Success"

    try {    
        Set-DnsServerForwarder -IPAddress $DNSForwarderIPs -PassThru
        Write-Log "INFO" "Successfully updated DNS Server forwarders"
    } catch {
        Write-Log "ERROR" $_.Exception.Message
        Failure-Message
        $Result = "Failure"

    }

    $Result

}

Function Add-SRV-Record {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$DomainName,
        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Port,
        [parameter(Mandatory=$true)]
	    [String]$Priority,
        [parameter(Mandatory=$true)]
	    [String]$Weight,
        [parameter(Mandatory=$true)]
	    [String]$ZoneName
        
    )

    $Result = "Success"
    try {

        if(Get-DnsServerResourceRecord -Name $Name -ZoneName $ZoneName -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "The SRV record $Name in $ZoneName already exists.  Going to delete and re-add"
            Remove-DnsServerResourceRecord -Name $Name -ZoneName $ZoneName -RRType Srv -Force:$true
        }
        
        Add-DnsServerResourceRecord -Srv -DomainName $DomainName -Name $Name -Port $Port -Priority $Priority -Weight $Weight -ZoneName $ZoneName 
        Write-Log "INFO" "Successfully added SRV record $Name for host $DomainName in $ZoneName"
    } catch {

        Write-Log "ERROR" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
    }

    $Result  
  
}

Function Create-AD-OU {
    
    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Path,
		[parameter(Mandatory=$true)]
	    [Boolean]$ProtectedFromAccidentalDeletion,
		[parameter(Mandatory=$true)]
	    [String]$Description
        
    )

    $Result = "Success"

    try {
        $ou_exists = [adsi]::Exists("LDAP://OU=$Name,$Path")
        
        if($ou_exists) {
            
            Write-Log "INFO" "OU=$Name,$Path already exists.  There is no need to do anything."
        } else {
            New-ADOrganizationalUnit -Name $Name -Path $Path -ProtectedFromAccidentalDeletion $ProtectedFromAccidentalDeletion -Description $Description
            Write-Log "INFO" "Successfully added AD OU $Name in $Path"
        }

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result
    
}

Function Create-AD-Group {
    
    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$GroupScope,
        [parameter(Mandatory=$true)]
	    [String]$Path
        
    )

    $Result = "Success"

    try {
        $group_exists = [adsi]::Exists("LDAP://CN=$Name,$Path")
        
        if($group_exists) {
            
            Write-Log "INFO" "CN=$Name,$Path already exists.  There is no need to do anything."
        } else {
            New-ADGroup -Name $Name -groupscope $GroupScope -path $Path
            Write-Log "INFO" "Successfully added AD Group $Name to $Path"
        }

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result
    
}

Function Create-AD-User {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$GivenName,
        [parameter(Mandatory=$true)]
	    [String]$Surname,
        [parameter(Mandatory=$true)]
	    [Boolean]$PasswordNeverExpires,
        [parameter(Mandatory=$true)]
	    [String]$Path,
        [parameter(Mandatory=$true)]
	    [String]$UserPrincipalName,
        [parameter(Mandatory=$true)]
	    [Boolean]$Enabled,
        [parameter(Mandatory=$true)]
	    [String]$DisplayName,
        [parameter(Mandatory=$false)]
	    [String]$AccountPass
        
    )

    $Result = "Success"

    try {
        $user_exists = [adsi]::Exists("LDAP://CN=$GivenName $Surname,$Path")
        
        if($user_exists) {
            
            Write-Log "INFO" "CN=$GivenName $Surname,$Path already exists.  There is no need to do anything."
        } else {

            if ($AccountPass) {
                $Password = $AccountPass
            }
            else {
                . 'C:\Software\Setup Scripts\New-SWRandomPassword.ps1'
                $Password = New-SWRandomPassword -PasswordLength 20;
            }

            New-ADUser -Name $Name -GivenName $GivenName -Surname $Surname -PasswordNeverExpires $PasswordNeverExpires -Path $Path -UserPrincipalName $UserPrincipalName -Enabled $Enabled -DisplayName $DisplayName -AccountPassword (ConvertTo-SecureString -AsPlainText $Password -Force)
            Rename-ADObject -Identity (Get-ADUser $Name).distinguishedname -newname "$GivenName $Surname"
            
            Create-New-Parameter $Name $Password $true 

            Write-Log "INFO" "Successfully added AD User $Name"
        }

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result
        
}

Function Add-AD-Group-Member {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$GroupName,
        [parameter(Mandatory=$true)]
	    [String]$UserName
        
    )

    $Result = "Success"

    try {

        Add-ADGroupMember $GroupName $UserName
        Write-Log "INFO" "Successfully added $UserName to $GroupName"

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result

}

Function Add-OU-Permissions {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Path,
        [parameter(Mandatory=$true)]
	    [String]$GroupName,
        [parameter(Mandatory=$true)]
	    [String]$ActiveDirectoryRights,
        [parameter(Mandatory=$true)]
	    [String]$AccessControlType,
        [parameter(Mandatory=$true)]
	    [String]$ActiveDirectorySecurityInheritance
    )

    $Result = "Success"

    try {

        $AdminsSysManObj = [ADSI]("LDAP://$Path")
        $Adminsgroup = Get-ADGroup $GroupName
        $Adminssid = [System.Security.Principal.SecurityIdentifier] $Adminsgroup.SID
        $Adminsidentity = [System.Security.Principal.IdentityReference] $Adminssid
        $AdminsadRights = [System.DirectoryServices.ActiveDirectoryRights] $ActiveDirectoryRights
        $Adminstype = [System.Security.AccessControl.AccessControlType] $AccessControlType
        $Adminsinheritancetype = [System.DirectoryServices.ActiveDirectorySecurityInheritance] $ActiveDirectorySecurityInheritance
        $AdminsACE = New-Object System.DirectoryServices.ActiveDirectoryAccessRule $Adminsidentity,$AdminsadRights,$Adminstype,$Adminsinheritancetype
        $AdminsSysManObj.psbase.ObjectSecurity.AddAccessRule($AdminsACE)
        $AdminsSysManObj.psbase.commitchanges()
        Write-Log "INFO" "Successfully added OU Permissions for $GroupName to $Path"

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result

}

Function Remove-Group-Policy-Link {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Target
    )

    $Result = "Success"

    try {
        $GPOId = Get-GPO -Name $Name | select Id
        $GPOId = $GPOId -replace '@{Id=','{'
        $LinkedGPs = Get-ADObject -Identity $Target -Properties gPlink | select gPlink 
     
        if ($LinkedGPs -like "*$GPOId*") {
            Remove-GPLink -Name $Name -Target $Target
            Write-Log "INFO" "Successfully removed group policy link for $Name on $Target"
        } else {
            
            Write-Log "INFO" "Group policy $Name is not linked to $Target.  There is no need to do anything."
        }    

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result
}

Function Add-New-GPO {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Domain
    )

    $Result = "Success"

    try {
        if (Get-GPO -Name $Name -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "GPO $Name already exists.  There is no need to do anything"
        } else {
            New-GPO -Name $Name -Domain $Domain
            Write-Log "INFO" "Successfully added GPO $Name to $Domain"
        }

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result
}

Function Add-New-GPO-Link{
    
    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Target
    )

    $Result = "Success"

    try {
        $GPOId = Get-GPO -Name $Name | select Id
        $GPOId = $GPOId -replace '@{Id=','{'
        $LinkedGPs = Get-ADObject -Identity $Target -Properties gPlink | select gPlink 
     
        if ($LinkedGPs -like "*$GPOId*") {
            
            Write-Log "INFO" "GPO $Name is already linked to $Target.  There is no need to do anything"
        } else {
            New-GPLink -Name $Name -Target $Target
            Write-Log "INFO" "Successfully linked GPO $Name to $Target"
        }    

    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result
}

Function Import-Saved-GPO {
    
    Param (

        [parameter(Mandatory=$true)]
	    [String]$BackupGpoName,
        [parameter(Mandatory=$true)]
	    [String]$TargetName,
        [parameter(Mandatory=$true)]
	    [String]$Path,
        [parameter(Mandatory=$false)]
	    [String]$MigrationFilePath

    )

    $Result = "Success"

    try {
        
        if ($MigrationFilePath) {
            Import-GPO -BackupGpoName $BackupGpoName  -TargetName $TargetName -Path $Path -MigrationTable $MigrationFilePath
        } else {
            Import-GPO -BackupGpoName $BackupGpoName  -TargetName $TargetName -Path $Path
        }
        Write-Log "INFO" "Successfully imported GPO $BackupGpoName to $TargetName from $Path"
    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result

}

Function Add-GPO-Filter {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Expression,
        [parameter(Mandatory=$true)]
	    [String]$Description
    )

    $Result = "Success"


    try {
        Import-Module ActiveDirectory, GPWmiFilter
        if(Get-GPWmiFilter -Name $Name -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "WMI Filter $Name already exists.  Going to delete and re-add"
            Remove-GPWmiFilter -Name $Name
        }
        New-GPWmiFilter -Name $Name -Expression $Expression -Description $Description
        Write-Log "INFO" "Successfully added GP WMI Filter $Name"
    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result

}


Function Link-GPO-Filter {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$GPOName
    )

    $Result = "Success"


    try {
        Import-Module ActiveDirectory, GPWmiFilter
        $GPOFilter = get-gpwmifilter -name $Name
        $GPO = get-gpo -Name $GPOName
        $GPO.WmiFilter = $GPOFilter
        Write-Log "INFO" "Successfully linked GP WMI Filter $Name to $GPOName"
    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"   
    }

    $Result

}

Function Create-AD-Object {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Type,
        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Path
    )

    $Result = "Success"


    try {
        
        if(Get-ADObject -Identity "CN=$Name,$Path" -ErrorAction SilentlyContinue) {
            
            
            Write-Log "INFO" "AD Object CN=$Name,$Path already exists.  There is no need to do anything"
            
        }
        
    } catch {
        
        try {
            New-ADObject -type $Type -name $Name -path $Path
            Write-Log "INFO" "Successfully created AD Object $Name at $Path"
        } catch {
            Write-Log "INFO" $_.Exception.Message
            Failure-Message
            $Result = "Failure"   
        }
    }

    $Result

}

Function Create-AD-Replication-Subnet {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$Site,
        [parameter(Mandatory=$true)]
	    [String]$Location
    )

    $Result = "Success"
    
    try {
        if (Get-ADReplicationSubnet -Identity $Name -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "The AD replication subnet for $Name already exists.  Going to delete and re-add"
            Remove-ADReplicationSubnet -Identity $Name -Confirm:$false
        }
        
    } catch {
        
    }

    try {
        New-ADReplicationSubnet -Name $Name -Site $Site -Location $Location
        Write-Log "INFO" "Successfully created AD Replication Subnet $Name in site $Site for location $Location"
    } catch {
        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
    }

    $Result

}

Function Create-DNS-Reverse-Lookup-Zone {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$NetworkID,
        [parameter(Mandatory=$true)]
	    [String]$ReplicationScope
    )

    $Result = "Success"
    

    try {
        $NetworkIDSplit = $NetworkID.Split(".")
        $ReverseLookupName = $NetworkIDSplit[2]+"."+$NetworkIDSplit[1]+"."+$NetworkIDSplit[0]+".in-addr.arpa"
        
        if (Get-DnsServerZone -Name $ReverseLookupName -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "The DNS reverse lookup zone $ReverseLookupName already exists.  There is no need to do anything"
        } else {
            Add-DNSServerPrimaryZone -NetworkID $NetworkID -ReplicationScope $ReplicationScope
            Write-Log "INFO" "Successfully created DNS reverse lookup zone for $NetworkID with type $ReplicationScope"
        }
        
    } catch {

        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
        
    }

    $Result

}

Function Create-AD-Replication-Site-Link {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Name,
        [parameter(Mandatory=$true)]
	    [String]$SitesIncluded,
        [parameter(Mandatory=$true)]
	    [String]$Cost,
        [parameter(Mandatory=$true)]
	    [String]$ReplicationFrequencyInMinutes
    )

    $Result = "Success"
    
    try {
        if (Get-AdReplicationSiteLink -Filter {Name -eq $Name}) {
            Set-ADReplicationSiteLink -Identity $Name -SitesIncluded @{Add=$SitesIncluded}
            Write-Log "INFO" "Successfully added $SitesIncluded to the $Name site link"
        } else {
            New-ADReplicationSiteLink -Name $Name -SitesIncluded Default-First-Site-Name,$SitesIncluded -Cost $Cost -ReplicationFrequencyInMinutes $ReplicationFrequencyInMinutes
            Write-Log "INFO" "A site link doesn't already exist.  Successfully created $Name site link and added $SitesIncluded to it"
        }
        
    } catch {

        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
        
    }

    $Result

} 

Function Move-AD-Server {
    
    Param (

        [parameter(Mandatory=$true)]
	    [String]$Identity,
        [parameter(Mandatory=$true)]
	    [String]$Site,
        [parameter(Mandatory=$true)]
	    [String]$TargetPath

    )

    $Result = "Success"
    

    try {
       
        Move-ADDirectoryServer -Identity $Identity -Site $Site
        Write-Log "INFO" "Successfully moved $Identity to $Site in AD Sites and Services" 
        Get-ADComputer $Identity | Move-ADObject -TargetPath $TargetPath
        Write-Log "INFO" "Successfully moved $Identity to $TargetPath in AD Users and Computers"  
        
    } catch {

        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
        
    }

    $Result

}

Function Create-KDS-Root-Key {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$EffectiveTime

    )

    $Result = "Success"
    Write-Output ""

    try {

        if(Get-KdsRootKey -ErrorAction SilentlyContinue) {
            Write-Log "INFO" "The KDS Root Key already exists.  There is no need to do anything."
        } else {
            Add-KdsRootKey -EffectiveTime $EffectiveTime
            Write-Log "INFO" "Successfully added KDS Root Key"
        }
        
    } catch {

        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
        
    }

    $Result

}

Function Add-Conditional-Forwader {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$Domain,
        [parameter(Mandatory=$true)]
	    [String]$ReplicationScope,
        [parameter(Mandatory=$true)]
	    [Collections.Arraylist]$MasterServers,
        [parameter(Mandatory=$true)]
	    [String]$ForwarderTimeout
        
    )

    $Result = "Success"

    try {
        if(Get-DnsServerZone -Name $Domain -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "The conditional forwarder for $Domain already exists.  Going to delete and re-add"
            Remove-DnsServerZone -Name $Domain -Force:$true
        }
        Add-DnsServerConditionalForwarderZone -Name $Domain -ReplicationScope $ReplicationScope -MasterServers $MasterServers -ForwarderTimeout $ForwarderTimeout
        Write-Log "INFO" "Successfully added the conditional forwarder for $Domain"
    } catch {

        
        Write-Log "ERROR" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
    }

    $Result
  
}

Function New-ADDomainTrust {

	Param
	(
        [parameter(Mandatory=$true)]
		[String]$RemoteUser,
        [parameter(Mandatory=$true)]
		[String]$RemotePassword,
		[parameter(Mandatory=$true)]
		[String]$RemoteDomain,
		[parameter(Mandatory=$true)]
		[ValidateSet("Inbound", "Outbound", "Bidirectional")]
		[String]$TrustDirection
	)

    $localDomain = [System.DirectoryServices.ActiveDirectory.Domain]::GetComputerDomain()

    if($localDomain.GetAllTrustRelationships() | Where TargetName -eq $RemoteDomain) {
        
        Write-Log "INFO" "The $TrustDirection trust already exists to $RemoteDomain.  No action is necessary"
        "Success"
    } else {
        $domaintrusterrorstatus = 0

        try {
            $remoteConnection = New-Object System.DirectoryServices.ActiveDirectory.DirectoryContext('Domain',$RemoteDomain,$RemoteUser,$RemotePassword)
            $remoteDomainConnection = [System.DirectoryServices.ActiveDirectory.Domain]::GetDomain($remoteConnection)
        } catch {
            
            Write-Log "ERROR" $_.Exception.Message
            $domaintrusterrorstatus = 1
        }

        if ($domaintrusterrorstatus -eq 0) {
            try {

                
	            $localDomain.CreateTrustRelationship($remoteDomainConnection,$TrustDirection)

            } catch {
                
                Write-Log "ERROR" $_.Exception.Message
                $domaintrusterrorstatus = 1
            }
        }

        if ($domaintrusterrorstatus -eq 0) {
            Write-Log "INFO" "Successfully created $TrustDirection trust to $RemoteDomain"
            "Success"
        } else {
            Failure-Message
            "Failure"
        }
    }
    
}

Function Get-DomainCredential {

    $GetCredential = Get-Credential
    $GetCredential.GetNetworkCredential().username
    $GetCredential.GetNetworkCredential().password
}


Write-Log "INFO" "**********************************************************************"
Write-Log "INFO" "Starting script"
    
$servername = $env:COMPUTERNAME
$serverFQDN = "$servername.$DomainName"

        
$GetDomainInfo = Get-Domain-Info (Get-WmiObject Win32_ComputerSystem).Domain
$DomainName = $GetDomainInfo[0]
$NetBIOSName = $GetDomainInfo[1]
$DCPath = $GetDomainInfo[2]

Write-Log "INFO" "The Server Name is: $servername"
Write-Log "INFO" "The Server FQDN is: $serverFQDN"
Write-Log "INFO" "The domain is: $DomainName"
Write-Log "INFO" "The NetBIOS name is: $NetBiosName"
Write-Log "INFO" "The DC Path is: $DCPath"
        

Write-Log "INFO" "KMS Host Name:  $KMSHostname"
Write-Log "INFO" "Management Domain:  $ManagementDomain"
Write-Log "INFO" "Management Domain DNS Servers:  $ManagementDomainDNSServers"
Write-Log "INFO" "Public Domain:  $PublicDomain"
Write-Log "INFO" "Public Domain DNS Servers:  $PublicDomainDNSServers"
Write-Log "INFO" "General GPO Name:  $GeneralGPOName"
Write-Log "INFO" "NTP GPO Name:  $NTPGPOName"
Write-Log "INFO" "Site GPO Prefix:  $SiteGPOPrefix"
Write-Log "INFO" "Management Enterprise Domain Group:  $ManagementEnterpriseDomainsGroup"
Write-Log "INFO" "Management Domain PDC:  $ManagementDomainPDC"
Write-Log "INFO" "Management Domain Security Group Path:  $ManagementDomainSecurityGroupPath"

if ($MTDomain -and $MTDomainDNSServers) {

    Write-Log "INFO" "Multi-tenant Domain:  $MTDomain"
    Write-Log "INFO" "Multi-tenant Domain DNS Servers: $MTDomainDNSServers"
    Write-Log "INFO" "Multi-tenant Domain Information has been supplied. Will establish trust and forwarders"
    $SetupMTDomain = $true

}

#--------------------------
#DNS section      

Write-Log "INFO" "Entering DNS Section"
        
$SetDefaultDNSProperties = Set-Default-DNS-Properties       
$AddKMSSRVRecord = Add-SRV-Record $KMSHostname "_VLMCS._tcp" "1688" "0" "0" $DomainName

Write-Log "INFO" "Updating DNS forwarders"
$DNSForwarderIPs = @("8.8.8.8","208.67.222.222","209.244.0.3","64.6.64.6")
$UpdateDNSForwarders = Update-DNSForwarders $DNSForwarderIPs

$ManagementDomainDNSServers = $ManagementDomainDNSServers -replace '\s',''
$ManagementDomainDNSServersFinal = $ManagementDomainDNSServers -split ","
$TempManagementDomainDNSServer = $ManagementDomainDNSServersFinal[0]

$AddManagementDomainConditionalForwarder = Add-Conditional-Forwader $ManagementDomain "Domain" $TempManagementDomainDNSServer "5"
Write-Log "INFO" "This is a temporary conditional forwarder that points to only one DNS. We will delete and re-add the final ones later"

$PublicDomainDNSServers = $PublicDomainDNSServers -replace '\s',''
$PublicDomainDNSServersFinal = $PublicDomainDNSServers -split ","
$TempPublicDomainDNSServer = $PublicDomainDNSServersFinal[0]

$AddPublicDomainConditionalForwarder = Add-Conditional-Forwader $PublicDomain "Domain" $TempPublicDomainDNSServer "5"
Write-Log "INFO" "This is a temporary conditional forwarder that points to only one DNS. We will delete and re-add the final ones later"

#--------------------------
#NTP GPO ONLY Section

$AddGPOFilter = Add-GPO-Filter "PDC Emulator" 'Select * from Win32_ComputerSystem where DomainRole = "5"' "Query for PDC FSMO Role"
$AddNewGPO = Add-New-GPO $NTPGPOName $DomainName
$LinkGPOFilter = Link-GPO-Filter "PDC Emulator" $NTPGPOName
$AddNewGPOLink = Add-New-GPO-Link $NTPGPOName "OU=Domain Controllers,$DCPath"
$ImportGPO = Import-Saved-GPO $NTPGPOName $NTPGPOName "C:\Software\GPO Backups\$NTPGPOName" 
gpupdate /force
w32tm /resync
w32tm /query /status

#--------------------------
#AD Users and Computers section

try {
    Set-ADUser -Identity Administrator -PasswordNeverExpires $true
    Write-Log "INFO" "Successfully set password never expires on domain administrator"
} catch {
    Write-Log "ERROR" "Failed to set password never expires on domain administrator"
}

#

$AddOU = Create-AD-OU "User Accounts" $DCPath -ProtectedFromAccidentalDeletion $true -Description "User Accounts"

$AddOU = Create-AD-OU "Servers" $DCPath -ProtectedFromAccidentalDeletion $true -Description "Servers"
$AddOU = Create-AD-OU "Quarantine" "OU=Servers,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "Workstations"

$AddOU = Create-AD-OU "Workstations" $DCPath -ProtectedFromAccidentalDeletion $true -Description "Workstations"
$AddOU = Create-AD-OU "Quarantine" "OU=Workstations,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "Workstations"

$AddOU = Create-AD-OU "Quarantine" "OU=Domain Controllers,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "Workstations"

$AddOU = Create-AD-OU "Administration" $DCPath -ProtectedFromAccidentalDeletion $true -Description "Administration"

$AddOU = Create-AD-OU "Service Accounts" "OU=Administration,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "Service Accounts"

$AddOU = Create-AD-OU "Security Groups" "OU=Administration,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "Security Groups"

$AddUser = Create-AD-User "app_admin" "App" "Admin" $true "OU=User Accounts,$DCPath" "app_admin@$DomainName" $true "App Admin"

$AddUser = Create-AD-User "svc_ldapread" "LDAP Read" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_ldapread@$DomainName" $true "LDAP Read Service Account"

$AddOU = Create-AD-OU "Cisco_ICM" $DCPath -ProtectedFromAccidentalDeletion $true -Description "Cisco ICM Root"

$AddOU = Create-AD-OU "UCCE" "OU=Cisco_ICM,$DCPath" -ProtectedFromAccidentalDeletion $false -Description "Cisco ICM Facility"
	
$AddOU = Create-AD-OU "pd$SystemID" "OU=UCCE,OU=Cisco_ICM,$DCPath" -ProtectedFromAccidentalDeletion $false -Description "Cisco ICM Instance"
		
$AddOU = Create-AD-OU "sb$SystemID" "OU=UCCE,OU=Cisco_ICM,$DCPath" -ProtectedFromAccidentalDeletion $false -Description "Cisco ICM Instance"   

$AddGroup = Create-AD-Group "ICM Administrators" "DomainLocal" "OU=Security Groups,OU=Administration,$DCPath"
	
$AddOUPermissions = Add-OU-Permissions "OU=Cisco_ICM,$DCPath" "ICM Administrators" "GenericAll" "Allow" "All"

$AddGroup = Create-AD-Group "Cisco_ICM_Config" "DomainLocal" "OU=Cisco_ICM,$DCPath"
	
$AddGroup = Create-AD-Group "Cisco_ICM_Setup" "DomainLocal" "OU=Cisco_ICM,$DCPath"

$AddGroup = Create-AD-Group "UCCE_Config" "DomainLocal" "OU=UCCE,OU=Cisco_ICM,$DCPath"
	
$AddGroup = Create-AD-Group "UCCE_Setup" "DomainLocal" "OU=UCCE,OU=Cisco_ICM,$DCPath"
	
$AddGroup = Create-AD-Group "UCCE_pd$($SystemID)_Config" "DomainLocal" "OU=pd$SystemID,OU=UCCE,OU=Cisco_ICM,$DCPath"
	
$AddGroup = Create-AD-Group "UCCE_pd$($SystemID)_Service" "DomainLocal" "OU=pd$SystemID,OU=UCCE,OU=Cisco_ICM,$DCPath"
	
$AddGroup = Create-AD-Group "UCCE_pd$($SystemID)_Setup" "DomainLocal" "OU=pd$SystemID,OU=UCCE,OU=Cisco_ICM,$DCPath"

$AddGroup = Create-AD-Group "UCCE_sb$($SystemID)_Config" "DomainLocal" "OU=sb$SystemID,OU=UCCE,OU=Cisco_ICM,$DCPath"
	
$AddGroup = Create-AD-Group "UCCE_sb$($SystemID)_Service" "DomainLocal" "OU=sb$SystemID,OU=UCCE,OU=Cisco_ICM,$DCPath"
	
$AddGroup = Create-AD-Group "UCCE_sb$($SystemID)_Setup" "DomainLocal" "OU=sb$SystemID,OU=UCCE,OU=Cisco_ICM,$DCPath"

$AddGroupMember = Add-AD-Group-Member "ICM Administrators" app_admin

$AddOUPermissions = Add-OU-Permissions "OU=Cisco_ICM,$DCPath" "ICM Administrators" "GenericAll" "Allow" "All"

$AddOU = Create-AD-OU "icPortal" "OU=Security Groups,OU=Administration,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "Portal Security Groups"

$AddGroup = Create-AD-Group "icApps Users" "Global" "OU=icPortal,OU=Security Groups,OU=Administration,$DCPath"

$AddUser = Create-AD-User "svc_icportal_tenant" "icPortal Tenant" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_icportal_tenant@$DomainName" $true "icPortal Tenant Service Account"

$AddUser = Create-AD-User "svc_multichannel" "Multichannel" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_multichannel@$DomainName" $true "Multichannel Service Account"

$AddUser = Create-AD-User "svc_finesse" "Finesse" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_finesse@$DomainName" $true "Finesse Service Account"

$AddUser = Create-AD-User "svc_principalaw" "Principal AW" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_principalaw@$DomainName" $true "Principal AW Service Account"

$AddUser = Create-AD-User "svc_ccdm" "CCDM" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_ccdm@$DomainName" $true "CCDM Service Account"

$AddUser = Create-AD-User "svc_cvpmedia" "CVP Media" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_cvpmedia@$DomainName" $true "CVP Media Service Account"
	
$AddUser = Create-AD-User "svc_UCCE_SideA" "CCE Prod Side A" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_UCCE_SideA@$DomainName" $true "CCE Prod Side A SVC Acct"
	
$AddUser = Create-AD-User "svc_UCCE_SideB" "CCE Prod Side B" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_UCCE_SideB@$DomainName" $true "CCE Prod Side B Service Account"

$AddUser = Create-AD-User "svc_UCCE_Sandbox" "CCE Sandbox" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_UCCE_Sandbox@$DomainName" $true "CCE Sandbox Service Account"

$AddUser = Create-AD-User "svc_adfs" "AD FS" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_adfs@$DomainName" $true "AD FS Service Account" $ADFSAccountPass

$AddUser = Create-AD-User "svc_cust_files" "Cust Files" "Service Account" $true "OU=Service Accounts,OU=Administration,$DCPath" "svc_cust_files@$DomainName" $true "Cust Files Service Account"

$ICMGroupUser = Get-ADGroup -Identity "Cisco_ICM_Setup" -Server $DomainName
Add-ADGroupMember "Cisco_ICM_Config" -Members $ICMGroupUser
Add-ADGroupMember "UCCE_Setup" -Members $ICMGroupUser

$ICMGroupUser = Get-ADGroup -Identity "Cisco_ICM_Config" -Server $DomainName
Add-ADGroupMember "UCCE_Config" -Members $ICMGroupUser

$ICMGroupUser = Get-ADGroup -Identity "UCCE_Setup" -Server $DomainName
Add-ADGroupMember "UCCE_Config" -Members $ICMGroupUser
Add-ADGroupMember "UCCE_pd$($SystemID)_Setup" -Members $ICMGroupUser
Add-ADGroupMember "UCCE_sb$($SystemID)_Setup" -Members $ICMGroupUser

$ICMGroupUser = Get-ADGroup -Identity "UCCE_Config" -Server $DomainName
Add-ADGroupMember "UCCE_pd$($SystemID)_Config" -Members $ICMGroupUser
Add-ADGroupMember "UCCE_sb$($SystemID)_Config" -Members $ICMGroupUser

$ICMGroupUser = Get-ADGroup -Identity "UCCE_pd$($SystemID)_Setup" -Server $DomainName
Add-ADGroupMember "UCCE_pd$($SystemID)_Config" -Members $ICMGroupUser

$ICMGroupUser = Get-ADGroup -Identity "UCCE_sb$($SystemID)_Setup" -Server $DomainName
Add-ADGroupMember "UCCE_sb$($SystemID)_Config" -Members $ICMGroupUser

$ICMGroupUser = Get-ADGroup -Identity "Domain Admins" -Server $DomainName
Add-ADGroupMember "Cisco_ICM_Config" -Members $ICMGroupUser
Add-ADGroupMember "Cisco_ICM_Setup" -Members $ICMGroupUser

$ICMGroupUser = Get-ADGroup -Identity "ICM Administrators" -Server $DomainName
Add-ADGroupMember "Cisco_ICM_Setup" -Members $ICMGroupUser

$AddGroupMember = Add-AD-Group-Member "UCCE_pd$($SystemID)_Config" "svc_ccdm"
$AddGroupMember = Add-AD-Group-Member "UCCE_sb$($SystemID)_Config" "svc_ccdm"

$AddGroupMember = Add-AD-Group-Member "UCCE_pd$($SystemID)_Config" "svc_principalaw"
$AddGroupMember = Add-AD-Group-Member "UCCE_sb$($SystemID)_Config" "svc_principalaw"
$AddGroupMember = Add-AD-Group-Member "UCCE_pd$($SystemID)_Service" "svc_principalaw"
$AddGroupMember = Add-AD-Group-Member "UCCE_sb$($SystemID)_Service" "svc_principalaw"

$AddGroupMember = Add-AD-Group-Member "UCCE_pd$($SystemID)_Setup" "svc_icportal_tenant"
$AddGroupMember = Add-AD-Group-Member "UCCE_sb$($SystemID)_Setup" "svc_icportal_tenant"

$AddGroupMember = Add-AD-Group-Member "UCCE_pd$($SystemID)_Service" "svc_UCCE_SideA"
$AddGroupMember = Add-AD-Group-Member "UCCE_pd$($SystemID)_Service" "svc_UCCE_SideB"
$AddGroupMember = Add-AD-Group-Member "UCCE_sb$($SystemID)_Service" "svc_UCCE_Sandbox"

#--------------------------
#Domain Trusts section
              
$ManagementDomainUserName = $UserName
$ManagementDomainUserPassword = $UserPass

$ManagementDomainUserPasswordSecure = ConvertTo-SecureString $ManagementDomainUserPassword -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PSCredential ($ManagementDomainUserName, $ManagementDomainUserPasswordSecure)

$DnsNatIP = $DnsNatIP -replace '\s',''
Write-Log "INFO" "The final DnsNatIP list is: $DnsNatIP"
$DnsNatIPFinal = $DnsNatIP -split ","

Write-Log "INFO" "Trying to create domain trust with $ManagementDomainUserName"

$AddManagementDomainDomainTrust = New-ADDomainTrust $ManagementDomainUserName $ManagementDomainUserPassword $ManagementDomain Bidirectional

try {

    Write-Log "INFO" "Creating CIM Session to $ManagementDomainPDC with user $ManagementDomainUserName"
                       
        $ManagementDomainCimSession = New-CimSession -ComputerName $ManagementDomainPDC -Credential $mycreds

        if(Get-DnsServerZone -Name $DomainName -CimSession $ManagementDomainCimSession -ErrorAction SilentlyContinue) {
            
        Write-Log "INFO" "The conditional forwarder for $DomainName already exists.  Going to delete and re-add"
        Remove-DnsServerZone -Name $DomainName -CimSession $ManagementDomainCimSession -Force:$true
    }
                    
    Add-DnsServerConditionalForwarderZone -Name $DomainName -ReplicationScope "Domain" -MasterServers $DnsNatIPFinal -ForwarderTimeout "5" -CimSession $ManagementDomainCimSession
    Write-Log "INFO" "Successfully added the conditional forwarder for $DomainName"

} catch {
        
    Write-Log "ERROR" $_.Exception.Message
    Failure-Message
}

foreach ($DnsNat in $DnsNatIPFinal) {
	
	$NATReverseLookupZone = ""
    $Counter = 1
    Write-Log "INFO" "Site DNS NAT IP is $DnsNat"
    $DnsNat.Split(".") | ForEach { 
		
        if ($Counter -eq "4") {
            
        } elseif ($Counter -eq "1") {
           $NATReverseLookupZone = $_+".in-addr.arpa"
        } else {
            $NATReverseLookupZone = $_+"."+$NATReverseLookupZone
        }
        $Counter++
    }

    Write-Log "INFO" "NAT Reverse Lookup Zone is: $NATReverseLookupZone"
        
    try {
            
        if(Get-DnsServerZone -Name $NATReverseLookupZone -CimSession $ManagementDomainCimSession -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "The conditional forwarder for $NATReverseLookupZone already exists.  Going to delete and re-add"
            Remove-DnsServerZone -Name $NATReverseLookupZone -CimSession $ManagementDomainCimSession -Force:$true
            
        }
        
        Add-DnsServerConditionalForwarderZone -Name $NATReverseLookupZone -ReplicationScope "Domain" -MasterServers $DnsNatIPFinal -ForwarderTimeout "5" -CimSession $ManagementDomainCimSession
        Write-Log "INFO" "Successfully added the conditional forwarder for $NATReverseLookupZone"
        
    } catch {

        Write-Log "ERROR" $_.Exception.Message
        Failure-Message

    }

}
                
try {
    $NetBiosNameUpper = $NetBiosName.ToUpper()
    $ManagementDomainSecurityGroup = "$NetBiosNameUpper-Server-Admins"
    Write-Log "INFO" "Creating a new security group in the management domain $ManagementDomain named $ManagementDomainSecurityGroup"
    
    New-ADOrganizationalUnit -Name "$NetBiosNameUpper" -path $ManagementDomainSecurityGroupPath -Server $ManagementDomain -Credential $mycreds
    $ManagementDomainSecurityGroupPathFinal = "OU=$NetBiosNameUpper,$ManagementDomainSecurityGroupPath"
    New-ADGroup -Name "$ManagementDomainSecurityGroup" -groupscope "Global" -path $ManagementDomainSecurityGroupPathFinal -Server $ManagementDomain -Credential $mycreds
    Write-Log "INFO" "Successfully created new security group in the management domain"
       

} catch {
        
    Write-Log "ERROR" $_.Exception.Message
    Failure-Message
                     
}

try {

    $ManagementEnterpriseDomainsGroupSplit = $ManagementEnterpriseDomainsGroup.Split("\")
    Write-Log "INFO" "Adding $($ManagementEnterpriseDomainsGroupSplit[1]) from $($ManagementEnterpriseDomainsGroupSplit[0]) to Administrators group"
    $ManagementGroupUser = Get-ADGroup -Identity $ManagementEnterpriseDomainsGroupSplit[1] -Server $ManagementDomain -Credential $mycreds
    Add-ADGroupMember Administrators -Members $ManagementGroupUser
    Write-Log "INFO" "Adding $($ManagementEnterpriseDomainsGroupSplit[1]) from $($ManagementEnterpriseDomainsGroupSplit[0]) to DnsAdmins group"
    Add-ADGroupMember DNSAdmins -Members $ManagementGroupUser

} catch {
        
    Write-Log "ERROR" $_.Exception.Message
    Failure-Message
                     
}

#--------------------------
#Multi-tenant Domain Trusts section

if ($SetupMTDomain) {  

    $MTDomainDNSServers = $MTDomainDNSServers -replace '\s',''
    $MTDomainDNSServersFinal = $MTDomainDNSServers -split ","
    $AddMTDomainConditionalForwarder = Add-Conditional-Forwader $MTDomain "Domain" $MTDomainDNSServersFinal "5"
            
    Write-Log "INFO" "Trying to create domain trust with $ManagementDomainUserName"

    $AddMTDomainDomainTrust = New-ADDomainTrust $ManagementDomainUserName $ManagementDomainUserPassword $MTDomain Bidirectional

    $MTDomainPDC = $MTDomainDNSServersFinal[0];

    try {

        Write-Log "INFO" "Creating CIM Session to $MTDomainPDC with user $ManagementDomainUserName"
                       
        $MTDomainCimSession = New-CimSession -ComputerName $MTDomainPDC -Credential $mycreds

        if(Get-DnsServerZone -Name $DomainName -CimSession $MTDomainCimSession -ErrorAction SilentlyContinue) {
            
            Write-Log "INFO" "The conditional forwarder for $DomainName already exists.  Going to delete and re-add"
            Remove-DnsServerZone -Name $DomainName -CimSession $MTDomainCimSession -Force:$true
        }
                    
        Add-DnsServerConditionalForwarderZone -Name $DomainName -ReplicationScope "Domain" -MasterServers $DnsNatIPFinal -ForwarderTimeout "5" -CimSession $MTDomainCimSession
        Write-Log "INFO" "Successfully added the conditional forwarder for $DomainName"

    } catch {
        
        Write-Log "ERROR" $_.Exception.Message
        Failure-Message
    }

    foreach ($DnsNat in $DnsNatIPFinal) {
	
	    $NATReverseLookupZone = ""
        $Counter = 1
        Write-Log "INFO" "Site DNS NAT IP is $DnsNat"
        $DnsNat.Split(".") | ForEach { 
		
            if ($Counter -eq "4") {
            
            } elseif ($Counter -eq "1") {
               $NATReverseLookupZone = $_+".in-addr.arpa"
            } else {
                $NATReverseLookupZone = $_+"."+$NATReverseLookupZone
            }
            $Counter++
        }

        Write-Log "INFO" "NAT Reverse Lookup Zone is: $NATReverseLookupZone"
        
        try {
            
            if(Get-DnsServerZone -Name $NATReverseLookupZone -CimSession $MTDomainCimSession -ErrorAction SilentlyContinue) {
            
                Write-Log "INFO" "The conditional forwarder for $NATReverseLookupZone already exists.  Going to delete and re-add"
                Remove-DnsServerZone -Name $NATReverseLookupZone -CimSession $MTDomainCimSession -Force:$true
            
            }
        
            Add-DnsServerConditionalForwarderZone -Name $NATReverseLookupZone -ReplicationScope "Domain" -MasterServers $DnsNatIPFinal -ForwarderTimeout "5" -CimSession $MTDomainCimSession
            Write-Log "INFO" "Successfully added the conditional forwarder for $NATReverseLookupZone"
        
        } catch {

            Write-Log "ERROR" $_.Exception.Message
            Failure-Message

        }

    }
}

#--------------------------
#Group Policy section

New-Item -Path "c:\" -Name "DOD_EP" -ItemType "directory"
New-SmbShare -Name "DOD_EP" -Path "C:\DOD_EP" -FullAccess "Authenticated Users"
Copy-Item -Path "C:\Software\GPO Backups\DOD_EP_V3.xml" -Destination "C:\DOD_EP"

Write-Log "INFO" "Blocking Inheritance on Quarantine OU for Servers"
Set-GPInheritance -Target "OU=Quarantine,OU=Servers,$DCPath" -IsBlocked Yes
Write-Log "INFO" "Blocking Inheritance on Quarantine OU for Workstations"
Set-GPInheritance -Target "OU=Quarantine,OU=Workstations,$DCPath" -IsBlocked Yes
Write-Log "INFO" "Blocking Inheritance on Quarantine OU for Domain Controllers"
Set-GPInheritance -Target "OU=Quarantine,OU=Domain Controllers,$DCPath" -IsBlocked Yes

$AddGPOFilter = Add-GPO-Filter "Excel 2013" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office15\\excel.exe" AND Version LIKE "15.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office15\\excel.exe" AND Version LIKE "15.%")' "Excel 2013"
$AddGPOFilter = Add-GPO-Filter "Excel 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\excel.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\excel.exe" AND Version LIKE "16.%")' "Excel 2016"
$AddGPOFilter = Add-GPO-Filter "Google Chrome" 'SELECT Name FROM CIM_Datafile WHERE Name = "C:\\Program Files (x86)\\Google\\Chrome\\Application\\chrome.exe"' "Google Chrome"
$AddGPOFilter = Add-GPO-Filter "Internet Explorer 11" 'SELECT Name,Version FROM CIM_Datafile WHERE Name = "C:\\Program Files\\Internet Explorer\\iexplore.exe" AND Version LIKE "11.%"' "Internet Explorer 11"
$AddGPOFilter = Add-GPO-Filter "Microsoft Office 2013" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office15\\clview.exe" AND Version LIKE "15.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office15\\clview.exe" AND Version LIKE "15.%")' "Microsoft Office 2013"
$AddGPOFilter = Add-GPO-Filter "Microsoft Office 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\clview.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\clview.exe" AND Version LIKE "16.%")' "Microsoft Office 2016"
$AddGPOFilter = Add-GPO-Filter "OneDrive for Business 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\groove.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\groove.exe" AND Version LIKE "16.%")' "OneDrive for Business 2016"
$AddGPOFilter = Add-GPO-Filter "Outlook 2013" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office15\\outlook.exe" AND Version LIKE "15.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office15\\outlook.exe" AND Version LIKE "15.%")' "Outlook 2013"
$AddGPOFilter = Add-GPO-Filter "Outlook 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\outlook.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\outlook.exe" AND Version LIKE "16.%")' "Outlook 2016"
$AddGPOFilter = Add-GPO-Filter "PowerPoint 2013" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office15\\powerpnt.exe" AND Version LIKE "15.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office15\\powerpnt.exe" AND Version LIKE "15.%")' "PowerPoint 2013"
$AddGPOFilter = Add-GPO-Filter "PowerPoint 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\powerpnt.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\powerpnt.exe" AND Version LIKE "16.%")' "PowerPoint 2016"
$AddGPOFilter = Add-GPO-Filter "Project 2013" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office15\\winproj.exe" AND Version LIKE "15.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office15\\winproj.exe" AND Version LIKE "15.%")' "Project 2013"
$AddGPOFilter = Add-GPO-Filter "Project 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\winproj.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\winproj.exe" AND Version LIKE "16.%")' "Project 2016"
$AddGPOFilter = Add-GPO-Filter "Visio 2013" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office15\\visio.exe" AND Version LIKE "15.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office15\\visio.exe" AND Version LIKE "15.%")' "Visio 2013"
$AddGPOFilter = Add-GPO-Filter "Visio 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\visio.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\visio.exe" AND Version LIKE "16.%")' "Visio 2016"
$AddGPOFilter = Add-GPO-Filter "Windows 10" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "10.%" AND ProductType = "1"' "Windows 10"
$AddGPOFilter = Add-GPO-Filter "Windows 10, 2016, 2019" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "10.%"' "Windows 10, 2016, 2019"
$AddGPOFilter = Add-GPO-Filter "Windows Server 2012 R2 Domain Controller" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "6.3%" AND ProductType = "2"' "Windows Server 2012 R2 Domain Controller"
$AddGPOFilter = Add-GPO-Filter "Windows Server 2012 R2 Member Server" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "6.3%" AND ProductType = "3"' "Windows Server 2012 R2 Member Server"
$AddGPOFilter = Add-GPO-Filter "Windows Server 2016 Domain Controller" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "10.0.14393" AND ProductType = "2"' "Windows Server 2016 Domain Controller"
$AddGPOFilter = Add-GPO-Filter "Windows Server 2016 Member Server" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "10.0.14393" AND ProductType = "3"' "Windows Server 2016 Member Server"
$AddGPOFilter = Add-GPO-Filter "Windows Server 2019 Domain Controller" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "10.0.17763" AND ProductType = "2"' "Windows Server 2019 Domain Controller"
$AddGPOFilter = Add-GPO-Filter "Windows Server 2019 Member Server" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "10.0.17763" AND ProductType = "3"' "Windows Server 2019 Member Server"
$AddGPOFilter = Add-GPO-Filter "Windows Server All Versions Domain Controller" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE (Version LIKE "6.3%" OR Version LIKE "10.0.14393" OR Version LIKE "10.0.17763") AND ProductType = "2"' "Windows Server All Versions Domain Controller"
$AddGPOFilter = Add-GPO-Filter "Windows Server All Versions Member Server" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE (Version LIKE "6.3%" OR Version LIKE "10.0.14393" OR Version LIKE "10.0.17763") AND ProductType = "3"' "Windows Server All Versions Member Server"
$AddGPOFilter = Add-GPO-Filter "Word 2013" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office15\\winword.exe" AND Version LIKE "15.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office15\\winword.exe" AND Version LIKE "15.%")' "Word 2013"
$AddGPOFilter = Add-GPO-Filter "Word 2016" 'SELECT Name,Version FROM CIM_Datafile WHERE (Name = "C:\\Program Files (x86)\\Microsoft Office\\Office16\\winword.exe" AND Version LIKE "16.%") OR (Name = "C:\\Program Files\\Microsoft Office\\Office16\\winword.exe" AND Version LIKE "16.%")' "Word 2016"
$AddGPOFilter = Add-GPO-Filter "Windows 10, 2019" 'SELECT Version,ProductType FROM Win32_OperatingSystem WHERE Version LIKE "10.%" AND NOT LIKE "10.0.14393"' "Windows 10, 2019"

$AddNewGPO = Add-New-GPO "Crypto Win 10, 2016, 2019" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows 10, 2016, 2019" "Crypto Win 10, 2016, 2019"
$AddNewGPOLink = Add-New-GPO-Link "Crypto Win 10, 2016, 2019" $DCPath


$AddNewGPOLink = Add-New-GPO-Link "Default Domain Policy" "OU=Quarantine,OU=Servers,$DCPath"
$AddNewGPOLink = Add-New-GPO-Link "Default Domain Policy" "OU=Quarantine,OU=Workstations,$DCPath"
$AddNewGPOLink = Add-New-GPO-Link "Default Domain Policy" "OU=Quarantine,OU=Domain Controllers,$DCPath"
$AddNewGPOLink = Add-New-GPO-Link "Default Domain Controllers Policy" "OU=Quarantine,OU=Domain Controllers,$DCPath"

$AddNewGPO = Add-New-GPO "DoD Excel 2013 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Excel 2013" "DoD Excel 2013 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Excel 2013 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Excel 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Excel 2016" "DoD Excel 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Excel 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Google Chrome" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Google Chrome" "DoD Google Chrome"
$AddNewGPOLink = Add-New-GPO-Link "DoD Google Chrome" $DCPath

$AddNewGPO = Add-New-GPO "DoD Internet Explorer 11 STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Internet Explorer 11" "DoD Internet Explorer 11 STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Internet Explorer 11 STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Internet Explorer 11 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Internet Explorer 11" "DoD Internet Explorer 11 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Internet Explorer 11 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Office System 2013 STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Microsoft Office 2013" "DoD Office System 2013 STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Office System 2013 STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Office System 2013 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Microsoft Office 2013" "DoD Office System 2013 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Office System 2013 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Office System 2016 STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Microsoft Office 2016" "DoD Office System 2016 STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Office System 2016 STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Office System 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Microsoft Office 2016" "DoD Office System 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Office System 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD OneDrive for Business 2016 STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "OneDrive for Business 2016" "DoD OneDrive for Business 2016 STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD OneDrive for Business 2016 STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD OneDrive for Business 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "OneDrive for Business 2016" "DoD OneDrive for Business 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD OneDrive for Business 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Outlook 2013 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Outlook 2013" "DoD Outlook 2013 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Outlook 2013 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Outlook 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Outlook 2016" "DoD Outlook 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Outlook 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD PowerPoint 2013 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "PowerPoint 2013" "DoD PowerPoint 2013 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD PowerPoint 2013 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD PowerPoint 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "PowerPoint 2016" "DoD PowerPoint 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD PowerPoint 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Project 2013 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Project 2013" "DoD Project 2013 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Project 2013 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Project 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Project 2016" "DoD Project 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Project 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Visio 2013 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Visio 2013" "DoD Visio 2013 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Visio 2013 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Visio 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Visio 2016" "DoD Visio 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Visio 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Word 2013 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Word 2013" "DoD Word 2013 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Word 2013 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Word 2016 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Word 2016" "DoD Word 2016 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Word 2016 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows 10 STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows 10" "DoD Windows 10 STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows 10 STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "Exploit Protection UNC" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows 10, 2019" "Exploit Protection UNC"
$AddNewGPOLink = Add-New-GPO-Link "Exploit Protection UNC" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows 10 STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows 10" "DoD Windows 10 STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows 10 STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Defender Antivirus STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows 10, 2016, 2019" "DoD Windows Defender Antivirus STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Defender Antivirus STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Firewall STIG" $DomainName
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Firewall STIG" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server 2012 R2 Domain Controller STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server 2012 R2 Domain Controller" "DoD Windows Server 2012 R2 Domain Controller STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server 2012 R2 Domain Controller STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server 2012 R2 Member Server STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server 2012 R2 Member Server" "DoD Windows Server 2012 R2 Member Server STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server 2012 R2 Member Server STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server 2016 Domain Controller STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server 2016 Domain Controller" "DoD Windows Server 2016 Domain Controller STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server 2016 Domain Controller STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server 2016 Member Server STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server 2016 Member Server" "DoD Windows Server 2016 Member Server STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server 2016 Member Server STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server 2019 Domain Controller STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server 2019 Domain Controller" "DoD Windows Server 2019 Domain Controller STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server 2019 Domain Controller STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server 2019 Member Server STIG Computer" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server 2019 Member Server" "DoD Windows Server 2019 Member Server STIG Computer"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server 2019 Member Server STIG Computer" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server Domain Controller STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server All Versions Domain Controller" "DoD Windows Server Domain Controller STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server Domain Controller STIG User" $DCPath

$AddNewGPO = Add-New-GPO "DoD Windows Server Member Server STIG User" $DomainName
$LinkGPOFilter = Link-GPO-Filter "Windows Server All Versions Member Server" "DoD Windows Server Member Server STIG User"
$AddNewGPOLink = Add-New-GPO-Link "DoD Windows Server Member Server STIG User" $DCPath

$AddNewGPO = Add-New-GPO $GeneralGPOName $DomainName
$AddNewGPOLink = Add-New-GPO-Link $GeneralGPOName $DCPath

$NetBiosNameUpper = $NetBiosName.ToUpper()
$ManagementDomainSecurityGroup = "$($ManagementEnterpriseDomainsGroupSplit[0])\$NetBiosNameUpper-Server-Admins"
Write-Log "INFO" "Updating Windows Admins GPO Migration Table with the following Administrators Group Name: $ManagementDomainSecurityGroup"
(Get-Content "C:\Software\GPO Backups\GPO.migtable").replace('TenantServerAdmins', $ManagementDomainSecurityGroup) | Set-Content "C:\Software\GPO Backups\GPO.migtable"

Write-Log "INFO" "Updating $GeneralGPOName GPO Migration Table with the following Administrators Group Name: $ManagementEnterpriseDomainsGroup"
(Get-Content "C:\Software\GPO Backups\GPO.migtable").replace('ManagementEnterpriseAdmins', $ManagementEnterpriseDomainsGroup) | Set-Content "C:\Software\GPO Backups\GPO.migtable"

Sleep -Seconds 5

$AddNewGPO = Add-New-GPO "Windows Admins" $DomainName
$AddNewGPOLink = Add-New-GPO-Link "Windows Admins" "OU=Servers,$DCPath"
$AddNewGPOLink = Add-New-GPO-Link "Windows Admins" "OU=Workstations,$DCPath"

$AddNewGPO = Add-New-GPO "Enterprise Admins" $DomainName
$AddNewGPOLink = Add-New-GPO-Link "Enterprise Admins" $DCPath

$ImportGPO = Import-Saved-GPO "Crypto Win 10, 2016, 2019" "Crypto Win 10, 2016, 2019" "C:\Software\GPO Backups\Crypto Win 10, 2016, 2019"
$ImportGPO = Import-Saved-GPO "DoD Excel 2013 STIG User" "DoD Excel 2013 STIG User" "C:\Software\GPO Backups\DoD Excel 2013 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Excel 2016 STIG User" "DoD Excel 2016 STIG User" "C:\Software\GPO Backups\DoD Excel 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Google Chrome" "DoD Google Chrome" "C:\Software\GPO Backups\DoD Google Chrome"
$ImportGPO = Import-Saved-GPO "DoD Internet Explorer 11 STIG Computer" "DoD Internet Explorer 11 STIG Computer" "C:\Software\GPO Backups\DoD Internet Explorer 11 STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD Internet Explorer 11 STIG User" "DoD Internet Explorer 11 STIG User" "C:\Software\GPO Backups\DoD Internet Explorer 11 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Office System 2013 STIG Computer" "DoD Office System 2013 STIG Computer" "C:\Software\GPO Backups\DoD Office System 2013 STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD Office System 2013 STIG User" "DoD Office System 2013 STIG User" "C:\Software\GPO Backups\DoD Office System 2013 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Office System 2016 STIG Computer" "DoD Office System 2016 STIG Computer" "C:\Software\GPO Backups\DoD Office System 2016 STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD Office System 2016 STIG User" "DoD Office System 2016 STIG User" "C:\Software\GPO Backups\DoD Office System 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD OneDrive for Business 2016 STIG Computer" "DoD OneDrive for Business 2016 STIG Computer" "C:\Software\GPO Backups\DoD OneDrive for Business 2016 STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD OneDrive for Business 2016 STIG User" "DoD OneDrive for Business 2016 STIG User" "C:\Software\GPO Backups\DoD OneDrive for Business 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Outlook 2013 STIG User" "DoD Outlook 2013 STIG User" "C:\Software\GPO Backups\DoD Outlook 2013 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Outlook 2016 STIG User" "DoD Outlook 2016 STIG User" "C:\Software\GPO Backups\DoD Outlook 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD PowerPoint 2013 STIG User" "DoD PowerPoint 2013 STIG User" "C:\Software\GPO Backups\DoD PowerPoint 2013 STIG User"
$ImportGPO = Import-Saved-GPO "DoD PowerPoint 2016 STIG User" "DoD PowerPoint 2016 STIG User" "C:\Software\GPO Backups\DoD PowerPoint 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Project 2013 STIG User" "DoD Project 2013 STIG User" "C:\Software\GPO Backups\DoD Project 2013 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Project 2016 STIG User" "DoD Project 2016 STIG User" "C:\Software\GPO Backups\DoD Project 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Visio 2013 STIG User" "DoD Visio 2013 STIG User" "C:\Software\GPO Backups\DoD Visio 2013 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Visio 2016 STIG User" "DoD Visio 2016 STIG User" "C:\Software\GPO Backups\DoD Visio 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Word 2013 STIG User" "DoD Word 2013 STIG User" "C:\Software\GPO Backups\DoD Word 2013 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Word 2016 STIG User" "DoD Word 2016 STIG User" "C:\Software\GPO Backups\DoD Word 2016 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Windows 10 STIG Computer" "DoD Windows 10 STIG Computer" "C:\Software\GPO Backups\DoD Windows 10 STIG Computer"
$ImportGPO = Import-Saved-GPO "Exploit Protection UNC" "Exploit Protection UNC" "C:\Software\GPO Backups\Exploit Protection UNC"
$ImportGPO = Import-Saved-GPO "DoD Windows 10 STIG User" "DoD Windows 10 STIG User" "C:\Software\GPO Backups\DoD Windows 10 STIG User"
$ImportGPO = Import-Saved-GPO "DoD Windows Defender Antivirus STIG Computer" "DoD Windows Defender Antivirus STIG Computer" "C:\Software\GPO Backups\DoD Windows Defender Antivirus STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD Windows Firewall STIG" "DoD Windows Firewall STIG" "C:\Software\GPO Backups\DoD Windows Firewall STIG"
$ImportGPO = Import-Saved-GPO "DoD Windows Server 2012 R2 Member Server STIG Computer" "DoD Windows Server 2012 R2 Member Server STIG Computer" "C:\Software\GPO Backups\DoD Windows Server 2012 R2 Member Server STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD Windows Server 2016 Member Server STIG Computer" "DoD Windows Server 2016 Member Server STIG Computer" "C:\Software\GPO Backups\DoD Windows Server 2016 Member Server STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD Windows Server 2019 Member Server STIG Computer" "DoD Windows Server 2019 Member Server STIG Computer" "C:\Software\GPO Backups\DoD Windows Server 2019 Member Server STIG Computer"
$ImportGPO = Import-Saved-GPO "DoD Windows Server Member Server STIG User" "DoD Windows Server Member Server STIG User" "C:\Software\GPO Backups\DoD Windows Server Member Server STIG User"
$ImportGPO = Import-Saved-GPO "Windows Admins" "Windows Admins" "C:\Software\GPO Backups\Windows Admins" "C:\Software\GPO Backups\GPO.migtable"
$ImportGPO = Import-Saved-GPO "Enterprise Admins" "Enterprise Admins" "C:\Software\GPO Backups\Enterprise Admins" "C:\Software\GPO Backups\GPO.migtable"
           
Write-Log "INFO" "Adding commands to AD-Primary-Final script for Group Policy.  This must be run to complete GPO install"

Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$SetGPPermissions = Set-GPPermissions -All -TargetName `'$ManagementEnterpriseDomainsGroup`' -TargetType Group -PermissionLevel GpoEditDeleteModifySecurity"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`nWrite-Log 'INFO' 'Successfully set group policy permissions for $ManagementEnterpriseDomainsGroup'"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$ImportGPO = Import-Saved-GPO `'DoD Windows Server 2012 R2 Domain Controller STIG Computer`' `'DoD Windows Server 2012 R2 Domain Controller STIG Computer`' `'C:\Software\GPO Backups\DoD Windows Server 2012 R2 Domain Controller STIG Computer`'"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$ImportGPO = Import-Saved-GPO `'DoD Windows Server 2016 Domain Controller STIG Computer`' `'DoD Windows Server 2016 Domain Controller STIG Computer`' `'C:\Software\GPO Backups\DoD Windows Server 2016 Domain Controller STIG Computer`'"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$ImportGPO = Import-Saved-GPO `'DoD Windows Server 2019 Domain Controller STIG Computer`' `'DoD Windows Server 2019 Domain Controller STIG Computer`' `'C:\Software\GPO Backups\DoD Windows Server 2019 Domain Controller STIG Computer`'"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$ImportGPO = Import-Saved-GPO `'DoD Windows Server Domain Controller STIG User`' `'DoD Windows Server Domain Controller STIG User`' `'C:\Software\GPO Backups\DoD Windows Server Domain Controller STIG User`'"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$RemoveGPLink = Remove-Group-Policy-Link `'Default Domain Policy`' `'$DCPath`'"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$RemoveGPLink = Remove-Group-Policy-Link `'Default Domain Controllers Policy`' `'OU=Domain Controllers,$DCPath`'"
Add-Content -Path "C:\Software\Setup Scripts\AD-Primary-Final.ps1" -Value "`r`n`$ImportGPO = Import-Saved-GPO `'$GeneralGPOName`' `'$GeneralGPOName`' `'C:\Software\GPO Backups\$GeneralGPOName`'"

#--------------------------
#Sites section      

$ADSites.Split(",") | ForEach {
    Write-Log "INFO" "Starting Configuration for Site: $_"
    $ADSiteSplit = $_.Split("-")
    $SiteToAddCode = $ADSiteSplit[0]
    $SiteSubnet = $ADSiteSplit[1]
    $Sites = "CN=Sites,CN=Configuration,"+$DCPath
    $SiteServersContainer = "CN="+$SiteToAddCode+","+$Sites
                        
    Write-Log "INFO" "The site to be added is: $SiteToAddCode"
    Write-Log "INFO" "The sites CN path is: $Sites"
    Write-Log "INFO" "The site servers container CN path is: $SiteServersContainer"
    Write-Log "INFO" "The site subnet is: $SiteSubnet"

    $CreateADObject = Create-AD-Object "Site" $SiteToAddCode $Sites

    $CreateADObject = Create-AD-Object "ServersContainer" "Servers" $SiteServersContainer

    $CreateADObject = Create-AD-Object "NTDSSiteSettings" "NTDS Site Settings" $SiteServersContainer
                    
    $CreateADReplicationSubnet = Create-AD-Replication-Subnet $SiteSubnet $SiteToAddCode $SiteToAddCode

    $Counter = 1
    $SiteSubnetReverseLookupZone = ""
    $SiteSubnet.Split(".") | ForEach { 
        if ($Counter -eq "4") {
            $SiteSubnetReverseLookupZone = $SiteSubnetReverseLookupZone+"0/24"
        } else {
            $SiteSubnetReverseLookupZone = $SiteSubnetReverseLookupZone+$_+"."
        }
        $Counter++
    }

    $CreateDNSReverseLookupZone = Create-DNS-Reverse-Lookup-Zone $SiteSubnetReverseLookupZone "Domain"

    $CreateADReplicationSiteLink = Create-AD-Replication-Site-Link $NetBiosName $SiteToAddCode "100" "15"

    $AddOU = Create-AD-OU $SiteToAddCode "OU=Servers,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "$SiteToAddCode Servers"

    $AddOU = Create-AD-OU "ICM" "OU=$SiteToAddCode,OU=Servers,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "$SiteToAddCode ICM Servers"
    #$AddNewGPOLink = Add-New-GPO-Link "Tenant-ICMAdmins" "OU=ICM,OU=$SiteToAddCode,OU=Servers,$DCPath"
    
    $AddOU = Create-AD-OU "Standard" "OU=$SiteToAddCode,OU=Servers,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "$SiteToAddCode Standard Servers"

    $AddOU = Create-AD-OU $SiteToAddCode "OU=Domain Controllers,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "$SiteToAddCode Domain Controllers"

    $AddOU = Create-AD-OU $SiteToAddCode "OU=Workstations,$DCPath" -ProtectedFromAccidentalDeletion $true -Description "$SiteToAddCode Workstations"
    
    $AddNewGPO = Add-New-GPO "$SiteGPOPrefix - $SiteToAddCode" $DomainName

    $AddNewGPOLink = Add-New-GPO-Link "$SiteGPOPrefix - $SiteToAddCode" "OU=$SiteToAddCode,OU=Servers,$DCPath"
    $AddNewGPOLink = Add-New-GPO-Link "$SiteGPOPrefix - $SiteToAddCode" "OU=$SiteToAddCode,OU=Domain Controllers,$DCPath"
    $AddNewGPOLink = Add-New-GPO-Link "$SiteGPOPrefix - $SiteToAddCode" "OU=$SiteToAddCode,OU=Workstations,$DCPath"
   
    $ImportGPO = Import-Saved-GPO "$SiteGPOPrefix - $SiteToAddCode" "$SiteGPOPrefix - $SiteToAddCode" "C:\Software\GPO Backups\$SiteGPOPrefix - $SiteToAddCode"
    
    Write-Log "INFO" "Silent Mode.  Checking whether this server should be assigned to this site"
        
    if ($env:COMPUTERNAME.Substring(0,3).ToUpper() -eq $SiteToAddCode) {
        Write-Log "INFO" "Silent Mode.  Found a site match.  Setting AssignDCToThisSite to 1"
        $AssignDCToThisSite = 1
    } else {
        $AssignDCToThisSite = 2
        Write-Log "INFO" "Silent Mode.  No site match.  Setting AssignDCToThisSite to 2"
    }
                   
    Write-Log "INFO" "AssignDCToThisSite is set to: $AssignDCToThisSite"

    if ($AssignDCToThisSite -eq "1") {
                            
        $MoveADServer = Move-AD-Server $env:COMPUTERNAME $SiteToAddCode "OU=$SiteToAddCode,OU=Domain Controllers,$DCPath"
                   
    }
    
 }

#--------------------------------------------------------------------
#Create KDS Root Key
       
$CreateKDSRootKey = Create-KDS-Root-Key (Get-Date).AddHours(-10)

#--------------------------------------------------------------------
#Re-Add Conditional Forwarders

$AddManagementDomainConditionalForwarder = Add-Conditional-Forwader $ManagementDomain "Domain" $ManagementDomainDNSServersFinal "5"
$AddPublicDomainConditionalForwarder = Add-Conditional-Forwader $PublicDomain "Domain" $PublicDomainDNSServersFinal "5"