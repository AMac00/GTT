Param (
     
    [parameter(Mandatory=$true)]
	[String]$ServerIP,
    [parameter(Mandatory=$true)]
	[String]$PrimaryDNSIP,
    [parameter(Mandatory=$true)]
	[String]$SecondaryDNSIP
)

$Logfile = "C:\Software\Setup Scripts\AD-Primary-Final.log"
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

Function Get-Parameter {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$ParameterName

    )
        

        if (Test-Path 'C:\Software\Setup Scripts\passwords.txt') {
            Get-Content 'C:\Software\Setup Scripts\passwords.txt' | ForEach-Object {
                
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

Function Failure-Message {
    Write-Output ""
    Write-Log "ERROR" "A failure occurred.  Please review any error messages that exist above."
    Write-Log "WARN" "If you choose to continue without fixing the issue other downstream errors may be encountered"
    
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

try {
    Remove-Item "C:\Software\Setup Scripts\passwords.txt" -Confirm:$false
    Write-Log "INFO" "Successfully removed passwords file from server"
} catch {
    Write-Log "INFO" "Failed to remove passwords file from server"
}

Restart-Service -Name NlaSvc -Force
