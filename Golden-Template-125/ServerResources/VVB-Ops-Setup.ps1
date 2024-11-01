Param (
     
    [parameter(Mandatory=$true)]
	[Array]$ServerAddresses
)

$Logfile = "C:\Software\Setup Scripts\VVB-Ops-Setup.log"
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

foreach ($ServerAddress in $ServerAddresses) {
    
    Write-Log "INFO" "Server Address to process is: $ServerAddress"
    $ServerAddressSplit = $ServerAddress.split(".")
    $ServerName = $ServerAddressSplit[0]

    
    $filename = "$ServerName.cer"
    Write-Log "INFO" "The file name will be: $filename"
    
    $HTTPPath = "https://$ServerAddress"

    Write-Log "INFO" "The cert will be fetched from $HTTPPath"

    $webRequest = [Net.WebRequest]::Create("$HTTPPath")
    $success = $true
    try { $webRequest.GetResponse() } catch {}

    try {
        $cert = $webRequest.ServicePoint.Certificate
        $bytes = $cert.Export([Security.Cryptography.X509Certificates.X509ContentType]::Cert)
        set-content -value $bytes -encoding byte -path "C:\Software\SSLCerts\$filename"
        
    } catch { 
        Write-Log "ERROR" "Unable to download server certificate for: $ServerAddress"
        $success = $false
        
    }

    if ($success) {

        Write-Log "INFO" "Importing $filename to CVP Ops Keystore $ServerName"

        Write-Log "INFO" "Getting the CVP Keystore Password"
        $KeystorePass = Get-Content "C:\Cisco\CVP\conf\security.properties"
        $KeystorePassArr = $KeystorePass.Split(" ")
        $KeystorePass = $KeystorePassArr[2]

        Write-Log "INFO" "Deleteing Certificate if it exists"
        C:\Cisco\CVP\jre\bin\keytool.exe -delete -alias $ServerName -file "C:\Software\SSLCerts\$filename" -keystore C:\Cisco\CVP\conf\security\.keystore -storetype JCEKS -storepass $KeystorePass -noprompt
        Write-Log "INFO" "Importing Certificate"
        C:\Cisco\CVP\jre\bin\keytool.exe -import -alias $ServerName -file "C:\Software\SSLCerts\$filename" -keystore C:\Cisco\CVP\conf\security\.keystore -storetype JCEKS -storepass $KeystorePass -trustcacerts -noprompt
        Write-Log "INFO" "Displaying Certificate Thumbprint"
        C:\Cisco\CVP\jre\bin\keytool.exe -list -alias $ServerName -file "C:\Software\SSLCerts\$filename" -keystore C:\Cisco\CVP\conf\security\.keystore -storetype JCEKS -storepass $KeystorePass -noprompt

    } 
}

