 Param (
     
    [ValidateSet("PDC","DC","ICM","Standard")]
    [parameter(Mandatory=$true)]
	[String]$ServerType,
    [parameter(Mandatory=$true)]
	[String]$DomainName,
	[parameter(Mandatory=$true)]
	[String]$CertificatePassword,
    [parameter(Mandatory=$false)]
	[String]$DomainUserName,
    [parameter(Mandatory=$false)]
	[String]$DomainUserPass,
    [parameter(Mandatory=$false)]
	[String]$SafeModePass,
    [parameter(Mandatory=$false)]
	[String]$PrivateIP,
    [parameter(Mandatory=$false)]
	[String]$RemotePrivateCIDR,
    [parameter(Mandatory=$false)]
	[Boolean]$LeaveInWorkgroup
)

$Logfile = "C:\Software\Setup Scripts\Setup.log"
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

Function Create-New-Password {

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

    Get-Content "C:\Software\Setup Scripts\passwords.txt" | Where-Object {$_ -notmatch "$Parameter="} | Set-Content "C:\Software\Setup Scripts\parameters-new.txt"
    $LineToAdd | Add-Content 'C:\Software\Setup Scripts\passwords-new.txt'

    Remove-Item 'C:\Software\Setup Scripts\passwords.txt'
    Rename-Item 'C:\Software\Setup Scripts\passwords-new.txt' 'passwords.txt'
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
        
        Install-ADDSForest `
            -CreateDnsDelegation:$false `
            -DatabasePath "D:\Windows\NTDS" `
            -SafeModeAdministratorPassword (ConvertTo-SecureString $SafeModePassword -AsPlainText -Force) `
            -DomainMode "7" `
            -DomainName $DomainName `
            -DomainNetbiosName $NetBiosName `
            -ForestMode "7" `
            -InstallDns:$true `
            -LogPath "D:\Windows\NTDS" `
            -NoRebootOnCompletion:$true `
            -SysvolPath "D:\Windows\SYSVOL" `
            -Force:$true 

    
    } catch {
        
        Write-Log "ERROR" $_.Exception.Message
        
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

Function Import-PFX-Certificate {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$FilePath,
        [parameter(Mandatory=$true)]
	    [String]$CertStore,
        [parameter(Mandatory=$true)]
	    [String]$Password
    

    )

    $Result = "Success"
    

    try {
        $SecurePassword = ConvertTo-SecureString -String $Password -Force -AsPlainText
        Import-PfxCertificate -FilePath $FilePath $CertStore -Password $SecurePassword -Exportable
        Write-Log "INFO" "Successfully imported $FilePath to certificate store $CertStore"
        
    } catch {

        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
        
    }

    $Result

}


if (Test-Path "C:\Program Files\Notepad++\updater") {
    Write-Log "INFO" "Notepad++ updater is enabled. Disabling now"
    Rename-Item -Path "C:\Program Files\Notepad++\updater" -NewName "C:\Program Files\Notepad++\updater_disabled"
} else {
    Write-Log "INFO" "Notepad++ updater not found. Nothing to do"
}

Write-Log "INFO" "Setting Teredo to disabled"
netsh interface teredo set state disabled


$netadaptercount = Get-NetAdapter | measure
if ($netadaptercount.Count -eq "2") {

    if ($PrivateIP -and $RemotePrivateCIDR) {
        $subnetmasks = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.ipaddress -like $PrivateIP} 
        Foreach ($subnetmask in $subnetmasks) {
            $nexthop = $subnetmask.DefaultIPGateway
            $interfaceindex = $subnetmask.InterfaceIndex
        }

        Write-Log "INFO" "Setting Private Network Adapter Name to Private and changing profile to Private"
        $setprivadaptername = Get-NetAdapter -InterfaceIndex $interfaceindex | Rename-NetAdapter -NewName Private

        Set-NetConnectionProfile -InterfaceIndex $interfaceindex -NetworkCategory Private
        
        Write-Log "INFO" "Creating a private static route for $RemovePrivateCIDR with a next hop of $nexthop"
        $createprivatestaticroute = New-NetRoute -DestinationPrefix $RemotePrivateCIDR -InterfaceIndex $interfaceindex -RouteMetric 1 -NextHop "$nexthop"
        Write-Log "INFO" "Removing DNS Servers from Private Network Adapter"
        $remoteprivatednsservers = Set-DNSClientServerAddress -InterfaceIndex $interfaceindex -ResetServerAddresses
        Write-Log "INFO" "Removing Default Gateway from Private Network Adapter"
        $removeprivatedefaultroute = Remove-NetRoute -DestinationPrefix 0.0.0.0/0 -InterfaceIndex $interfaceindex -Confirm:$false

    } else {
        Write-Log "ERROR" "Cant perform Net Adapter section because either the PrivateIP or RemotePrivateCIDR parameters are missing"
    }
} 

Write-Log "INFO" "Setting Public Network Adapter Name to Public"
$setvisibleadaptername = Get-NetAdapter | Where-Object {$_.name -like "Ether*"} | Rename-NetAdapter -NewName Public

Write-Log "INFO" "Enabling services & features"
Set-Service -Name Browser -StartupType Automatic -ErrorAction SilentlyContinue
Add-WindowsFeature -Name rsat-ad-tools
Add-WindowsFeature -Name snmp-service
Add-WindowsFeature -Name snmp-wmi-provider
Add-WindowsFeature -Name telnet-client

if ($ServerType -eq "PDC") {

    Write-Log "INFO" "Setting NlaSvc startup registry key to Delayed Autostart"
    Set-ItemProperty -Path "Registry::HKLM\System\CurrentControlSet\Services\NlaSvc" -Name "DelayedAutostart" -Value 1 -Type DWORD
    
	$ImportPFXCerticate = Import-PFX-Certificate "c:\Software\SSLCerts\wildcard.pfx" Cert:\localMachine\My $CertificatePassword
    Write-Log "INFO" "DomainName is $DomainName"

    $DomainInfo = Get-Domain-Info $DomainName
	$NetBiosName = $DomainInfo[1]

	    
	Write-Log "INFO" "The domain to be created will be: $DomainName"
	Write-Log "INFO" "The NetBIOS name for this domain will be: $NetBiosName"
	Write-Log "INFO" "Starting DC Install Now"
	Install-WindowsFeature AD-Domain-Services -IncludeManagementTools
	
    Create-New-Password 'ADDRPassword' $SafeModePass $true
	New-AD-Install $DomainName $NetBiosName $SafeModePass 
    Write-Log "INFO" "Setting NlaSvc to be dependent on AD services prior to starting"
    sc.exe config nlasvc depend=NSI/RpcSs/TcpIp/Dhcp/Eventlog/DNS/NTDS   
        
} elseif ($ServerType -eq "DC") {

    Write-Log "INFO" "Setting NlaSvc startup registry key to Delayed Autostart"
    Set-ItemProperty -Path "Registry::HKLM\System\CurrentControlSet\Services\NlaSvc" -Name "DelayedAutostart" -Value 1 -Type DWORD
    
	$ImportPFXCerticate = Import-PFX-Certificate "c:\Software\SSLCerts\wildcard.pfx" Cert:\localMachine\My $CertificatePassword
    
    $DomainInfo = Get-Domain-Info $DomainName
    $NetBiosName = $DomainInfo[1]
    $DCPath = $DomainInfo[2]

    $SiteToAddCode = $env:COMPUTERNAME.Substring(0,3).ToUpper() 
    
    Write-Log "INFO" "The domain that this server will be joined to is: $DomainName"
    Write-Log "INFO" "The NetBIOS name of this domain is: $NetBiosName"
    Write-Log "INFO" "The DN for this domain is: $DCPath"
    Write-Log "INFO" "The site this server will be added to is: $SiteToAddCode - NOTE: This step will fail if the site doesn't exist in AD"

    Write-Log "INFO" "Starting DC Install Now"
    Install-WindowsFeature AD-Domain-Services -IncludeManagementTools

    $DomainUserPassSecure = ConvertTo-SecureString $DomainUserPass -AsPlainText -Force
    $Credential = New-Object System.Management.Automation.PSCredential ($DomainUserName, $DomainUserPassSecure)

    Create-New-Password 'ADDRPassword' $SafeModePass $true
	
    $AddSecondaryADStatus = "1"
    $AddSecondaryADCounter = "1"

    while ($AddSecondaryADStatus -eq "1") {
        
        try {
	        Install-ADDSDomainController `
		        -NoGlobalCatalog:$false `
		        -CreateDnsDelegation:$false `
		        -credential $Credential `
		        -CriticalReplicationOnly:$false `
		        -DatabasePath "D:\Windows\NTDS" `
		        -DomainName $DomainName `
		        -InstallDns:$true `
		        -LogPath "D:\Windows\NTDS" `
		        -NoRebootOnCompletion:$true `
                -SafeModeAdministratorPassword (ConvertTo-SecureString $SafeModePass -AsPlainText -Force) `
		        -SiteName $SiteToAddCode `
		        -SysvolPath "D:\Windows\SYSVOL" `
		        -Force:$true 

            $AddSecondaryADStatus = "2"

            Write-Log "INFO" "Setting NlaSvc to be dependent on AD services prior to starting"
            sc.exe config nlasvc depend=NSI/RpcSs/TcpIp/Dhcp/Eventlog/DNS/NTDS
            
        } catch {
            Write-Log "ERROR" $_.Exception.Message
            

            $AddSecondaryADCounter = $AddSecondaryADCounter + 1

            if ($AddSecondaryADCounter -eq 4) {
                $AddSecondaryADSuccess = "3"
            } else {
                Write-Log "ERROR" "Failed to join domain.  Will retry"
            }
        
        }

    }
    
    if ($AddSecondaryADStatus -eq "2") {

        Write-Log "INFO" "The server has been successfully promoted to be a DC of $DomainName"
    
        Get-ADComputer $env:COMPUTERNAME -Server $DomainName -Credential $Credential | Move-ADObject -TargetPath "OU=$SiteToAddCode,OU=Domain Controllers,$DCPath"
        Write-Log "INFO" "Successfully moved $env:COMPUTERNAME to OU=$SiteToAddCode,OU=Domain Controllers,$DCPath"
        Write-Log "INFO" "A reboot is required"      
    
    } else {

        Write-Log "ERROR" "The server failed to promote to a DC"
    }
    

   

} else {

    try {
        $user = [adsi]"WinNT://$env:computername/administrator"
        $user.UserFlags.value = $user.UserFlags.value -bor 0x10000
        $user.CommitChanges()
        Write-Log "INFO" "Successfully set Local Administrator account to never expire"
    } catch {
        Write-Log "ERROR" "Failed to set Local Administrator account to never expire"
    }

    If (Get-Service "MSSQLSERVER" -ErrorAction SilentlyContinue) {
        Write-Log "INFO" "SQL Server is installed.  Performing SQL Staging"

        #Set the SQL Server Name to the hostname of the server
        try {
            Invoke-Sqlcmd -Query "EXEC sp_dropserver @@SERVERNAME" -ServerInstance "."
            Invoke-Sqlcmd -Query "EXEC sp_addserver $env:COMPUTERNAME,'local'" -ServerInstance "."
            Invoke-Sqlcmd -Query "EXEC sp_configure 'show advanced option', '1';" -ServerInstance "."
            Invoke-Sqlcmd -Query "RECONFIGURE;" -ServerInstance "."
            Write-Log "INFO" "Successfully set SQL Server Name to $env:COMPUTERNAME"
        } catch {
            Write-Log "ERROR" "Failed to set SQL Server Name to $env:COMPUTERNAME"
        }

        

        #Set the Max Memory on SQL.  
        #If Memory GB < 9 THEN Memory = TotalServerMemory - 2GB
        #Otherwise Memory = TotalServerMemory - 4GB
        $PhysicalMemory = Get-WmiObject CIM_PhysicalMemory | Measure-Object -Property capacity -Sum | % { [Math]::Round(($_.sum / 1GB), 2) }
        Write-Log "INFO" "Physical Memory on server is $PhysicalMemory GB"

        if ($PhysicalMemory -lt 9) {
            $SQLMemory = ($PhysicalMemory - 2) * 1024
            Write-Log "INFO" "Will set SQL Memory on server to $SQLMemory MB"
        } else {
            $SQLMemory = ($PhysicalMemory - 4) * 1024
            Write-Log "INFO" "Will set SQL Memory on server to $SQLMemory MB"
        }
        try {
            
            $query = "EXEC sp_configure 'max server memory (MB)', '$SQLMemory'"
            Invoke-Sqlcmd -Query $query -ServerInstance "."
            Invoke-Sqlcmd -Query "RECONFIGURE WITH OVERRIDE" -ServerInstance "."
            Write-Log "INFO" "Successfully configured SQL Max Memory to $SQLMemory"
        } catch {
            Write-Log "ERROR" "Failed to configure SQL Max Memory to $SQLMemory"
        }

        #Get CPU information for use with Parellelism and TempDB
        $cs = Get-WmiObject -class Win32_ComputerSystem #Get CPU Information
        $Cores=$cs.numberoflogicalprocessors
        Write-Log "INFO" "Determined the number of CPU Cores to be: $Cores"

        #Set the max degree of parellelism to the number of cores / 2
        #In the event we have an odd number of cores, we will round down (so three cores will result in 1 being used
        try {
            $SQLParallelism = [Math]::Floor($Cores/2)
            Write-Log "INFO" "Max degrees of parellelism will be: $SQLParallelism"
            
            $query = "EXEC sp_configure 'show advanced options', 1;  
            GO  
            RECONFIGURE WITH OVERRIDE;  
            GO  
            EXEC sp_configure 'max degree of parallelism', '$SQLParallelism';  
            GO  
            RECONFIGURE WITH OVERRIDE;  
            GO  
            "

            Invoke-Sqlcmd -Query $query -ServerInstance "."
            Write-Log "INFO" "Successfully set max degress of parallelism"
        } catch {
            Write-Log "ERROR" "Failed to set max degress of parallelism"
        }
               
        
        #TempDB Section
        #1 data file is needed per core.  If more than 8 cores are present then we only need 8 data files
        #Data files should always grow in 64 MB chunks.  The sum of all data files should be 75% of the TempDB drive space with autogrowth turned off
        #The log file is set to autogrow, but limited to 23% of the remaining the drive space.
		#This section will be skipped for ICM 12.5 Roggers, Loggers, & HDS servers.  In these cases, SQL has already been optimized in the ova template.
        if ($ServerType -eq "ICM") {
			Write-Log "INFO" "Skipping TempDB file modification on this UCCE Rogger, HDS, or Logger - optimizations should already be applied on the ova"
		} else {
		
			try {
				#Get each tempDB filename (name), type (0 = data, 1 = log) and path (physical_name)
				$sqlresults = Invoke-Sqlcmd -Query "SELECT name,type,physical_name FROM tempdb.sys.database_files"  -ServerInstance "." -OutputAs DataRows
				foreach($sqlresult in $sqlresults)
				{
					$tempdbfilename = $sqlresult.name
					$tempdbfilepath = $sqlresult.physical_name
					$tempdbfiletype = $sqlresult.type

					Write-Log "INFO" "Looking at filename = $tempdbfilename, filepath = $tempdbfilepath, filetype = $tempdbfiletype"
					if ($sqlresult.type -eq "0") {

						Write-Log "INFO" "It is a data file"

						if ($tempdbfilepath -like "*.ndf") {
							
							Write-Log "INFO" "Data file is determined to be a secondary file. We dont need this so going to remove it"
							$query = "USE tempdb;
							DBCC SHRINKFILE('$tempdbfilename', EMPTYFILE)
							GO
							USE master;
							GO
							ALTER DATABASE tempdb
							REMOVE FILE $tempdbfilename;
							"
							Invoke-Sqlcmd -Query $query -ServerInstance "."
							Write-Log "INFO" "Successfully removed secondary data file" 

						} else {
							
							Write-Log "INFO" "Data file is determined to be the primary data file.  We're going to shrink it down to 1 GB in the event its larger than that"
							$query = "USE tempdb;
							GO
							CHECKPOINT
							GO
							DBCC FREEPROCCACHE
							GO
							DBCC SHRINKFILE ($tempdbfilename, 1024)
							GO
							CHECKPOINT
							GO
							DBCC FREEPROCCACHE
							GO"
							Invoke-Sqlcmd -Query $query -ServerInstance "."
							Write-Log "INFO" "Successfully shrunk the primary data file."

							#Now we need to determine the drive letter that the TempDB is stored on, as well as the path to data and log files
							$tempdbfilepos = $tempdbfilepath.LastIndexOf('\') + 1
							$tempdbpath = $tempdbfilepath.SubString(0,$tempdbfilepos)

							Write-Log "INFO" "Setting the tempdbpath for new data file creation to: $tempdbpath"

							$tempdbdrivepos = $tempdbfilepath.IndexOf('\')
							$tempdbdriveletter = $tempdbfilepath.SubString(0,$tempdbdrivepos)

							Write-Log "INFO" "Setting the tempdbdriveletter to determine the size of the drive to: $tempdbdriveletter"

							$disk = Get-WmiObject Win32_LogicalDisk -Filter "DeviceID='$tempdbdriveletter'" | Select-Object Size

							$disksize = [Math]::round($disk.Size/1024/1024/1024,0)
							Write-Log "INFO" "The total disk size of the tempdb drive is: $disksize GB"

							#Check to see if number of cores is gt 8.  If it is, we will cap the number at 8 so only a max of only 8 data files get created
							if ($Cores -gt 8) {
								$Cores = "8"
								Write-Log "INFO" "The total number of Cores is greater than 8. We will only create $Cores tempdb data files"
							} else {
								Write-Log "INFO" "The total number of Cores is less than 8. We will create $Cores tempdb data files"
							}

							$tempdbfilesize = [Math]::floor($disksize * .75 / $Cores)
							Write-Log "INFO" "Each tempdb data file will be: $tempdbfilesize GB"


							$query = "ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'$tempdbfilename', SIZE = "+$tempdbfilesize+"GB, MAXSIZE = UNLIMITED, FILEGROWTH = 0)"
							Invoke-Sqlcmd -Query $query -ServerInstance "."
							Write-Log "INFO" "Successfully altered the primary data file.  Name = $tempdbfilename, Size = $tempdbfilesize GB, MAXSIZE = UNLIMITED, FILEGROWTH = NONE"
						}

					} else {
						
						Write-Log "INFO" "It is a log file"

						$tempdblogsize = [Math]::floor($disksize * .23)
						Write-Log "INFO" "23 percent of the overall disksize of the drive size is $tempdblogsize GB.  We will use this to cap the max size of the log file"
						$query = "ALTER DATABASE [tempdb] MODIFY FILE ( NAME = N'"+$tempdbfilename+"', SIZE = 4096KB , MAXSIZE = "+$tempdblogsize+"GB , FILEGROWTH = 65536KB)"
						Invoke-Sqlcmd -Query $query -ServerInstance "."
						Write-Log "INFO" "Successfully set the tempdb log file.  Name = $tempdbfilename, INITIAL SIZE = 4 MB, MAXSIZE = $tempdblogsize GB, FILEGROWTH = 64 MB"
					}

				}
				
				#Last we need to add all of our additional tempDB drives
				for ($i = 2; $i -le $Cores; $i++) {
					$tempdatafilename = $tempdbpath+"tempdev"+$i+".ndf"
					$query = "ALTER DATABASE [tempdb] ADD FILE ( NAME = N'tempdev"+$i+"', FILENAME = N'"+$tempdatafilename+"' , SIZE = "+$tempdbfilesize+"GB, MAXSIZE = UNLIMITED, FILEGROWTH = 0)" 
					Invoke-Sqlcmd -Query $query -ServerInstance "."
					Write-Log "INFO" "Successfully added a new secondary data file.  NAME = tempdev$i, FILENAME = $tempdatafilename, Size = $tempdbfilesize GB, MAXSIZE = UNLIMITED, FILEGROWTH = NONE"
				}
			} catch {
				Write-Log "ERROR" "Failed to setup tempDB properly"
			}
		}
    }
    
    $siteToAddCode = $env:COMPUTERNAME.Substring(0,3)
	$siteToAddCode = $siteToAddCode.ToUpper()
	
	if ($ServerType -eq "ICM") {

        Write-Log "INFO" "Binding new wildcard certificate to IIS and Diag FW"
        Import-Module WebAdministration
        C:\icm\serviceability\diagnostics\bin\DiagFwCertMgr /task:UnbindCert
        Get-Item IIS:\SslBindings\0.0.0.0!443 | Remove-Item
        Get-Item cert:\LocalMachine\My\*  | foreach { 
            $OldThumb = $_.Thumbprint
            Remove-Item -Path Cert:\LocalMachine\My\$OldThumb
        }
		#next line imports the wildcard certificate that was manually copied into the GTT directory before running the GTT.
        $ImportPFXCerticate = Import-PFX-Certificate "c:\Software\SSLCerts\wildcard.pfx" Cert:\localMachine\My $CertificatePassword
        
        Get-Item cert:\LocalMachine\My\*  | foreach { 
            $NewCertThumbPrint = $_.Thumbprint
        }
        Get-Item -Path "cert:\LocalMachine\My\$NewCertThumbPrint" | new-item -path IIS:\SslBindings\0.0.0.0!443
        C:\icm\serviceability\diagnostics\bin\DiagFwCertMgr /task:BindCertFromStore /certhash:$NewCertThumbPrint

        #Not needed as we're modifying the template keystore to include all standard root certs
        #Write-Log "INFO" "Importing Root Certificate"
        #& $env:JAVA_HOME\bin\keytool.exe -import -alias root -file C:\Software\SSLCerts\bundle.crt -keystore "C:\Program Files (x86)\Java\jre1.8.0_221\lib\security\cacerts" -storepass changeit -noprompt
        
        $OUname = "ICM"

	}
	else {
		$OUname = "Standard"
		$ImportPFXCerticate = Import-PFX-Certificate "c:\Software\SSLCerts\wildcard.pfx" Cert:\localMachine\My $CertificatePassword
	}


	$dcPath = "DC="
	$counter = 1
	$DomainName.Split(".") | ForEach { 
		if ($counter -eq "1") {
			$dcPath = "DC="+$_ 
		} else {
			$dcPath = $dcPath+",DC="+$_
		}
		$counter++
	}


	$dcPath = "OU=$OUname,OU=$siteToAddCode,OU=Servers,$dcPath"

	Write-Log "INFO" "Moving to OU path: $dcPath"

	$cred = New-Object System.Management.Automation.PSCredential($DomainUserName, (ConvertTo-SecureString $DomainUserPass -AsPlainText -Force))

    if ($LeaveInWorkgroup) {
        Write-Log "INFO" "Leave in workgroup was set.  Not joining to domain"
    } else {

        $DomainJoinStatus = "0"
        $DomainJoinCounter = "0"

        while ($DomainJoinStatus -eq "0") {
            
            try {
                Add-Computer -DomainName $DomainName -Credential $cred -OUPath $dcPath
                
                if ((gwmi win32_computersystem).partofdomain -eq $true) {
                    $DomainJoinStatus = "1"
                }
            } catch {
                Write-Log "ERROR" $_.Exception.Message
                Write-Log "ERROR" "Domain Join Failed"
            }

            if ($DomainJoinStatus -eq "1") {
                Write-Log "INFO" "Successfully added computer to the domain"
                Write-Log "INFO" "A reboot is required"
            } elseif ($DomainJoinCounter -eq "2") {
                $DomainJoinStatus = 2
                Write-Log "ERROR" "The computer could not be joined to the domain. You must add the server to the domain manually. Any downstream scripts will now fail"
            } else {
                $DomainJoinCounter = $DomainJoinCounter + 1
                Start-Sleep -Seconds 15
                Write-Log "INFO" "Re-attempting Domain Join"
            }

        }
        
    }
}