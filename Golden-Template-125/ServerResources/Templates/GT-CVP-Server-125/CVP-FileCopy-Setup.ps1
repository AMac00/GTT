 Param (

    [parameter(Mandatory=$true)]
	[Boolean]$IsPrimary,
    [parameter(Mandatory=$true)]
	[String]$PrimaryCVPServer,
    [parameter(Mandatory=$true)]
	[String]$SecondaryCVPServer,
    [parameter(Mandatory=$true)]
	[Boolean]$EnableDialer
)

$Logfile = "C:\Software\Setup Scripts\CVP-FileCopy-Setup.log"
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

$DomainName = (Get-WmiObject Win32_ComputerSystem).Domain
$NetBiosNamePos = $DomainName.IndexOf(".")
$NetBiosName = $DomainName.Substring(0, $NetBiosNamePos)

Write-Log "INFO" "The server domain name is: $DomainName"
Write-Log "INFO" "The NetBIOS name is: $NetBiosName"

#MediaServer Binding Section
Write-Log "INFO" "Binding wildcard certificate to IIS"
Import-Module WebAdministration

Get-Item cert:\LocalMachine\My\*  | foreach { 
    if ($_.Subject -match $DomainName) {
        $NewCertThumbPrint = $_.Thumbprint
    }
}
New-WebBinding -Name "MediaFiles" -Port 443 -Protocol https 
(Get-WebBinding -Name "MediaFiles" -Port 443 -Protocol "https").AddSslCertificate($NewCertThumbPrint, "my")


#OpenSSH Section
if (($env:COMPUTERNAME -match $PrimaryCVPServer) -or ($env:COMPUTERNAME -match $SecondaryCVPServer)) {

    Write-Log "INFO" "This is a primary or secondary CVP server.  Setting up OpenSSH"

    Write-Log "INFO" "Replacing domain name with $NetBiosName is sshd_config"
    (Get-Content "C:\ProgramData\ssh\sshd_config").replace('hc001', $NetBiosName) | Set-Content "C:\ProgramData\ssh\sshd_config"

    Write-Log "INFO" "Setting sshd service to automatic"
    Set-Service -Name sshd -StartupType Automatic

}

#DFS Replication Section
Write-Log "INFO" "Installing Windows features on local computer"
Install-WindowsFeature FS-DFS-Replication, RSAT-DFS-Mgmt-Con

$GroupName = "CVP"
$FolderName = "CVPFiles"
$MediaFilesPath = "C:\MediaFiles"

$DialerGroupName = "Dialer"
$DialerFolderName = "DialerFiles"
$DialerFilesPath = "C:\CustomerFiles\CiscoImport"

Write-Log "INFO" "File Path for replication is set to: $MediaFilesPath"

if ($IsPrimary) {

    ####CVP Section####
    Write-Log "INFO" "Setting up CVP Replication"
    Write-Log "INFO" "Creating Replication Group.  GroupName = $GroupName"
    New-DfsReplicationGroup -GroupName $GroupName -DomainName $DomainName

    Write-Log "INFO" "Creating Replicated Folder.  FolderName = $FolderName"
    New-DfsReplicatedFolder -GroupName $GroupName -DomainName $DomainName -FolderName $FolderName

    Write-Log "INFO" "Adding DFSR Member $env:COMPUTERNAME"
    Add-DfsrMember -GroupName $GroupName -DomainName $DomainName -ComputerName $env:COMPUTERNAME

    Write-Log "INFO" "Setting DFSR Membership on $env:COMPUTERNAME"
    Set-DfsrMembership -GroupName $GroupName -DomainName $DomainName -FolderName $FolderName -ComputerName $env:COMPUTERNAME -ContentPath $MediaFilesPath –PrimaryMember $true -RemoveDeletedFiles $true -StagingPathQuotaInMB 32768 -ConflictAndDeletedQuotaInMB 4096 -Confirm:$false -Force

    #####Dialer Section####
    Write-Log "INFO" "Setting up Dialer Replication"
    Write-Log "INFO" "Creating Replication Group.  GroupName = $DialerGroupName"
    New-DfsReplicationGroup -GroupName $DialerGroupName -DomainName $DomainName

    Write-Log "INFO" "Creating Replicated Folder.  FolderName = $DialerFolderName"
    New-DfsReplicatedFolder -GroupName $DialerGroupName -DomainName $DomainName -FolderName $DialerFolderName

    Write-Log "INFO" "Adding DFSR Member $env:COMPUTERNAME"
    Add-DfsrMember -GroupName $DialerGroupName -DomainName $DomainName -ComputerName $env:COMPUTERNAME

    Write-Log "INFO" "Setting DFSR Membership on $env:COMPUTERNAME"
    Set-DfsrMembership -GroupName $DialerGroupName -DomainName $DomainName -FolderName $DialerFolderName -ComputerName $env:COMPUTERNAME -ContentPath $DialerFilesPath –PrimaryMember $true -RemoveDeletedFiles $true -StagingPathQuotaInMB 32768 -ConflictAndDeletedQuotaInMB 4096 -Confirm:$false -Force

} else {

    ####CVP Section####
    Write-Log "INFO" "Setting up CVP Replication"
    Write-Log "INFO" "Adding DFSR Member $env:COMPUTERNAME"
    Add-DfsrMember -GroupName $GroupName -DomainName $DomainName -ComputerName $env:COMPUTERNAME

    Write-Log "INFO" "Adding DFSR Connection"
    Add-DfsrConnection -GroupName $GroupName -DomainName $DomainName -SourceComputerName $env:COMPUTERNAME -DestinationComputerName $PrimaryCVPServer

    if ($env:COMPUTERNAME -notmatch $SecondaryCVPServer) {

        Write-Log "INFO" "Adding DFSR Connection"
        Add-DfsrConnection -GroupName $GroupName -DomainName $DomainName -SourceComputerName $env:COMPUTERNAME -DestinationComputerName $SecondaryCVPServer
    }

    Write-Log "INFO" "Setting DFSR Membership on $env:COMPUTERNAME"
    Set-DfsrMembership -GroupName $GroupName -DomainName $DomainName -FolderName $FolderName -ComputerName $env:COMPUTERNAME -ContentPath $MediaFilesPath -RemoveDeletedFiles $true -StagingPathQuotaInMB 32768 -ConflictAndDeletedQuotaInMB 4096 -Confirm:$false -Force

    ####Dialer Section####

    if ($EnableDialer) {
        Write-Log "INFO" "Setting up Dialer Replication"
        Write-Log "INFO" "Adding DFSR Member $env:COMPUTERNAME"
        Add-DfsrMember -GroupName $DialerGroupName -DomainName $DomainName -ComputerName $env:COMPUTERNAME

        Write-Log "INFO" "Adding DFSR Connection"
        Add-DfsrConnection -GroupName $DialerGroupName -DomainName $DomainName -SourceComputerName $env:COMPUTERNAME -DestinationComputerName $PrimaryCVPServer

        if ($env:COMPUTERNAME -notmatch $SecondaryCVPServer) {

            Write-Log "INFO" "Adding DFSR Connection"
            Add-DfsrConnection -GroupName $DialerGroupName -DomainName $DomainName -SourceComputerName $env:COMPUTERNAME -DestinationComputerName $SecondaryCVPServer
        }

        Write-Log "INFO" "Setting DFSR Membership on $env:COMPUTERNAME"
        Set-DfsrMembership -GroupName $DialerGroupName -DomainName $DomainName -FolderName $DialerFolderName -ComputerName $env:COMPUTERNAME -ContentPath $DialerFilesPath -RemoveDeletedFiles $true -StagingPathQuotaInMB 32768 -ConflictAndDeletedQuotaInMB 4096 -Confirm:$false -Force
    
    }
}
