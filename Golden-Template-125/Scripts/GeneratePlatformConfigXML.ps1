$GTHomePath = $HOME_PATH

Function GetShortCountryName($FullName,[REF]$ShortName,[REF]$Success, [REF]$ErrorMsg)
{	
    $ShortName.Value = ""
    switch ($FullName)
	{

	"Aaland Islands"                          {$ShortName.Value = "AX"}
	"Afghanistan"							  {$ShortName.Value = "AF"}
	"Albania"                                 {$ShortName.Value = "AL"}
	"Algeria"								  {$ShortName.Value = "DZ"}
	"Andorra"								  {$ShortName.Value = "AD"}
	"Angola"								  {$ShortName.Value = "AO"}	
	"Anguilla"								  {$ShortName.Value = "AI"}	
	"Antarctica"							  {$ShortName.Value = "AQ"}	
	"Antigua & Barbuda"						  {$ShortName.Value = "AG"}	
	"Argentina"								  {$ShortName.Value = "AR"}	
	"Armenia"								  {$ShortName.Value = "AM"}
	"Aruba"									  {$ShortName.Value = "AW"}
	"Austria"								  {$ShortName.Value = "AT"} 
	"Australia"								{$ShortName.Value = "AU"} 
	"Azerbaijan"							{$ShortName.Value = "AZ"} 
	"Bahamas"								{$ShortName.Value = "BS"} 
	"Bahrain"								{$ShortName.Value = "BH"} 
	"Bangladesh"							{$ShortName.Value = "BD"} 
	"Barbados"								{$ShortName.Value = "BB"} 
	"Belarus"								{$ShortName.Value = "BY"} 	
	"Belgium"								{$ShortName.Value = "BE"} 
	"Belize"								{$ShortName.Value = "BZ"} 
	"Benin"									{$ShortName.Value = "BJ"} 
	"Bermuda"								{$ShortName.Value = "BM"} 
	"Bhutan"								{$ShortName.Value = "BJ"} 
	"Bolivia"								{$ShortName.Value = "BO"} 
	"Bosnia & Herzegovina"					{$ShortName.Value = "BA"} 
	"Botswana"								{$ShortName.Value = "BW"} 
	"Bouvet Island"							{$ShortName.Value = "BV"} 
	"Brazil"								{$ShortName.Value = "BR"} 
	"British Indian Ocean Territory"		{$ShortName.Value = "IO"} 
	"Brunei"								{$ShortName.Value = "BN"} 
	"Bulgaria"								{$ShortName.Value = "BG"} 
	"Burkina Faso"							{$ShortName.Value = "BF"} 
	"Burundi"								{$ShortName.Value = "BI"} 
	"Cambodia"								{$ShortName.Value = "KH"} 
	"Cameroon"								{$ShortName.Value = "CM"} 
	"Canada"								{$ShortName.Value = "CA"} 
	"Cape Verde"							{$ShortName.Value = "CV"} 
	"Cayman Islands"						{$ShortName.Value = "KY"} 
	"Central African Rep."					{$ShortName.Value = "CF"} 
	"Chad"									{$ShortName.Value = "TD"} 
	"Chile"									{$ShortName.Value = "CL"} 
	"China"									{$ShortName.Value = "CN"} 
	"Christmas Island"						{$ShortName.Value = "CX"} 
	"Cocos (Keeling) Islands"				{$ShortName.Value = "CC"} 
	"Colombia"								{$ShortName.Value = "CO"} 
	"Comoros"								{$ShortName.Value = "KM"} 
	"Congo (Dem. Rep.)"						{$ShortName.Value = "CD"} 
	"Congo (Rep.)"							{$ShortName.Value = "CG"} 
	"Cook Islands"							{$ShortName.Value = "CK"} 
	"Cote d'Ivoire"							{$ShortName.Value = "CI"} 
	"Costa Rica"							{$ShortName.Value = "CR"} 
	"Croatia"								{$ShortName.Value = "HR"} 
	"Cuba"									{$ShortName.Value = "CU"} 
	"Cyprus"								{$ShortName.Value = "CY"} 
	"Czech Republic"						{$ShortName.Value = "CZ"} 
	"Denmark"								{$ShortName.Value = "DK"} 
	"Djibouti"								{$ShortName.Value = "DJ"} 
	"Dominica"								{$ShortName.Value = "DM"} 
	"Dominican Republic"					{$ShortName.Value = "DO"} 
	"East Timor"							{$ShortName.Value = "TL"} 
	"Ecuador"								{$ShortName.Value = "EC"} 
	"Egypt"									{$ShortName.Value = "EG"} 
	"El Salvador"							{$ShortName.Value = "SV"} 
	"Eritrea"								{$ShortName.Value = "ER"} 
	"Estonia"								{$ShortName.Value = "EE"} 
	"Ethiopia"								{$ShortName.Value = "ET"} 
	"Equatorial Guinea"						{$ShortName.Value = "GQ"} 
	"Faeroe Islands"						{$ShortName.Value = "FO"} 
	"Falkland Islands"						{$ShortName.Value = "FK"} 
	"Finland"								{$ShortName.Value = "FI"} 
	"Fiji"									{$ShortName.Value = "FJ"} 
	"France"								{$ShortName.Value = "FR"} 
	"French Guiana"							{$ShortName.Value = "GF"} 
	"French Polynesia"						{$ShortName.Value = "PF"} 
	"French Southern & Antarctic Lands"		{$ShortName.Value = "TF"} 
	"Gabon"									{$ShortName.Value = "GA"} 
	"Gambia"								{$ShortName.Value = "GM"} 
	"Georgia"								{$ShortName.Value = "GE"} 
	"Germany"								{$ShortName.Value = "DE"} 
	"Ghana"									{$ShortName.Value = "GH"} 
	"Gibraltar"								{$ShortName.Value = "GI"} 
	"Greece"								{$ShortName.Value = "GR"} 
	"Greenland"								{$ShortName.Value = "GL"} 
	"Grenada"								{$ShortName.Value = "GD"} 
	"Guineav"								{$ShortName.Value = "GN"} 
	"Guadeloupe"							{$ShortName.Value = "GP"} 
	"Guatemala"								{$ShortName.Value = "GT"} 
	"Guam"									{$ShortName.Value = "GU"} 
	"Guinea-Bissau"							{$ShortName.Value = "GW"} 
	"Guyana"								{$ShortName.Value = "GY"} 
	"Haiti"									{$ShortName.Value = "HT"} 
	"Heard Island & McDonald Islands"		{$ShortName.Value = "HM"} 
	"Honduras"								{$ShortName.Value = "HN"} 
	"Hong Kong"								{$ShortName.Value = "HK"} 
	"Hungary"								{$ShortName.Value = "HU"} 
	"Iceland"								{$ShortName.Value = "IS"} 
	"India"									{$ShortName.Value = "IN"} 
	"Indonesia"								{$ShortName.Value = "ID"} 
	"Iran"									{$ShortName.Value = "IR"} 
	"Iraq"									{$ShortName.Value = "IQ"} 
	"Ireland"								{$ShortName.Value = "IE"} 
	"Israel"								{$ShortName.Value = "IL"} 
	"Italy"									{$ShortName.Value = "IT"} 
	"Jamaica"								{$ShortName.Value = "JM"} 
	"Japan"									{$ShortName.Value = "JP"} 
	"Jordan"								{$ShortName.Value = "JO"} 
	"Kazakhstan"							{$ShortName.Value = "KZ"} 
	"Kenya"									{$ShortName.Value = "KE"} 
	"Kiribati"								{$ShortName.Value = "KI"} 
	"Korea (North)"							{$ShortName.Value = "KP"} 
	"Korea (South)"							{$ShortName.Value = "KR"} 
	"Kuwait"								{$ShortName.Value = "KW"} 
	"Kyrgyzstan"							{$ShortName.Value = "KG"} 
	"Laos"									{$ShortName.Value = "LA"} 
	"Latvia"								{$ShortName.Value = "LV"} 
	"Lebanon"								{$ShortName.Value = "LB"} 
	"Lesotho"								{$ShortName.Value = "LS"} 
	"Liberia"								{$ShortName.Value = "LR"} 
	"Libya"									{$ShortName.Value = "LY"} 
	"Liechtenstein"							{$ShortName.Value = "LI"} 
	"Lithuania"								{$ShortName.Value = "LT"} 
	"Luxembourg"							{$ShortName.Value = "LU"} 
	"Macau"									{$ShortName.Value = "MO"} 
	"Macedonia"								{$ShortName.Value = "MK"} 
	"Madagasca"								{$ShortName.Value = "MG"} 
	"Malawi"								{$ShortName.Value = "MW"} 
	"Malaysia"								{$ShortName.Value = "MY"} 
	"Maldives"								{$ShortName.Value = "MV"} 
	"Mali"									{$ShortName.Value = "ML"} 
	"Malta"									{$ShortName.Value = "MT"} 
	"Marshall Islands"						{$ShortName.Value = "MH"} 
	"Martinique"							{$ShortName.Value = "MQ"} 
	"Mauritania"							{$ShortName.Value = "MR"} 
	"Mauritius"								{$ShortName.Value = "MU"} 
	"Mayotte"								{$ShortName.Value = "YT"} 
	"Mexico"								{$ShortName.Value = "MX"} 
	"Micronesia"							{$ShortName.Value = "FM"} 
	"Moldova"								{$ShortName.Value = "MD"} 
	"Monaco"								{$ShortName.Value = "MC"} 
	"Mongolia"								{$ShortName.Value = "MN"} 
	"Montserrat"							{$ShortName.Value = "MS"} 
	"Morocco"								{$ShortName.Value = "MA"} 
	"Mozambique"							{$ShortName.Value = "MZ"} 
	"Myanmar (Burma)"						{$ShortName.Value = "MM"} 
	"Namibia"								{$ShortName.Value = "NA"} 
	"Nauru"									{$ShortName.Value = "NR"} 
	"Nepal"									{$ShortName.Value = "NP"} 
	"Netherlands"							{$ShortName.Value = "NL"} 
	"Netherlands Antilles"					{$ShortName.Value = "AN"} 
	"New Caledonia"							{$ShortName.Value = "NC"} 
	"New Zealand"							{$ShortName.Value = "NZ"} 
	"Nicaragua"								{$ShortName.Value = "NI"} 
	"Niger"									{$ShortName.Value = "NE"} 
	"Nigeria"								{$ShortName.Value = "NG"} 
	"Niue"									{$ShortName.Value = "NU"} 
	"Norfolk Island"						{$ShortName.Value = "NF"} 
	"Northern Mariana Islands"				{$ShortName.Value = "MP"} 
	"Norway"								{$ShortName.Value = "NO"} 
	"Oman"									{$ShortName.Value = "OM"} 
	"Pakistan"								{$ShortName.Value = "PK"} 
	"Palau"									{$ShortName.Value = "PW"} 
	"Palestine"								{$ShortName.Value = "PS"} 
	"Panama"								{$ShortName.Value = "PA"} 
	"Papua New Guinea"						{$ShortName.Value = "PG"} 
	"Paraguay"								{$ShortName.Value = "PY"} 
	"Peru"									{$ShortName.Value = "PE"} 
	"Philippines"							{$ShortName.Value = "PH"} 
	"Pitcairn"								{$ShortName.Value = "PN"} 
	"Poland"								{$ShortName.Value = "PL"} 
	"Portugalv"								{$ShortName.Value = "PT"} 
	"Puerto Rico"							{$ShortName.Value = "PR"} 
	"Qatar"									{$ShortName.Value = "QA"} 
	"Reunion"								{$ShortName.Value = "RE"} 
	"Romania"								{$ShortName.Value = "RO"} 
	"Russia"								{$ShortName.Value = "RU"} 
	"Rwanda"								{$ShortName.Value = "RW"} 
	"Samoa (American)"						{$ShortName.Value = "AS"} 
	"Samoa (Western)"						{$ShortName.Value = "WS"} 
	"San Marino"							{$ShortName.Value = "SM"} 
	"Sao Tome & Principe"					{$ShortName.Value = "ST"} 
	"Saudi Arabia"							{$ShortName.Value = "SA"} 
	"Senegal"								{$ShortName.Value = "SN"} 
	"Serbia and Montenegro"					{$ShortName.Value = "CS"} 
	"Seychelles"							{$ShortName.Value = "SC"} 
	"Sierra Leone"							{$ShortName.Value = "SL"} 
	"Singapore"								{$ShortName.Value = "SG"} 
	"Slovakia"								{$ShortName.Value = "SK"} 
	"Slovenia"								{$ShortName.Value = "SI"} 
	"Solomon Islands"						{$ShortName.Value = "SB"} 
	"Somalia"								{$ShortName.Value = "SO"} 
	"South Africa"							{$ShortName.Value = "ZA"} 
	"South Georgia & the South Sandwich Islands"							{$ShortName.Value = "GS"} 
	"Spain"								{$ShortName.Value = "ES"} 
	"Sri Lanka"							{$ShortName.Value = "LK"} 
	"St Kitts & Nevis"					{$ShortName.Value = "KN"} 
	"St Helena"							{$ShortName.Value = "SH"} 
	"St Lucia"							{$ShortName.Value = "LC"} 
	"St Pierre & Miquelon"				{$ShortName.Value = "PM"} 
	"St Vincent"						{$ShortName.Value = "VC"} 
	"Sudan"								{$ShortName.Value = "SD"} 
	"Suriname"							{$ShortName.Value = "SR"} 
	"Svalbard & Jan Mayen"				{$ShortName.Value = "SJ"} 
	"Swaziland"							{$ShortName.Value = "SZ"} 
	"Sweden"							{$ShortName.Value = "SE"} 
	"Switzerland"						{$ShortName.Value = "CH"} 
	"Syria"								{$ShortName.Value = "SY"} 
	"Taiwan"							{$ShortName.Value = "TW"} 
	"Tajikistan"						{$ShortName.Value = "TJ"} 
	"Tanzania"							{$ShortName.Value = "TZ"} 
	"Thailand"							{$ShortName.Value = "TH"} 
	"Togo"								{$ShortName.Value = "TG"} 
	"Tokelau"							{$ShortName.Value = "TK"} 
	"Tonga"								{$ShortName.Value = "TO"} 
	"Tunisia"							{$ShortName.Value = "TN"} 
	"Turkey"							{$ShortName.Value = "TR"} 
	"Turkmenistan"						{$ShortName.Value = "TM"} 
	"Turks & Caicos Is"					{$ShortName.Value = "TC"} 
	"Trinidad & Tobago"					{$ShortName.Value = "TT"} 
	"Tuvalu"							{$ShortName.Value = "TV"} 
	"Uganda"							{$ShortName.Value = "UG"} 
	"Ukraine"							{$ShortName.Value = "UA"} 
	"United Arab Emirates"				{$ShortName.Value = "AE"} 
	"United Kingdom"					{$ShortName.Value = "GB"} 
	"United States of America"			{$ShortName.Value = "US"} 
	"Uruguay"							{$ShortName.Value = "UY"} 
	"US minor outlying islands"			{$ShortName.Value = "UM"} 
	"Uzbekistan"						{$ShortName.Value = "UZ"} 
	"Vanuatu"							{$ShortName.Value = "VU"} 
	"Vatican City"						{$ShortName.Value = "VA"} 
	"Venezuela"							{$ShortName.Value = "VE"} 
	"Vietnam"							{$ShortName.Value = "VN"} 
	"Virgin Islands (UK)"				{$ShortName.Value = "VG"} 
	"Virgin Islands (US)"				{$ShortName.Value = "VI"} 
	"Wallis & Futuna"					{$ShortName.Value = "WF"} 
	"Western Sahara"					{$ShortName.Value = "EH"} 
	"Yemen"								{$ShortName.Value = "YE"} 
	"Zambia"							{$ShortName.Value = "ZM"} 
	"Zimbabwe"   						{$ShortName.Value = "ZW"}

	}
	
	if($ShortName.Value -eq "")
	{
		$Success.Value = $false
		$ErrorMsg.Value = "The Country Name provided is invalid"
		$ShortName.Value = "none" #Setting it to Default
	}
	else
	{
		$Success.Value = $true
		$ErrorMsg.Value = "The Country Name provided is valid"
	}
}

Function CreatePlatformChildNode($ConfigFileWriter, $ParentNodeName,$ParamNameTextValue,$ParamDefaultValue,$ParamValue)
{
	#<ProductDeployment>
	$ConfigFileWriter.WriteStartElement($ParentNodeName)

	#<ParamNameText>Deployment</ParamNameText>
	$ConfigFileWriter.WriteElementString("ParamNameText", $ParamNameTextValue) 

	#<ParamDefaultValue>CallManager</ParamDefaultValue>
	$ConfigFileWriter.WriteElementString("ParamDefaultValue", $ParamDefaultValue) 

	if($ParamValue -like "NULL")
	{
		#<ParamValue/>
		$ConfigFileWriter.WriteStartElement("ParamValue")
        #$ConfigFileWriter.WriteFullEndElement()
		$ConfigFileWriter.WriteEndElement()
		
	}
	else
	{
		#<ParamValue>callmanager</ParamValue>
		$ConfigFileWriter.WriteElementString("ParamValue", $ParamValue) 
	}
	

	#</ProductDeployment>
	$ConfigFileWriter.WriteEndElement()
}

Function WriteORAClusterNodes ($ConfigFileWriter, $ORAClusterNodes,$ORANode, $NodeAddress, $NodeType)
{
<#******************EXAMPLE***************
<ORAClusterNodes>
    <ORANode>
      <NodeAddress>
        <ParamNameText>IP Address of the node</ParamNameText>
        <ParamDefaultValue>none</ParamDefaultValue>
        <ParamValue>10.10.10.230</ParamValue>
      </NodeAddress>
      <NodeType>
        <ParamNameText>Type of the ORA Node (Primary | Secondary | Expansion)</ParamNameText>
        <ParamDefaultValue>none</ParamDefaultValue>
        <ParamValue>Primary</ParamValue>
      </NodeType>
    </ORANode>
  </ORAClusterNodes>
#>

$ConfigFileWriter.WriteStartElement($ORAClusterNodes)
$ConfigFileWriter.WriteStartElement($ORANode)
CreatePlatformChildNode $ConfigFileWriter "NodeAddress" "IP Address of the node" "none" $NodeAddress
CreatePlatformChildNode $ConfigFileWriter "NodeType" "Type of the ORA Node (Primary | Secondary | Expansion)" "none" $NodeType 

$ConfigFileWriter.WriteEndElement()
$ConfigFileWriter.WriteEndElement()


}

#########################################################################################################

Function CreatePlatformConfigXML ($TimeStamp, $Global_Vm_array,[REF]$Success, [REF]$ErrorMsg)
{
	$Success.Value = $true
	$ErrorMsg.Value = "Succeeded"
	#Calling Platform Config File Generator for all VOS products
	CreatePlatformConfigXMLforVOS $TimeStamp $Global_Vm_array ([REF]$Success) ([REF]$ErrorMsg)
}
################################################################################################################
#Get the DeploymentName for each VOS product at a time.
################################################################################################################
Function GetProductDeploymentName ($TYPEofVM , [REF]$DeploymentName)
{
	switch -wildcard ($TYPEofVM)
	{
		"CUCM*" 		{$DeploymentName.value = "callmanager"}
		"UNITY*" 		{$DeploymentName.value = "connection"}
		"FINESSE*" 		{$DeploymentName.value = "finesse"}
		"VVB*" 			{$DeploymentName.value = "voicebrowser"}
		"MEDIASENSE*"	{$DeploymentName.value = "ora"}
		"CUICLDwithIDS*"	{$DeploymentName.value = "intelligencecenter"}
		"CUIC_*"		{$DeploymentName.value = "intelligencecenter_cuic_only"}
		"LiveData*"		{$DeploymentName.value = "tempesta"}
		"Cisco_IDS*"			{$DeploymentName.value = "ids"}
		"PRESENCE*"			{$DeploymentName.value = "cups"}
        "EXPRESS*"			{$DeploymentName.value = "contactcenterxpress"}
		"Cloud_Connect*"			{$DeploymentName.value = "cloudconnect"}
	}
}

################################################################################################################
Function CreatePlatformConfigXMLforVOS ($TimeStamp, $Global_Vm_array,[REF]$Success, [REF]$ErrorMsg)
{
	$Success.Value = $true
	$ErrorMsg.Value = "Succeeded"
	$PubData = ""
		
	foreach ($vm in $Global_Vm_array)
	{	
		$ProductDeploymentName = ""
		$index = $vm.VM_TYPE.IndexOf("_")
		$VMnameTruncated = $vm.VM_TYPE.Substring(0, $index) #VM name truncated to use for information
		GetProductDeploymentName $vm.VM_TYPE ([REF]$ProductDeploymentName)
		if($vm.SERVERNUM -eq "01") {
			Log-Message -Type "INFO" -Message "Copying $($vm.VM_TYPE) publisher data for use with subscriber"
			switch -wildcard ($vm.VM_TYPE) {
				"Cisco_IDS*" {
					$IDSPubData = $vm
				} "LiveData*" {
					$LiveDataPubData = $vm
				} "FINESSE*" {
					$FinessePubData = $vm
				} "CUIC*" {
					$CUICPubData = $vm
				} "CUCM*" {
					$CUCMPubData = $vm
				} "UNITY*" {
					$CUCPubData = $vm
				} "MEDIASENSE*" {
					$MediaSensePubData = $vm
				} "EXPRESS*" {
					$ExpressPubData = $vm
				} "Cloud_Connect*" {
					$CLCPubData = $vm
				}
			}
			
		}
		
		if($vm.CREATEVM -like "YES" -and $vm.CUSTOMIZATION -like "YES" -and $vm.Operation -ne "ExportServer" -and $vm.TASK_STATUS -eq "Success" )
		{
			if($ProductDeploymentName) {		
				
                $DirName = "$($GTHomePath)\PlatformConfigRepository\$($VMnameTruncated)\$($TimeStamp)\$($vm.VM_TYPE)"
			    [IO.Directory]::CreateDirectory($DirName)
				
				if(($vm.SERVERNUM -notmatch "01") -or ($vm.VM_TYPE -match "PRESENCE"))
				{	
					switch -wildcard ($vm.VM_TYPE) {
						"Cisco_IDS*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($IDSPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $IDSPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($IDSPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $IDSPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $IDSPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $IDSPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $IDSPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $IDSPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "LiveData*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($LiveDataPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $LiveDataPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($LiveDataPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $LiveDataPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $LiveDataPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $LiveDataPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $LiveDataPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $LiveDataPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "FINESSE*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($FinessePubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $FinessePubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($FinessePubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $FinessePubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $FinessePubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $FinessePubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $FinessePubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $FinessePubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "CUIC*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($CUICPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $CUICPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($CUICPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $CUICPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $CUICPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $CUICPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $CUICPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $CUICPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "CUCM*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($CUCMPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $CUCMPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($CUCMPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $CUCMPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $CUCMPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $CUCMPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $CUCMPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $CUCMPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "UNITY*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($CUCPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $CUCPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($CUCPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $CUCPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $CUCPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $CUCPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $CUCPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $CUCPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "MEDIASENSE*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($MediaSensePubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $MediaSensePubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($MediaSensePubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $MediaSensePubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $MediaSensePubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $MediaSensePubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $MediaSensePubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $MediaSensePubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "PRESENCE*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($CUCMPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $CUCMPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($CUCMPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $CUCMPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $CUCMPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $CUCMPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $CUCMPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $CUCMPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "EXPRESS*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($ExpressPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $ExpressPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($ExpressPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $ExpressPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $ExpressPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $ExpressPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $ExpressPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $ExpressPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						} "Cloud_Connect*" {
							Log-Message -Type "DEBUG" -Message "Saved Publisher Host Name is: $($CLCPubData.COMPUTER_NAME)"
							$vm.CCMDBHost = $CLCPubData.COMPUTER_NAME
							Log-Message -Type "DEBUG" -Message "Saved Publisher IP is: $($CLCPubData.IP_ADDRESS_NIC1)"
							$vm.CCMDBIPADDR = $CLCPubData.IP_ADDRESS_NIC1		

							$vm.NTPSERVERHOST = $CLCPubData.COMPUTER_NAME
							$vm.NTPSERVERIPADDR = $CLCPubData.IP_ADDRESS_NIC1				
							
							$vm.IPSECMASTERHOST = $CLCPubData.COMPUTER_NAME
							$vm.IPSECMASTERIPADDR = $CLCPubData.IP_ADDRESS_NIC1
							
							$vm.CCMFIRSTNODE = "no"
							$vm.IPSECFIRSTNODE = "no"
						}
					}
				}
								
				Log-Message -Type "INFO" -Message "Creating PlatformConfig XML for $($vm.VM_TYPE)"
			
				$settings = New-Object system.Xml.XmlWriterSettings 
				$settings.Indent = $true 
				$settings.OmitXmlDeclaration = $false 
				$settings.NewLineOnAttributes = $true			
				
				$filename = $DirName + "\platformConfig.xml"
				
				# Create a new Writer 
				$writer = [system.xml.XmlWriter]::Create($filename, $settings)
								 
				######
				#<PlatformData>
				$writer.WriteStartElement("PlatformData")

				if($vm.PRODUCT_VERSION)
				{
					$writer.WriteElementString("Version", $vm.PRODUCT_VERSION) 
				}
				else
				{
					$writer.WriteElementString("Version", "12.5.1")
				}

				CreatePlatformChildNode $writer "ProductDeployment" "Deployment" "CallManager" $ProductDeploymentName
				
				if($vm.VM_TYPE -match "PRESENCE")
				{
					CreatePlatformChildNode $writer "ImpDomainName" "First IMP node domain name" "none" $vm.DOMAIN_NAME
				}
				
				CreatePlatformChildNode $writer "PlatformConfigurationDone" "Status of platform configuration" "no" "no"
				CreatePlatformChildNode $writer "PreLoadedSoftware" "Create a pre loaded software node" "no" "yes" 
				CreatePlatformChildNode $writer "InstallType" "Install or upgrade type" "basic" "Basic Install"
				CreatePlatformChildNode $writer "LocalHostNICAuto" "Auto Configure speed and duplex" "yes" "yes"
				CreatePlatformChildNode $writer "LocalHostName" "Host Name for this machine" "localhost" $vm.COMPUTER_NAME
				CreatePlatformChildNode $writer "LocalHostDHCP" "Is DHCP enabled for this machine" "no" "no"
				CreatePlatformChildNode $writer "LocalHostIP0" "Host IP0 addr for this node" "127.0.0.1" $vm.IP_ADDRESS_NIC1
				CreatePlatformChildNode $writer "LocalHostMask0" "Host IP0 mask for this node" "255.255.255.0" $vm.SUB_NET_MASK_NIC1
				CreatePlatformChildNode $writer "LocalHostGW0" "Gateway for this node" "127.0.0.1" $vm.DEFAULT_GATEWAY_NIC1
				
				if($vm.DNS_IP_NIC1 -and $vm.DOMAIN_NAME)
				{
					#Create the nodes only if Domain Name and DNS IP is provided.
					CreatePlatformChildNode $writer "LocalHostDnsPrimary" "Primary DNS server IP address" "0.0.0.0" $vm.DNS_IP_NIC1
					if($vm.DNS_ALTERNATE_NIC1)
					{
						CreatePlatformChildNode $writer "LocalHostDnsSecondary" "Secondary DNS server IP address" "0.0.0.0" $vm.DNS_ALTERNATE_NIC1
					}
					else
					{
						CreatePlatformChildNode $writer "LocalHostDnsSecondary" "Secondary DNS server IP address" "0.0.0.0" ""
					}

					CreatePlatformChildNode $writer "LocalHostDomain" "Domain name for this machine" "cisco.com" $vm.DOMAIN_NAME
				}
				
				CreatePlatformChildNode $writer "LocalHostTimezone" "Timezone for this node" "America/Los_Angeles" $vm.TIME_ZONE_LINUX
				CreatePlatformChildNode $writer "LocalHostContinent" "Continent for this node" "America" $vm.TIME_ZONE_LINUX_AREA
				CreatePlatformChildNode $writer "LocalHostCity" "City for this node" "Los_Angeles" $vm.TIME_ZONE_LINUX_LOCATION
				
				CreatePlatformChildNode $writer "LocalHostAdminName" "Administrator name for this node" "administrator" $vm.AdminUserName
				CreatePlatformChildNode $writer "LocalHostAdminPwCrypt" "Admin PW for this node" "password" $vm.AdminAndClusterPW

				#</CertX509>
				$writer.WriteStartElement("CertX509")
				CreatePlatformChildNode $writer "Org" "Certification Signing Request Organization" "none" $vm.ORGANIZATION_Name
				CreatePlatformChildNode $writer "Unit" "Certification Signing Request Unit" "none" $vm.ORGANIZATION_UNIT
				CreatePlatformChildNode $writer "Location" "Certification Signing Request Location" "none" $vm.ORGANIZATION_LOCATION
				CreatePlatformChildNode $writer "State" "Certification Signing Request State" "none" $vm.ORGANIZATION_STATE
				
				$ShortName = ""
				$GetShortNameSuccess = $false
				$GetShortNameErrorMsg = ""		
				GetShortCountryName $vm.ORGANIZATION_COUNTRY ([REF]$ShortName) ([REF]$GetShortNameSuccess) ([REF]$GetShortNameErrorMsg)
				$vm.ORGANIZATION_COUNTRY = $ShortName
				CreatePlatformChildNode $writer "Country" "Certification Signing Request Country" "none" $vm.ORGANIZATION_COUNTRY

				#</CertX509>
				$writer.WriteEndElement()

				CreatePlatformChildNode $writer "LocaleId" "Microsoft assigned locale identifier value" "00000409" "" ##Fix it
				CreatePlatformChildNode $writer "CCMVersion" "CM version on the server backed up" "CCM ver 5.0" "" ##Fix it
				#VVB Parameter is different.
				if($vm.VM_TYPE -match "VVB")
				{
					CreatePlatformChildNode $writer "CcmFirstNode" "First CCM node in the cluster" "yes" "yes"
				}
				else
				{
					CreatePlatformChildNode $writer "CcmFirstNode" "First CCM node in the cluster" "yes" $vm.CCMFIRSTNODE
				}
				#Required only for CUCM.
				if(($vm.VM_TYPE -match "CUCM") -or ($vm.VM_TYPE -match "UNITY"))
				{
					CreatePlatformChildNode $writer "CallHomeDisable" "This tag will be present when SCH and ACH is disabled by the user" "Disable" "Disable"
				}
				
				CreatePlatformChildNode $writer "SftpPwCrypt" "Security PW for this node" "password" $vm.AdminAndClusterPW
				
				CreatePlatformChildNode $writer "IPSecFirstNode" "First IPSec node in the cluster" "yes" $vm.IPSECFIRSTNODE
				CreatePlatformChildNode $writer "IPSecEnabled" "IPSec Configuration for this node" "no" "no"
				
				CreatePlatformChildNode $writer "IPSecSecurityPwCrypt" "Security PW for this node" "password" $vm.AdminAndClusterPW
				
				if((($vm.SERVERNUM -notmatch "01") -or ($vm.VM_TYPE -match "PRESENCE")) -and ($vm.VM_TYPE -notmatch "VVB_")) {			 
					CreatePlatformChildNode $writer "CcmDBHost" "Host Name for DataBase" "none" $vm.CCMDBHost	
					CreatePlatformChildNode $writer "CcmDBIpAddr" "Host IP Addr for DataBase" "none" $vm.CCMDBIPADDR
				
					CreatePlatformChildNode $writer "IPSecMasterHost" "Host name for IPSec" "none" $vm.IPSECMASTERHOST
					
					if($vm.VM_TYPE -match "CUCM")
					{
						CreatePlatformChildNode $writer "IPSecMasterIpAddr" "Cluster NTP Server Host name" "none" $vm.IPSECMASTERIPADDR
					}
					else
					{
						CreatePlatformChildNode $writer "IPSecMasterIpAddr" "Host IP Addr for IPSec" "none" $vm.IPSECMASTERIPADDR
					}
				
					CreatePlatformChildNode $writer "NTPServerHost" "Cluster NTP Server Host name" "none" $vm.NTPSERVERHOST
					CreatePlatformChildNode $writer "NTPServerIpAddr" "Cluster NTP Server Host IP Addr" "none" $vm.NTPSERVERIPADDR			
					
				} elseif(($vm.SERVERNUM -match "01") -or ($vm.VM_TYPE -match "VVB_")) {
					#Pending : Fix it
					CreatePlatformChildNode $writer "NtpServer" "Address Range for NTP server" "none" $vm.NTP_SERVER
                    CreatePlatformChildNode $writer "NtpServer" "Address Range for NTP server" "none" $vm.NTP_SERVER2
					#Only For MEDIASENSE
					if($vm.VM_TYPE -match "MEDIASENSE_PRIMARY")
					{
						CreatePlatformChildNode $writer "ORANodeType" "ORA node type of this server" "unknown" "Primary"
					}
				}
				
				switch -wildcard ($vm.VM_TYPE)
				{
				"UNITY*" {
                            if ($vm.SERVERNUM -match "01") {
                                CreatePlatformChildNode $writer "PostInstallAutoRegister" "Number of Hours to Enable Auto Register Post-Install on Pub" "24" "24"
                            }
                         }
				"CUCM*"  {
                            if ($vm.SERVERNUM -match "01") {
                                CreatePlatformChildNode $writer "PostInstallAutoRegister" "Number of Hours to Enable Auto Register Post-Install on Pub" "24" "24"}
                            }
                            
                "EXPRESS*" {CreatePlatformChildNode $writer "CCXDeploymentType" "CCX deployment type of this server" "none" "CCM"}
				}
				
				#ApplUserUsername different for VVB
				if($vm.VM_TYPE -match "VVB")
				{
					CreatePlatformChildNode $writer "ApplUserUsername" "Application User Username" "VBAdministrator" $vm.AppAdminUserName
				}
				else
				{
					CreatePlatformChildNode $writer "ApplUserUsername" "Application User Username" "CCMAdministrator" $vm.AppAdminUserName
					
				}
				
				CreatePlatformChildNode $writer "ApplUserPwCrypt" "Application User Password" "password" $vm.AppAdminPW
				
			    #License Mac for Different VM except CUCM & ORA only for MEDIASENSE
				switch -wildcard ($vm.VM_TYPE)
				{
				"CUIC*" {CreatePlatformChildNode $writer "LicenseMAC" "License MAC used for VM provisioning/installing only.  This value is NOT kept in sync with post install changes." "none" "none"}
				"LiveData*" {CreatePlatformChildNode $writer "LicenseMAC" "License MAC used for VM provisioning/installing only.  This value is NOT kept in sync with post install changes." "none" "none"}
				"FINESSE*" {CreatePlatformChildNode $writer "LicenseMAC" "License MAC used for VM provisioning/installing only.  This value is NOT kept in sync with post install changes." "none" "none"}
				"VVB*" {CreatePlatformChildNode $writer "LicenseMAC" "License MAC used for VM provisioning/installing only.  This value is NOT kept in sync with post install changes." "none" "20263e3cf9cf"}
				"MEDIASENSE*" {WriteORAClusterNodes $writer "ORAClusterNodes" "ORANode" $vm.IP_ADDRESS_NIC1 "Primary"}
                "EXPRESS*" {CreatePlatformChildNode $writer "LicenseMAC" "License MAC used for VM provisioning/installing only.  This value is NOT kept in sync with post install changes." "none" "1f943281ea67"}
				"Cloud_Connect*" {CreatePlatformChildNode $writer "LicenseMAC" "License MAC used for VM provisioning/installing only.  This value is NOT kept in sync with post install changes." "none" "none"}
				}
				
				#Difference for Unity
				switch -wildcard ($vm.VM_TYPE)
				{
				"UNITY*" {CreatePlatformChildNode $writer "DRSMasterHost" "DRSMasterHost" "localhost" $vm.COMPUTER_NAME}
				}
				
				#</PlatformData> 
				$writer.WriteEndElement()

				$writer.Flush() 
				$writer.Close()

				Log-Message -Type "INFO" -Message "Created PlatformConfigXML $filename for $($vm.NEW_VM_NAME)"
		        winImageProcessing $TimeStamp $DirName
        	} #End of #if check(product)###
		
		} #End of if(create and customization) check####
		
	} #End of foreach loop#

}
####################################################-END Of Function-CreatePlatformConfigXMLforVOS###########################################################################