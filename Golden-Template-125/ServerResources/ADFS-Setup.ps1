Param (

    [parameter(Mandatory=$true)]
	[Boolean]$IsPrimary,
    [parameter(Mandatory=$true)]
	[String]$DomainName,
    [parameter(Mandatory=$true)]
	[String]$ADFSCompanyName,
    [parameter(Mandatory=$true)]
	[String]$ADFSThemeFolder,
    [parameter(Mandatory=$true)]
	[String]$ADFSPrimaryServer,
    [parameter(Mandatory=$true)]
	[String]$ADFSSVCAccountName,
    [parameter(Mandatory=$true)]
	[String]$ADFSSVCAccountPass

)

$Logfile = "C:\Software\Setup Scripts\ADFS-Setup.log"
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

Function Install-Primary-ADFS {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$CertificateThumbprint,
        [parameter(Mandatory=$true)]
	    [String]$FederationServiceDisplayName,
        [parameter(Mandatory=$true)]
	    [String]$FederationServiceName,
        [parameter(Mandatory=$true)]
	    [String]$SvcAccountUser,
        [parameter(Mandatory=$true)]
	    [String]$SvcAccountPass
    

    )

    $Result = "Success"
    

    try {

        $cred = New-Object System.Management.Automation.PSCredential($SvcAccountUser, (ConvertTo-SecureString $SvcAccountPass -AsPlainText -Force))
        Install-AdfsFarm -CertificateThumbprint:$CertificateThumbprint -FederationServiceDisplayName:$FederationServiceDisplayName -FederationServiceName:$FederationServiceName  -ServiceAccountCredential:$cred
        Write-Log "INFO" "Successfully installed primary ADFS"
        
    } catch {

        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
        
    }

    $Result

}

Function Set-ADFS-Properties {

    Param (

        [parameter(Mandatory=$true)]
	    [String]$ADFSCompanyName,
        [parameter(Mandatory=$true)]
	    [String]$ADFSThemeFolder
    

    )

    $Result = "Success"

    try {
		$CurrentYear = get-date -Format yyyy
		
		Set-AdfsProperties -CertificateDuration 3654
			
		Update-AdfsCertificate -CertificateType Token-Decrypting -Urgent
		
		Update-AdfsCertificate -CertificateType Token-Signing -Urgent
			
		Set-AdfsGlobalWebContent -CompanyName $ADFSCompanyName
		
		New-AdfsWebTheme -Name "ADFSTheme" -Illustration @{path="C:\adfstheme\$ADFSThemeFolder\illustration\illustration.png"} -Logo @{path="C:\adfstheme\$ADFSThemeFolder\logo\logo.png"} -StyleSheet @{locale="";path="C:\adfstheme\$ADFSThemeFolder\css\style.css"} -AdditionalFileResource @{Uri='/adfs/portal/script/onload.js';path="C:\adfstheme\$ADFSThemeFolder\script\onload.js"}
		
		if ($ADFSThemeFolder -eq "webex") {

			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/CiscoSansTTRegular.css";Path="C:\adfstheme\$ADFSThemeFolder\css\CiscoSansTTRegular.woff"}
			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/CiscoSansTTLight.css";Path="C:\adfstheme\$ADFSThemeFolder\css\CiscoSansTTLight.woff"}
			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/logoCisco.png";path="C:\adfstheme\$ADFSThemeFolder\illustration\logoCisco.png"}
			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/background.jpg";path="C:\adfstheme\$ADFSThemeFolder\illustration\background.jpg"}
			
			Set-AdfsGlobalWebContent -SignInPageDescriptionText "<img src='/adfs/portal/logoCisco.png' width='60.7px' height='32px'><p class='customDesc'>By using Webex Contact Center Enterprise, you accept the documented Terms of Service and Privacy Statements</p>"
		
		}
        elseif ($ADFSThemeFolder -eq "teletech") {

			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/CiscoSansTTRegular.css";Path="C:\adfstheme\$ADFSThemeFolder\css\CiscoSansTTRegular.woff"}
			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/CiscoSansTTLight.css";Path="C:\adfstheme\$ADFSThemeFolder\css\CiscoSansTTLight.woff"}
			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/logoCisco.png";path="C:\adfstheme\$ADFSThemeFolder\illustration\logoTTEC.png"}
			Set-AdfsWebTheme -TargetName ADFSTheme -AdditionalFileResource @{Uri="/adfs/portal/background.jpg";path="C:\adfstheme\$ADFSThemeFolder\illustration\background.jpg"}

			Set-AdfsGlobalWebContent -SignInPageDescriptionText "<img src='/adfs/portal/logoCisco.png' width='60.7px' height='32px'><p class='customDesc'>By using TTEC Contact Center Enterprise, you accept the documented Terms of Service and Privacy Statements</p>"

		}
        else {
			
			Set-AdfsGlobalWebContent -SignInPageDescriptionText "<P>Notice: You have accessed a private computer system. This system is for authorized use only and user activities are monitored and recorded by company personnel. Unauthorized access to or use of this system is strictly prohibited and constitutes a violation of federal and state criminal and civil laws, including Title 18, Section 1030 of the United States Code and applicable international laws. Violators will be prosecuted to the fullest extent of the law. By logging on you certify that you have read and understand these items and that you are authorized to access and use this system.</P><BR><P>Copyright © $CurrentYear - $ADFSCompanyName - All Rights Reserved"
			
		}

        Set-AdfsWebConfig -ActiveThemeName ADFSTheme
        
    } catch {

        
        Write-Log "INFO" $_.Exception.Message
        Failure-Message
        $Result = "Failure"
        
    }

    $Result

}

Write-Log "INFO" "ADFS Company Name: $ADFSCompanyName"
Write-Log "INFO" "ADFS Theme Folder: $ADFSThemeFolder"
Write-Log "INFO" "ADFS Primary Server: $ADFSPrimaryServer"
Write-Log "INFO" "ADFS Service Account Name: $ADFSSVCAccountName"
Write-Log "INFO" "ADFS Service Account Pass: *******"

   
$NetBiosNamePos = $DomainName.IndexOf(".")
$NetBiosName = $DomainName.Substring(0, $NetBiosNamePos)
$ADFSFQDN = "sso.$DomainName"

                    
Write-Log "INFO" "The Domain is: $DomainName"
Write-Log "INFO" "The NetBIOS name is: $NetBiosName"
Write-Log "INFO" "The ADFS FQDN will be: $ADFSFQDN"

Get-Item cert:\LocalMachine\My\*  | foreach { 
	$ADFSCertificateThumbprint = $_.Thumbprint
}

(Get-Content "C:\adfstheme\$ADFSThemeFolder\script\onload.js").replace('hc031', $NetBiosName) | Set-Content "C:\adfstheme\$ADFSThemeFolder\script\onload.js"
Write-Log "INFO" "Successfully updated NetBiosName occurances in onload.js to: $NetBiosName"

if ($IsPrimary) {
    
    Install-WindowsFeature ADFS-Federation
    Import-Module ADFS

    $InstallPrimaryADFS = Install-Primary-ADFS $ADFSCertificateThumbprint $ADFSCompanyName $ADFSFQDN $ADFSSVCAccountName $ADFSSVCAccountPass
    
    $SetADFSProperties = Set-ADFS-Properties $ADFSCompanyName $ADFSThemeFolder

    $SetADFSGlobalAuthPolicy = Set-AdfsGlobalAuthenticationPolicy -PrimaryExtranetAuthenticationProvider @('FormsAuthentication') -PrimaryIntranetAuthenticationProvider @('FormsAuthentication')
    Write-Log "INFO" "Successfully set ADFS Global Authentication Policy to Forms"

    $EnableADFSEndpoint = Enable-AdfsEndpoint -TargetAddress "/adfs/portal/updatepassword/"
    $EnableADFSEndpointProxy = Set-AdfsEndpoint -TargetAddress "/adfs/portal/updatepassword/" -Proxy $true
    Write-Log "INFO" "Successfully enabled ADFS Update Password Endpoint"

    $EnableADFSIDPSignOn = Set-AdfsProperties –EnableIdpInitiatedSignonPage $True
    Write-Log "INFO" "Successfully enabled ADFS IDPInitiatedSignonPage"

} else {

    $cred = New-Object System.Management.Automation.PSCredential($ADFSSVCAccountName, (ConvertTo-SecureString $ADFSSVCAccountPass -AsPlainText -Force))

    #Install secondary ADFS section
    Install-WindowsFeature ADFS-Federation
    Import-Module ADFS    


    try {
        Add-AdfsFarmNode -CertificateThumbprint:$ADFSCertificateThumbprint -ServiceAccountCredential:$cred -PrimaryComputerName:$ADFSPrimaryServer
        Write-Log "INFO" "Successfully added ADFS Farm Node" 
        
    } catch {
        Write-Log "ERROR" "ADFS setup failed"
    }
}