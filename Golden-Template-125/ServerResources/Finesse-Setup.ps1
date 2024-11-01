Param (

    [parameter(Mandatory=$true)]
	[String]$Method,
    [parameter(Mandatory=$true)]
	[String]$FinesseServer,
    [parameter(Mandatory=$false)]
	[String]$SecondaryNode,
    [parameter(Mandatory=$false)]
	[String]$Username,
    [parameter(Mandatory=$false)]
	[String]$Password
)

$Logfile = "C:\Software\Setup Scripts\Finesse-Setup.log"
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

#Requires -Version 3
Set-StrictMode -Version Latest

# Define default URL protocol to https, which can be changed by calling Set-Protocol function
$Script:FinesseMgmtProtocol = "https"

#Bypass Certs
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Ssl3, [Net.SecurityProtocolType]::Tls, [Net.SecurityProtocolType]::Tls11, [Net.SecurityProtocolType]::Tls12

function Set-FinesseMgmtProtocol {
    <#
    .SYNOPSIS
        Set $Script:FinesseMgmtProtocol, this will be used for all subsequent invocation of Finesse APIs
    .DESCRIPTION
        Set $Script:FinesseMgmtProtocol
    .PARAMETER Protocol
        Protocol, acceptable values are "http" and "https"
    .EXAMPLE
        Set-FinesseMgmtProtocol -Protocol https
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("http","https")]
        [string]$Protocol
    )

    Write-Log "INFO" "$($MyInvocation.MyCommand): Enter"

    $Script:FinesseMgmtProtocol = $Protocol

    Write-Log "INFO" "FinesseMgmtProtocol set to $Script:FinesseMgmtProtocol"
    Write-Log "INFO" "$($MyInvocation.MyCommand): Exit"
}

function Get-FinesseMgmtProtocol {
    <#
    .SYNOPSIS
        Get the value of $Script:FinesseMgmtProtocol
    .DESCRIPTION
        Set $Script:FinesseMgmtProtocol
    .EXAMPLE
        $protocol  = Get-FinesseMgmtProtocol
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    param()

    return $Script:FinesseMgmtProtocol 
}


function Invoke-FinesseRestApi {
    <#
    .SYNOPSIS
        Invoke Finesse REST API 
    .DESCRIPTION
        Invoke Finesse REST API 
    .PARAMETER FinesseServer
        The Finesse Server to be used for the request
    .PARAMETER Username
        Username to use to perform the request
    .PARAMETER Password
        Password to use to perform the request
    .PARAMETER OperationMethod
        Specifies the method used for the web request
    .PARAMETER ResourceType
        Type of the resource
    .PARAMETER ResourceName
        Name of the resource, optional
    .PARAMETER Action
        Name of the action to perform on the resource
    .PARAMETER Payload
        Payload  of the web request, in hashtable format

    .EXAMPLE
        Invoke Finesse REST API to set the Finesse secondary node
        $payload = @{ip="10.8.115.210"}
        Invoke-FinesseRestApi -FinesseServer myfinesseserver -Username myuser -Password mypassword -OperationMethod POST -ResourceType ClusterConfig -Payload $payload 
    .OUTPUTS
        Only when the OperationMethod is GET:
        PSCustomObject that represents the JSON response content. This object can be manipulated using the ConvertTo-Json Cmdlet.
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [String]$FinesseServer,
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [ValidateSet("DELETE","GET","POST","PUT")]
        [string]$OperationMethod,
        [Parameter(Mandatory=$true)]
        [string]$ResourceType,
        [Parameter(Mandatory=$false)]
        [string]$ResourceName, 
        [Parameter(Mandatory=$false)]
        [string]$Action,
        [Parameter(Mandatory=$false)]
        [string]$Body
        
    )

    Write-Log "INFO" "$($MyInvocation.MyCommand): Enter"
    
    Write-Log "INFO" "Building URI"
    $uri = "$($Script:FinesseMgmtProtocol)://$FinesseServer/finesse/api/$ResourceType"
    if (-not [string]::IsNullOrEmpty($ResourceName)) {
        $uri += "/$ResourceName"
    }

    Write-Log "INFO" "URI: $uri"
    
    $BasicAuthString = "$($Username):$($Password)"
    $encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($BasicAuthString))

    $headers = @{}
    $headers.Add("Authorization","Basic $encodedCreds")
    
    Write-Log "INFO" $Body
    try {
        Write-Log "INFO" "Calling Invoke-RestMethod"

        if ($Body) {

            $response = Invoke-RestMethod -Uri $uri  -Method $OperationMethod -Headers $headers -Body $Body -ContentType 'application/xml'

        } else {

            $response = Invoke-RestMethod -Uri $uri  -Method $OperationMethod -Headers $headers

        }

        Write-Log "INFO" "Response: $response"
        
    }
    catch [Exception] {
        Write-Log "ERROR" $_.Exception.Message
    }
    

    Write-Log "INFO" "$($MyInvocation.MyCommand): Exit"

    return $response

}

function Get-FinesseClusterConfig {
# Created: 20160912
    <#
    .SYNOPSIS
        Retrieves the Cluster Config of a Finesse Node
    .DESCRIPTION
        Retrieves the Cluster Config of a Finesse Node
    .PARAMETER FinesseServer
        The Finesse Server to be used for the request
    .PARAMETER Username
        Username to use to perform the request
    .PARAMETER Password
        Password to use to perform the request

    .EXAMPLE
        Get-FinesseClusterConfig -FinesseServer $FinesseServer -Username $Username -Password $Password
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [String]$FinesseServer,
        [Parameter(Mandatory=$true)]
        [String]$Username,
        [Parameter(Mandatory=$true)]
        [String]$Password
    )

    Write-Log "INFO" "$($MyInvocation.MyCommand): Enter"

    $response = Invoke-FinesseRestApi -FinesseServer $FinesseServer -Username $Username -Password $Password -OperationMethod GET -ResourceType ClusterConfig
    
    Write-Log "INFO" "$($MyInvocation.MyCommand): Exit"

    return $response
}

function Set-FinesseClusterConfig {
# Created: 20160912
    <#
    .SYNOPSIS
        Sets the Cluster Config of a Finesse Node
    .DESCRIPTION
        Sets the Cluster Config of a Finesse Node
    .PARAMETER FinesseServer
        The Finesse Server to be used for the request
    .PARAMETER Username
        Username to use to perform the request
    .PARAMETER Password
        Password to use to perform the request
    .PARAMETER SecondaryNode
        The name of the Secondary Node to be added

    .EXAMPLE
        Set-FinesseClusterConfig -FinesseServer $FinesseServer -Username $Username -Password $Password -SecondaryNode $SecondaryNode
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [String]$FinesseServer,
        [Parameter(Mandatory=$true)]
        [String]$Username, 
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [String]$SecondaryNode
    )

    Write-Log "INFO" "$($MyInvocation.MyCommand): Enter"

    $Body = "<ClusterConfig><uri>/finesse/api/ClusterConfig</uri><secondaryNode><host>$SecondaryNode</host></secondaryNode></ClusterConfig>"
    
    $response = Invoke-FinesseRestApi -FinesseServer $FinesseServer -Username $Username -Password $Password -OperationMethod PUT -ResourceType ClusterConfig -Body $Body
    
    Write-Log "INFO" "$($MyInvocation.MyCommand): Exit"

    return $response
}


function Set-FinesseEnterpriseDatabaseConfig {
# Created: 20160912
    <#
    .SYNOPSIS
        Sets the Enterprise Database Config of a Finesse Node
    .DESCRIPTION
        Sets the Enterprise Database Config of a Finesse Node
    .PARAMETER FinesseServer
        The Finesse Server to be used for the request
    .PARAMETER Username
        Username to use to perform the request
    .PARAMETER Password
        Password to use to perform the request
    .PARAMETER PrimaryDBHost
        The primary db host
    .PARAMETER BackupDBHost
        The backup db host
    .PARAMETER DBPort
        The db port
    .PARAMETER DBName
        The database name
    .PARAMETER SvcAccountDomain
        The domain of the service account user
    .PARAMETER SvcAccountUser
        The username of the service account
    .PARAMETER SvcAccountPass
        The password of the service account
    .PARAMETER ValidateConfig
        Whether to perform validation

    .EXAMPLE
        Set-FinesseEnterpriseDatabaseConfig -FinesseServer $FinesseServer -Username $Username -Password $Password -PrimaryDBHost $PrimaryDBHost -BackupDBHost $BackupDBHost -DBPort $DBPort -DBName $DBName -SvcAccountDomain $SvcAccountDomain -SvcAccountUser $SvcAccountUser -SvcAccountPass $SvcAccountPass -ValidateConfig $ValidateConfig
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    
    param (
        [Parameter(Mandatory=$true)]
        [String]$FinesseServer,
        [Parameter(Mandatory=$true)]
        [String]$Username, 
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [String]$PrimaryDBHost,
        [Parameter(Mandatory=$true)]
        [String]$BackupDBHost,
        [Parameter(Mandatory=$true)]
        [String]$DBPort,
        [Parameter(Mandatory=$true)]
        [String]$DBName,
        [Parameter(Mandatory=$true)]
        [String]$SvcAccountDomain,
        [Parameter(Mandatory=$true)]
        [String]$SvcAccountUser,
        [Parameter(Mandatory=$true)]
        [String]$SvcAccountPass,
        [Parameter(Mandatory=$true)]
        [boolean]$ValidateConfig
    )

    Write-Log "INFO" "$($MyInvocation.MyCommand): Enter"

    $Body = "<EnterpriseDatabaseConfig><uri>/finesse/api/EnterpriseDatabaseConfig</uri><host>$PrimaryDBHost</host><backupHost>$BackupDBHost</backupHost><port>$DBPort</port><databaseName>$DBName</databaseName><domain>$SvcAccountDomain</domain><username>$SvcAccountUser</username><password>$SvcAccountPass</password></EnterpriseDatabaseConfig>"
    
    if ($ValidateConfig) {
        $response = Invoke-FinesseRestApi -FinesseServer $FinesseServer -Username $Username -Password $Password -OperationMethod PUT -ResourceType "EnterpriseDatabaseConfig?override=false" -Body $Body
    } else {
        $response = Invoke-FinesseRestApi -FinesseServer $FinesseServer -Username $Username -Password $Password -OperationMethod PUT -ResourceType "EnterpriseDatabaseConfig?override=true" -Body $Body
    }
    
    Write-Log "INFO" "$($MyInvocation.MyCommand): Exit"

    return $response

}

function Set-FinesseSystemConfig {
# Created: 20160912
    <#
    .SYNOPSIS
        Sets the System Config of a Finesse Node
    .DESCRIPTION
        Sets the System Config of a Finesse Node
    .PARAMETER FinesseServer
        The Finesse Server to be used for the request
    .PARAMETER Username
        Username to use to perform the request
    .PARAMETER Password
        Password to use to perform the request
    .PARAMETER PrimaryCTI
        The name of the primary CTI Server
    .PARAMETER PrimaryCTIPort
        The port of the primary CTI Server (typically 42027)
    .PARAMETER BackupCTI
        The name of the backup CTI Server
    .PARAMETER BackupCTIPort
        The port of the backup CTI Server (typically 43027)
    .PARAMETER PeripheralID
        The ICM PG Peripheral ID

    .EXAMPLE
        Set-FinesseSystemConfig -FinesseServer $FinesseServer -Username $Username -Password $Password -PrimaryCTI $PrimaryCTI -PrimaryCTIPort $PrimaryCTIPort -BackupCTI $BackupCTI -BackupCTIPort $BackupCTIPort -PeripheralID $PeripheralID
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>

    param (
        [Parameter(Mandatory=$true)]
        [String]$FinesseServer,
        [Parameter(Mandatory=$true)]
        [String]$Username, 
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [String]$PrimaryCTI,
        [Parameter(Mandatory=$true)]
        [String]$PrimaryCTIPort,
        [Parameter(Mandatory=$true)]
        [String]$BackupCTI,
        [Parameter(Mandatory=$true)]
        [String]$BackupCTIPort,
        [Parameter(Mandatory=$true)]
        [String]$PeripheralID
    )

    Write-Log "INFO" "$($MyInvocation.MyCommand): Enter"

    $Body = "<SystemConfig><uri>/finesse/api/SystemConfig</uri><cti><host>$PrimaryCTI</host><port>$PrimaryCTIPort</port><backupHost>$BackupCTI</backupHost><backupPort>$BackupCTIPort</backupPort><peripheralId>$PeripheralID</peripheralId></cti></SystemConfig>"
    
    $response = Invoke-FinesseRestApi -FinesseServer $FinesseServer -Username $Username -Password $Password -OperationMethod PUT -ResourceType "SystemConfig" -Body $Body
   
    Write-Log "INFO" "$($MyInvocation.MyCommand): Exit"

    return $response
}


function Set-FinesseLayoutConfig {
# Created: 20160912
    <#
    .SYNOPSIS
        Sets the System Config of a Finesse Node
    .DESCRIPTION
        Sets the System Config of a Finesse Node
    .PARAMETER FinesseServer
        The Finesse Server to be used for the request
    .PARAMETER Username
        Username to use to perform the request
    .PARAMETER Password
        Password to use to perform the request
    .PARAMETER FinesseLayoutXML
        Layout to apply
    .EXAMPLE
        Set-FinesseLayoutConfig -FinesseServer $FinesseServer -Username $Username -Password $Password -FinesseLayoutXML $FinesseLayoutXML
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>

    param (
        [Parameter(Mandatory=$true)]
        [String]$FinesseServer,
        [Parameter(Mandatory=$true)]
        [String]$Username, 
        [Parameter(Mandatory=$true)]
        [String]$Password,
        [Parameter(Mandatory=$true)]
        [String]$FinesseLayoutXML
    )

    Write-Log "INFO" "$($MyInvocation.MyCommand): Enter"

    $Body = '<LayoutConfig><layoutxml><?xml version="1.0" encoding="UTF-8">'+$FinesseLayoutXML+'</layoutxml></LayoutConfig>'
    $response = Invoke-FinesseRestApi -FinesseServer $FinesseServer -Username $Username -Password $Password -OperationMethod PUT -ResourceType "LayoutConfig/default" -Body $Body

    Write-Log "INFO" "$($MyInvocation.MyCommand): Exit"

    return $response
}

if ($Method -eq "ADD_SECONDARY") {

	$failstatus = $false
    try {

        $invokeclusterconfig = Set-FinesseClusterConfig -FinesseServer $FinesseServer -Username $Username -Password $Password -SecondaryNode $SecondaryNode
        Write-Log "INFO" "Successfully added Finesse Secondary to Configuration"

    } catch {

        $failstatus = $true
    }

    if ($failstatus) {

        try {

            Write-Log "INFO" "First Attempt failed, trying again"
            $invokeclusterconfig = Set-FinesseClusterConfig -FinesseServer $FinesseServer -Username $Username -Password $Password -SecondaryNode $SecondaryNode
            Write-Log "INFO" "Successfully added Finesse Secondary to Configuration"

        } catch {

            Write-Log "ERROR" "Unable to add Finesse secondary to configuration. Please add it manually using CFAdmin and then use Console access on the Secondary Server to proceed through install"
        }
    }

}