 Param (
     
    [parameter(Mandatory=$true)]
	[String]$SystemID,
    [parameter(Mandatory=$true)]
	[String]$ServerNumber
	
)

$Logfile = "C:\Software\Setup Scripts\ICM.log"
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

$servername = $env:COMPUTERNAME
        
$GetDomainInfo = Get-Domain-Info (Get-WmiObject Win32_ComputerSystem).Domain
$DomainName = $GetDomainInfo[0]
$NetBIOSName = $GetDomainInfo[1]
$DCPath = $GetDomainInfo[2]

Write-Log "INFO" "The Server Name is: $servername"
Write-Log "INFO" "The Domain Name is: $DomainName"
Write-Log "INFO" "The NET BIOS Name is: $NetBIOSName"
Write-Log "INFO" "The System ID is: $SystemID"
Write-Log "INFO" "The Server Number is: $ServerNumber"


if ($ServerNumber -match "1s") {
    
    try {    
        
        Write-Log "INFO" "Adding $NetBiosName\UCCE_sb$($SystemID)_Service to Administrators"
        Add-LocalGroupMember -Group "Administrators" -Member "$NetBiosName\UCCE_sb$($SystemID)_Service"
        
        Write-Log "INFO" "Adding $NetBiosName\UCCE_sb$($SystemID)_Config to UCCEConfig"
        Add-LocalGroupMember -Group "UCCEConfig" -Member "$NetBiosName\UCCE_sb$($SystemID)_Config"

        Write-Log "INFO" "Adding $NetBiosName\UCCE_sb$($SystemID)_Setup to UCCESetup"
        Add-LocalGroupMember -Group "UCCESetup" -Member "$NetBiosName\UCCE_sb$($SystemID)_Setup"

        Write-Log "INFO" "Adding $NetBiosName\UCCE_sb$($SystemID)_Service to UCCEService"
        Add-LocalGroupMember -Group "UCCEService" -Member "$NetBiosName\UCCE_sb$($SystemID)_Service"

        Write-Log "INFO" "Adding $NetBiosName\svc_UCCE_Sandbox to Administrators"
        Add-LocalGroupMember -Group "Administrators" -Member "$NetBiosName\svc_UCCE_Sandbox"

        Write-Log "INFO" "Adding $NetBiosName\svc_UCCE_Sandbox to UCCEService"
        Add-LocalGroupMember -Group "UCCEService" -Member "$NetBiosName\svc_UCCE_Sandbox"
    } catch {

        Write-Log "ERROR" $_.Exception.Message
        Write-Log "ERROR" "An error occurred while adding Sandbox Groups to Local Security Groups"

    }

} else {

    try {
        
        Write-Log "INFO" "Adding $NetBiosName\UCCE_pd$($SystemID)_Service to Administrators"
        Add-LocalGroupMember -Group "Administrators" -Member "$NetBiosName\UCCE_pd$($SystemID)_Service"

        Write-Log "INFO" "Adding $NetBiosName\UCCE_pd$($SystemID)_Config to UCCEConfig"
        Add-LocalGroupMember -Group "UCCEConfig" -Member "$NetBiosName\UCCE_pd$($SystemID)_Config"

        
        Write-Log "INFO" "Adding $NetBiosName\UCCE_pd$($SystemID)_Setup to UCCESetup"
        Add-LocalGroupMember -Group "UCCESetup" -Member "$NetBiosName\UCCE_pd$($SystemID)_Setup"

        Write-Log "INFO" "Adding $NetBiosName\UCCE_pd$($SystemID)_Service to UCCEService"
        Add-LocalGroupMember -Group "UCCEService" -Member "$NetBiosName\UCCE_pd$($SystemID)_Service"

        Write-Log "INFO" "Adding $NetBiosName\ICM Administrators to Administrators"
        Add-LocalGroupMember -Group "Administrators" -Member "$NetBiosName\ICM Administrators"

        Write-Log "INFO" "Adding $NetBiosName\svc_UCCE_SideA to Administrators"
        Add-LocalGroupMember -Group "Administrators" -Member "$NetBiosName\svc_UCCE_SideA"

        Write-Log "INFO" "Adding $NetBiosName\svc_UCCE_SideA to UCCEService"
        Add-LocalGroupMember -Group "UCCEService" -Member "$NetBiosName\svc_UCCE_SideA"

        Write-Log "INFO" "Adding $NetBiosName\svc_UCCE_SideB to Administrators"
        Add-LocalGroupMember -Group "Administrators" -Member "$NetBiosName\svc_UCCE_SideB"

        Write-Log "INFO" "Adding $NetBiosName\svc_UCCE_SideB to UCCEService"
        Add-LocalGroupMember -Group "UCCEService" -Member "$NetBiosName\svc_UCCE_SideB"

    } catch {

        Write-Log "ERROR" $_.Exception.Message
        Write-Log "ERROR" "An error occurred while adding Production Groups to Local Security Groups"

    }

}