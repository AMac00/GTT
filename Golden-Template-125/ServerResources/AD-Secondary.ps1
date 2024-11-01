 Param (

    [parameter(Mandatory=$true)]
	[String]$DomainUserName,
    [parameter(Mandatory=$true)]
	[String]$DomainUserPass
)

$Logfile = "C:\Software\Setup Scripts\AD-Secondary.log"
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


$servername = $env:COMPUTERNAME
        
$GetDomainInfo = Get-Domain-Info (Get-WmiObject Win32_ComputerSystem).Domain
$DomainName = $GetDomainInfo[0]
$NetBIOSName = $GetDomainInfo[1]
$DCPath = $GetDomainInfo[2]

#--------------------------------------------------------------------
Write-Log "INFO" "Entering DNS Section"
$SetDefaultDNSProperties = Set-Default-DNS-Properties 

Write-Log "INFO" "Updating DNS forwarders"
$DNSForwarderIPs = @("8.8.8.8","208.67.222.222","209.244.0.3","64.6.64.6")
$UpdateDNSForwarders = Update-DNSForwarders $DNSForwarderIPs
  
#--------------------------------------------------------------------
#Remove Passwords File


Remove-Item "C:\Software\Setup Scripts\passwords.txt" -Confirm:$false
Write-Log "INFO" "Successfully removed passwords file from server"

Write-Log "INFO" "Performing DNS Reset"
ipconfig /flushdns
ipconfig /registerdns
Restart-Service DNS