Param (

    [parameter(Mandatory=$true)]
	[String]$WildcardCertPass

)

$Logfile = "C:\Software\Setup Scripts\CVP-Setup.log"
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
                    
Write-Log "INFO" "Getting the CVP Keystore Password"
$KeystorePass = Get-Content "C:\Cisco\CVP\conf\security.properties"
$KeystorePassArr = $KeystorePass.Split(" ")
$KeystorePass = $KeystorePassArr[2]

Write-Log "INFO" "Deleting existing Keystore Entries for VXML, CallServer and WSM"
$KeyStoreEntries = "vxml_certificate","callserver_certificate","wsm_certificate" 
Foreach ($KeyStoreEntry in $KeyStoreEntries) {
	C:\Cisco\CVP\jre\bin\keytool.exe -delete -keystore C:\Cisco\CVP\conf\security\.keystore -storetype JCEKS -alias $KeyStoreEntry -storepass $KeystorePass
}

Write-Log "INFO" "Getting the Wildcard Certificate Alias Name"
$WildcardAlias = C:\Cisco\CVP\jre\bin\keytool.exe -list -keystore "C:\Software\SSLCerts\wildcard.pfx" -storetype pkcs12 -storepass $WildcardCertPass -v | grep 'Alias name:'
$WildcardAliasArr = $WildcardAlias.Split([string[]]"Alias name: ", [StringSplitOptions]::None)
Write-Log "INFO" "The Wildcard Certificate Alias Name is: $($WildcardAliasArr[1])"

Write-Log "INFO" "Importing Wildcard for VXML, CallServer and WSM entries. Setting keypass to the same as the keystore"
Write-Log "INFO" "If you are deploying an Ops Console, you can ignore the message stating that the callserver-Certifciate and vxml_certificate aliases were not found and could not be removed.  This is expected"

Foreach ($KeyStoreEntry in $KeyStoreEntries) {
	
	C:\Cisco\CVP\jre\bin\keytool.exe -importkeystore -alias $WildcardAliasArr[1] -srckeystore "C:\Software\SSLCerts\wildcard.pfx" -srcstorepass $WildcardCertPass -destkeystore C:\Cisco\CVP\conf\security\.keystore -deststoretype JCEKS -deststorepass $KeystorePass -destalias $KeyStoreEntry -trustcacerts -noprompt
	
	C:\Cisco\CVP\jre\bin\keytool.exe -keypasswd -alias $KeyStoreEntry -keystore C:\Cisco\CVP\conf\security\.keystore -storetype JCEKS -storepass $KeystorePass -keypass $WildcardCertPass -new $KeystorePass -noprompt
	
}


Write-Log "INFO" "Importing Root Certificate"
C:\Cisco\CVP\jre\bin\keytool.exe -import -alias root -file "C:\Software\SSLCerts\bundle.crt" -keystore C:\Cisco\CVP\conf\security\.keystore -storetype JCEKS -storepass $KeystorePass -trustcacerts -noprompt

Write-Log "INFO" "CVP Setup has finished execution"