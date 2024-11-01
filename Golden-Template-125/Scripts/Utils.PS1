
$ERROR_ID_1 = "Value provided for New VM Name does not meet the specified criteria"
$ERROR_ID_2 = "Invalid value provided for source host IP"
$ERROR_ID_3 = "Invalid value provided for source datastore Name"
$ERROR_ID_4 = "Invalid value provided for Golden Template Name"
$ERROR_ID_5 = "Invalid value provided for destination Host IP"
$ERROR_ID_6 = "Invalid value provided for destination datastore Name"
$ERROR_ID_7 = "Value provided for Computer Name does not meet the specified criteria"
$ERROR_ID_8 = "Value provided for Work Group Name does not meet the specified criteria"
$ERROR_ID_9 = "Value provided for Domain Name does not meet the specified criteria"
$ERROR_ID_10 = "Value provided for DNS suffix does not meet the specified criteria"
$ERROR_ID_11 = "Invalid value provided for Time Zone Linux Area"
$ERROR_ID_12 = "Invalid value provided for Time Zone Linux Location"
$ERROR_ID_13 = "Invalid value provided for Time Zone Windows"
$ERROR_ID_14 = "Value provided for Domain User Name does not meet the specified criteria"
$ERROR_ID_15 = "Value provided for Domain password does not meet the specified criteria"
$ERROR_ID_16 = "Value provided for Organization Name does not meet the specified criteria"
$ERROR_ID_17= "Value provided for Owner Name does not meet the specified criteria"
$ERROR_ID_18= "Invalid value provided for Num NICs"
$ERROR_ID_19= "IP Address provided does not meet the specified criteria"
$ERROR_ID_20= "Subnet mask provided does not meet the specified criteria"
$ERROR_ID_21= "Default Gateway provided does not meet the specified criteria"
$ERROR_ID_22= "DNS Server provided does not meet the specified criteria"
$ERROR_ID_23= "NIC Information Mismatch"
$ERROR_ID_24= "Product key provided does not meet the specified criteria"
$ERROR_ID_25= "No Value provided for `"New VM Name`" field"
$ERROR_ID_26= "No value provided for `"Source Host IP`" field"
$ERROR_ID_27= "No value provided for `"Source Datastore Name`" field"
$ERROR_ID_28= "No value provided for `"Golden Template Name`""
$ERROR_ID_29= "No value provided for `"Destination Host IP`""
$ERROR_ID_30= "No value provided for `"Destination Datastore Name`""
$ERROR_ID_31= "No value provided for  `"Computer Name`" field"
$ERROR_ID_32= "No value provided for `"Work Group Name`" field"
$ERROR_ID_33= "No value provided for `"Domain Name`" field"
$ERROR_ID_34= "No value provided for `"DNS suffix`" "
$ERROR_ID_35= "No value provided for `"Time Zone Linux Area`" field"
$ERROR_ID_36= "No value provided for `"Time Zone Linux Location`" field"
$ERROR_ID_37= "No value provided for `"Time Zone Windows`""
$ERROR_ID_38="No Value provided for `"Domain User Name`" field"
$ERROR_ID_39="No value provided for `"Domain password`" field"
$ERROR_ID_40="No value provided for `"Organization Name`" field"
$ERROR_ID_41="No Value provided for `"Owner Name`" filed"
$ERROR_ID_42="No value provided for Num NICs"
$ERROR_ID_43="No value is provided for `"IP Address`" field"
$ERROR_ID_44="No Value is provided for `"Subnet mask`" field"
$ERROR_ID_45="No Value is provided for `"Default Gateway`" field"
$ERROR_ID_46="No Value is provided for `"DNS Server`" field"
$ERROR_ID_47="No Value is provided in `"Product key`" field"
$ERROR_ID_48="WorkGroup is Selected but Work Group Name is not provided"
$ERROR_ID_49="Domain is selected but Domain Name is not provided"
$ERROR_ID_50="Domain is selected but Domain User Name is not provided"
$ERROR_ID_51="Domain is selected but Domain Password is not provided"
$ERROR_ID_52="No Value provided for Work Group option"
$ERROR_ID_53="Value provided for Template Name does not meet the specified criteria"
$ERROR_ID_54="No Value is provided for `"Time Zone Windows`" field"
$ERROR_ID_55="Value provided for `"Time Zone Windows`" field does not meet the specified criteria"
$ERROR_ID_56="No Value provided for Area field for Linux Time Zone"
$ERROR_ID_57="No Value provided for Location field for Linux Time Zone"
$ERROR_ID_58="Domain name is not provided for Linux machine"
$ERROR_ID_59="No value provided for `"Organization Unit`" field"
$ERROR_ID_60="No value provided for `"Organization Location`" field"
$ERROR_ID_61="No value provided for `"Organization State`" field"
$ERROR_ID_62="No value provided for `"Organization Country`" field"
#PCCE
$ERROR_ID_63="OVF Tool not installed on system"
$OVFToolPath = ("C:\Program Files (x86)\VMware\VMware OVF Tool\ovftool.exe","C:\Program Files\VMware\VMware OVF Tool\ovftool.exe")

$OVFTool = ''

#####################################################################################################
#
#
#
#
#####################################################################################################
Function LOG($TYPE, $MSG_String)
{    
    $a = Get-Date
    $Date_Time = "" + $a.Day  + "/" + $a.Month + "/" + $a.Year + " " + $a.Hour + ":" + $a.Minute + ":" + $a.Second + ":" + $a.Millisecond
    if($TYPE -eq "ERROR") 
    {
        Write-Host "`r"
		Write-Host $Date_Time $TYPE : $MSG_String -foregroundcolor Red
    }
    elseif($TYPE -eq "INFO") 
    {	
        Write-Host "`r"
		Write-Host $Date_Time $TYPE : $MSG_String
    }
    elseif($TYPE -eq "DEBUG")
	{
	    if($LogLevel -eq "DEBUG")
		{
		    Write-Host "`r"
			Write-Host $Date_Time $TYPE : $MSG_String	
		}
	}
	
}
#####################################################################################################
#
#
#
#
#####################################################################################################

Function ValidateVMHostData($HostName, $type, [REF]$Success, [REF]$ErrorMsg) { 


    if($HostName) {
        $FieldName = ""
        if($type -eq "source") {
            $FieldName = "SOURCE_HOST_IP"
            $Success.Value = $true
		} elseif($type -eq "destination") {
			$FieldName = "DEST_HOST_IP"
            $Success.Value = $true
		}

    } else {
        if($type -eq "source") {
            Log-Message -Type "ERROR" -Message "$ERROR_ID_26"
            $Success.Value = $false
            $ErrorMsg.Value = $ERROR_ID_26
        } elseif($type -eq "destination") {
            Log-Message -Type "ERROR" -Message "$ERROR_ID_29"
            $Success.Value = $false
            $ErrorMsg.Value = $ERROR_ID_29
        }
    }

}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function validate_DNS_Names ($hostAddress)
{
   $ipAddress=$hostAddress
   $ipTest=$null

   # Try to parse it to see if it is valid ip address
  if (![system.net.IPAddress]::tryparse($hostAddress,[ref]$ipTest))
  {
  	  # Looks like it may be a hostname; so will try to look it up using DNS
      try
      {
          $DNS=[System.Net.Dns]::GetHostEntry($hostAddress)
          $ipAddress=$DNS.AddressList
          if ($ipAddress -ne [DBNull]::Value)
          {
          	# was able to find an ip address, so it is a valid host name
          	return $true
          }

     }
     catch
     {
         return $false
     }
  }
  else {
  	  # as long as the parse is successful, it is a valid ip address
      return $true
  }

  return $false

}
#####################################################################################################
#
#
#
#
#####################################################################################################

Function Validate_Template_Data($TemplateName , [REF]$Success, [REF]$ErrorMsg)
{
   if($TemplateName)
   {
       if($TemplateName.Length -le 32) 
		{	
			if($TemplateName.contains(" "))
			{
				Log-Message -Type "DEBUG" -Message "Template Name $TemplateName has a space or Tab"
				Log-Message -Type "ERROR" -Message "Template Name $TemplateName does not meet the specified criteria"
				$Success.Value = $false
				$ErrorMsg.Value = "Template Name " + $TemplateName + " does not meet the specified criteria"
			}			
			else
			{
				Log-Message -Type "DEBUG" -Message "Template Name $TemplateName is of correct format"
				$Success.Value = $true
				$ErrorMsg.Value = "Template Name" + $TemplateName + " is of correct format"
			}
		}
		else
		{
			Log-Message -Type "ERROR" -Message "$ERROR_ID_53"
			$Success.Value = $false
	        $ErrorMsg.Value = $ERROR_ID_53
		}
   }
   else
   {
        Log-Message -Type "ERROR" -Message "$ERROR_ID_28"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_28
   }
}
#####################################################################################################
#
#
#
#
#####################################################################################################

Function Validate_VirtualMachine_Name($VMName , [REF]$Success, [REF]$ErrorMsg)
{
   if($VMName)
   {
       if($VMName.Length -le 32) 
		{	
			if($VMName.contains(" "))
			{
				Log-Message -Type "DEBUG" -Message "New VM Name $VMName has a space or Tab"
				Log-Message -Type "ERROR" -Message "New VM Name $VMName does not meet the specified criteria"
				$Success.Value = $false
				$ErrorMsg.Value = "New VM Name " + $VMName + " does not meet the specified criteria"
			}			
			else
			{
				Log-Message -Type "DEBUG" -Message "New VM Name $VMName is of correct format"
				$Success.Value = $true
				$ErrorMsg.Value = "New VM Name" + $VMName + " is of correct format"
			}
		}
		else
		{
			Log-Message -Type "ERROR" -Message "$ERROR_ID_1"
			$Success.Value = $false
	        $ErrorMsg.Value = $ERROR_ID_1
		}
   }
   else
   {
        Log-Message -Type "ERROR" -Message "$ERROR_ID_25"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_25
   }
}
#####################################################################################################
#
#This function is to veryfy the deployed VMs
#
#
#####################################################################################################
Function Post_VM_Validation($VMName, $DestHostName, $DestDatastoreName, $VCenter, [REF]$Success, [REF]$ErrorMsg)
{
	
	Log-Message -Type "DEBUG" -Message "Virtual Machine $VMName Exists"
	$Success.Value = $true	
	
    #$Folder_Found = 0
    #if($VMName) {
       #$FileName = $VMName + ".vmdk"       
	   #$DestHost = Get-VMHost -Name $DestHostName -Server $VCenter
	   
	   # if($DestHost)
	   # {	   
		   # $DataStoreObj = Get-Datastore -VMHost $DestHost -Name $DestDatastoreName
		   # if($DataStoreObj)
		   # {
			   # $DSView = $DataStoreObj | Get-View
			   # $dsBrowser = Get-View $DSView.browser
			   # $rootPath = "["+$DSView.summary.Name+"]"
			   # LOG $DEBUG ("rootpath is "+ $rootPath )

			   # $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
			   # $fileQueryFlags.FileSize = $true
			   # $fileQueryFlags.FileType = $true
			   # $fileQueryFlags.Modification = $true
				   
			   # $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
			   # $searchSpec.details = $fileQueryFlags
			   # $searchSpec.sortFoldersFirst = $true
				   
			   # $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)   
				   
			   # foreach ($result in $searchResult)
			   # {
				   # foreach($folder in ($result.File |?{$_.Path -like  $FileName } | Sort Path))
				   # {
					   # $Folder_Found = 1					   
					   # break
				   # }
				   
				   # if($Folder_Found -eq 1)
				   # {
				       # break					   
				   # }
			   # }
			   
				# if($Folder_Found -ne 1)
				# {
				   # LOG "ERROR" ( "The newly deployed VM " + $VMName + " is not in good shape")
				   # $Success.Value = $false
				   # $ErrorMsg.Value = "The newly deployed VM is not in good shape"
				# }
				# else
				# {
					# LOG $DEBUG ("Virtual Machine " + $VMName + " Exists")
					# $Success.Value = $true			
				# }
			# }
			# else
			# {
				# LOG "ERROR" ("The specified destination datastore does not exist. Could not verify whether virtual machine " + $VMName + " exists")
				# $Success.Value = $false
				# $ErrorMsg.Value = "The specified destination datastore does not exist.Could not verify whether virtual machine " + $VMName + " exists"			
			# }
		# }
		# else
		# {
			# LOG "ERROR" ("The specified destination host does not exist. Could not verify whether virtual machine " + $VMName + " exists")
			# $Success.Value = $false
			# $ErrorMsg.Value = "The specified destination host does not exist.Could not verify whether virtual machine " + $VMName + " exists"		
		# }
	# }
	# else
	# {
		# LOG "ERROR" ($ERROR_ID_25)
		# $Success.Value = $false
		# $ErrorMsg.Value = $ERROR_ID_25
	# }

}

##############################################################################################################################################

Function Does_VirtualMachine_Exist($VirtualMachineName, $VMDestHostName, $DataCenter, $VCenter, [REF]$Success, [REF]$ErrorMsg, $PostDeployCheck)
{	
	if($VirtualMachineName)
	{
        
		$Success.Value = $true
		$Result = $false
	
		$VMArray = @()
		
		$VMDestHost = Get-VMHost -Name $VMDestHostName -Server $VCenter
				
		if($VMDestHost)
		{
            
			#$DataCenter = Get-Datacenter -VMHost $VMDestHost
			#Log "DEBUG" ("The destination VMHost " + $VMDestHostName + " is located in datacenter : " + $DataCenter.Name)
			
			$VMArray = Get-VM -Location $DataCenter -Name * -Server $VCenter
						
			foreach($VMEntry in $VMArray )
			{
                
				if($VMEntry -like $VirtualMachineName)
				{
                    
					$Result = $true
					break
				}
			}		
			
			if($Result -eq $true)
			{			
				$Success.Value = $true
				
				
				if($PostDeployCheck -eq $false)
				{
                    
					Log-Message -Type "INFO" -Message "Specified Virtual Machine $VirtualMachineName Already Exists."
					$ErrorMsg.Value = "Specified " + " Virtual Machine "+ $VirtualMachineName + " Already Exists."			
				}
				elseif($PostDeployCheck -eq $true)
				{
					Log-Message -Type "INFO" -Message "The newly deployed virtual machine $VirtualMachineName exists"					
					$ErrorMsg.Value = "The newly deployed virtual machine exists."			
				}
			}
			else
			{
						
				$Success.Value = $false
							
				if($PostDeployCheck -eq $false)
				{
					Log-Message -Type "DEBUG" -Message "Specified Virtual Machine $VirtualMachineName Does not exist"
					$ErrorMsg.Value = "Specified " + " Virtual Machine "+ $VirtualMachineName + " Does not exist"
				}
				elseif($PostDeployCheck -eq $true)
				{
					Log-Message -Type "ERROR" -Message "The virtual machine $VirtualMachineName does not exist"
					$ErrorMsg.Value = "The virtual machine does not exist."			
				}
			}
		}
		else
		{
			Log-Message -Type "ERROR" -Message "The specified destination host does not exist. Could not verify whether virtual machine $VirtualMachineName exists"
			$ErrorMsg.Value = "The specified destination host does not exist.Could not verify whether virtual machine " + $VirtualMachineName + " exists"		
			
			if($PostDeployCheck -eq $false)
			{
				$Success.Value = $true # For pre-deployment check we set it to true so that it gets negated...				
			}
			elseif($PostDeployCheck -eq $true)
			{
				$Success.Value = $false	# For pre-deployment check we set it to false...	
			}
		}
	}

}
#################################################################################################################################

Function Does_Host_Exist($HostName, $type, $VCenter, [REF]$Success, [REF]$ErrorMsg)
{
	if($HostName)
	{	
		if($VMHostValidationCache.contains($HostName))
		{
			if($VMHostValidationCache[$HostName] -eq $true)
			{	
				Log-Message -Type "DEBUG" -Message "Specified $type Host IP $HostName Exists"
				$Success.Value = $true
				$ErrorMsg.Value = "Success"		
			}
		}
		else
		{
			$IsVM_Host = Get-VMHost -Name $HostName -Server $VCenter
			if(!$IsVM_Host)
			{
				if($type -eq "source" )
				{
					Log-Message -Type "ERROR" -Message "$ERROR_ID_2"
					$Success.Value = $false
					$ErrorMsg = $ERROR_ID_2
				}
				elseif($type -eq "destination")
				{
					Log-Message -Type "ERROR" -Message "$ERROR_ID_5"
					$Success.Value = $false
					$ErrorMsg.Value = $ERROR_ID_5
				}
				
			}
			else
			{
				$VMHostValidationCache[$HostName] = $true
				Log-Message -Type "DEBUG" -Message "Specified $type Host IP $HostName Exists"
				$Success.Value = $true
				$ErrorMsg.Value = "Success"				
			}
		}
	}

}
#####################################################################################################
# Does_Template_Exist_Optimized : Validates whether the source host, source datastore and the template exist
#####################################################################################################

Function Does_Template_Exist_Optimized($TemplateName , $DataCenterName, $VCenter, [REF]$Success, [REF]$ErrorMsg)
{
    Log-Message -Type "INFO" -Message "Template = $TemplateName, DataCenter = $DataCenterName, vCenter = $VCenter"
	if($TemplateName -and $DataCenterName -and $VCenter)
    {
       
	   $TemplateValidationCacheLookUpStr = $VCenter + "/" + $DataCenterName + "/" + $TemplateName
       
	   if($TemplateValidationCache.contains($TemplateValidationCacheLookUpStr))
	   {
            Log-Message -Type "INFO" -Message "Does_Template_Exist_Optimized: Looking at the cache"
			if($TemplateValidationCache[$TemplateValidationCacheLookUpStr] -eq $true)
			{				
				Log-Message -Type "DEBUG" -Message "The specified template $TemplateName exists"
				$Success.Value = $true
				$ErrorMsg.Value = "The specified template " + $TemplateName + " exists"
			}
	   }
	   else
	   {
           Log-Message -Type "INFO" -Message "Does_Template_Exist_Optimized: Looking at the DataCenter"
		   $TemplateExist = Get-Template -Name $TemplateName -Location $DataCenterName -Server $VCenter
		   if ($TemplateExist) {
				$TemplateValidationCache[$TemplateValidationCacheLookUpStr] = $true
				Log-Message -Type "DEBUG" -Message "The specified template $TemplateName exists"
				$Success.Value = $true
				$ErrorMsg.Value = "The specified template " + $TemplateName + " exists"
			
			} else {
		   
				Log-Message -Type "ERROR" -Message "The specified template $TemplateName does not exist"
				$Success.Value = $false
				$ErrorMsg.Value = "The specified template " + $TemplateName + " does not exist"
		   
		   }
		   
		}
		
	} else {
	
		Log-Message -Type "ERROR" -Message "Errors were found with either the template name or the data center name"
		$Success.Value = $false
		$ErrorMsg.Value = "Errors were found with either the template name or the data center name"
	}

}
############################################################################################################################

Function Validate_DataStore_Data($DataStoreName , $type , [REF]$Success, [REF]$ErrorMsg)
{
    if($DataStoreName)
    {	
		$Success.Value = $true
		
		if($type -eq "source")
		{
			$ErrorMsg.Value = "The source datastore name is provided"
			Log-Message -Type "DEBUG" -Message "The source datastore name is provided"
		}
		else
		{
			$ErrorMsg.Value = "The destination datastore name is provided"
			Log-Message -Type "DEBUG" -Message "The destination datastore name is provided"
		}
		
    }
	else
	{
		if($type -eq "source")
			{
				Log-Message -Type "ERROR" -Message "$ERROR_ID_27"
				$Success.Value = $false
				$ErrorMsg.Value = $ERROR_ID_27
			}
		elseif($type -eq "destination")
			{
				Log-Message -Type "ERROR" -Message "$ERROR_ID_30"
				$Success.Value = $false
				$ErrorMsg.Value = $ERROR_ID_30			
			}
    }
}

Function Does_DestHost_And_DestDataStore_Exist($DataStoreName, $HostName, $VCenter, [REF]$Success, [REF]$ErrorMsg)
{
    if($DataStoreName -and $HostName)
    {
		$DataStoreLookUpStr = $HostName + "/" + $DataStoreName
		
		if($DatastoreValidationCache.contains($DataStoreLookUpStr))
		{
			if($DatastoreValidationCache[$DataStoreLookUpStr] -eq $true)
			{				
				$Success.Value = $true
				$ErrorMsg.Value = "The specified destination datastore" + $DataStoreName + " Exists"
				Log-Message -Type "DEBUG" -Message "The specified destination datastore $DataStoreName exists"
			}
		}
		else
		{
			$VMHost = Get-VMHost -Name $HostName -Server $VCenter
			
			if($VMHost)
			{
				$IsDataStore = Get-Datastore -VMHost $VMHost -Name $DataStoreName -Server $VCenter
				
				if($IsDataStore)
				{
					$DatastoreValidationCache[$DataStoreLookUpStr] = $true
					$Success.Value = $true
					$ErrorMsg.Value = "The specified destination datastore" + $DataStoreName + " exists"
					Log-Message -Type "DEBUG" -Message "The specified destination datastore $DataStoreName exists"
				}
				else
				{	
					Log-Message -Type "ERROR" -Message "$ERROR_ID_6"
					Log-Message -Type "ERROR" -Message "The specified destination datastore $DataStoreName does not exist"
					$Success.Value = $false
					$ErrorMsg.Value = "The specified destination datastore" + $DataStoreName + " does not exist"
				}
			}
			else
			{
				Log-Message -Type "ERROR" -Message "$ERROR_ID_5"
				Log-Message -Type "ERROR" -Message "The specified destination host does not exist. Could not verify whether destination datastore $DataStoreName exists"
				$Success.Value = $false
				$ErrorMsg.Value = "The specified destination host does not exist.Could not verify whether destination datastore " + $DataStoreName + " exists"
			}
		}
    }
}
#####################################################################################################
#
#
#####################################################################################################

Function Does_DataStore_Exist($DataStoreName ,$HostName , $type , [REF]$Success, [REF]$ErrorMsg)
{
     
    if($DataStoreName)
    {
		$DataStoreLookUpStr = $HostName + "/" + $DataStoreName
		
		if($DatastoreValidationCache.contains($DataStoreLookUpStr))
		{
			if($DatastoreValidationCache[$DataStoreLookUpStr] -eq $true)
			{				
				$Success.Value = $true
				$ErrorMsg.Value = "The specified " + $type + " datastore" + $DataStoreName + " Exists"
				LOG "DEBUG" ("The specified " + $type + " datastore" + $DataStoreName + " Exists")								
			}
		}
		else
		{
			$VMHost = Get-VMHost -Name $HostName -Server $vCenterIP
			
			if($VMHost)
			{
				$IsDataStore = Get-Datastore -VMHost $VMHost -Name $DataStoreName
				
				if(!$IsDataStore)
				{			
					if($type -eq "source")
					{
						Write-Host "`r"
						LOG "ERROR" ($ERROR_ID_3)
						$Success.Value = $false
						$ErrorMsg.Value = $ERROR_ID_3
					}
					elseif($type -eq "destination")
					{
						Write-Host "`r"
						LOG "ERROR" ($ERROR_ID_6)
						$Success.Value = $false
						$ErrorMsg.Value = $ERROR_ID_6
					}
				}
				else
				{
					$DatastoreValidationCache[$DataStoreLookUpStr] = $true
					$Success.Value = $true
					$ErrorMsg.Value = "The specified " + $type + " datastore" + $DataStoreName + " Exists"
					LOG "DEBUG" ("The specified " + $type + " datastore" + $DataStoreName + " Exists")
				}
			}
			else
			{
				LOG "ERROR" ("The specified " + $type + " host does not exist. Could not verify whether datastore " + $DataStoreName + " exists")
				$Success.Value = $false
				$ErrorMsg.Value = "The specified " + $type + " host does not exist.Could not verify whether datastore " + $DataStoreName + " exists"
			}
		}
    }
	else
	{
		if($type -eq "source")
		{
            LOG "INFO" (Second error Source)
			LOG "ERROR" ($ERROR_ID_27) 
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_27
		}
		elseif($type -eq "destination")
		{
			LOG "ERROR" ($ERROR_ID_30)
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_30			
		}
    }
}
#####################################################################################################
#
#This function validates the IP address fromat using API and returns true/false
#
#
#####################################################################################################
function Validate_IPAddress ( $ip_add )
{
	$ret = $false

   if ($IP -match "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}$")
   {
       #write-host IP address  $IP is of correct format
	   $ret = [bool][system.net.ipaddress]::Parse($ip_add);
   }
   
   return $ret
}
#####################################################################################################
#
#This function validates DNS IP Address For Linux
#
#
#####################################################################################################

Function Check_DNS_IP_Address_For_Linux($IP,[REF]$Success, [REF]$ErrorMsg)
{

$Success.Value = $true
$ErrorMsg.Value = "Success"	

	if ($IP)
	{
		$result = Validate_IPAddress  $IP ;
		
		if ($result)
		{
			Log-Message -Type "DEBUG" -Message "IP address $IP is of correct format"
			$Success.Value = $true
			$ErrorMsg.Value = "IP address " + $IP + " is of correct format"			
		}
		else
		{
			Log-Message -Type "ERROR" -Message "IP address $IP is of incorrect format"
			$Success.Value = $false
			$ErrorMsg.Value = "IP address " + $IP + " is of incorrect format"			
		}
	}
	# else ### Making DNS IP address optional for Linux.
	# {
		# Log-Message -Type "ERROR" -Message "$ERROR_ID_43"
		# $Success.Value = $false
		# $ErrorMsg.Value = $ERROR_ID_43
	# }

}
###########################################################################################################
# Validation of Domain Information
###########################################################################################################
Function Check_DNS_Domain($DOMAIN_NAME,[REF]$Success,[REF]$ErrorMsg)
{

    $Success.Value = $true
	$ErrorMsg.Value = "Success"
    
    if($vm.DOMAIN_NAME -and $vm.DNS_IP_NIC1)
    {
            Log-Message -Type "DEBUG" -Message "Both DNS and Domain data are available for $($vm.VM_TYPE)"
			$Success.Value = $true
			$ErrorMsg.Value = "Both DNS and Domain data are available for " + $vm.VM_TYPE
    }
    
    else
    {       
            $Success.Value = $false
            Log-Message -Type "ERROR" -Message "Both DNS and Domain data are mandatory for $($vm.VM_TYPE)"
    }        
    
}


#####################################################################################################
#This function validates the IP address format
#####################################################################################################

Function Check_IP_Address_Format($FieldName, $IP,[REF]$Success, [REF]$ErrorMsg)
{
	if ($IP)
	{
		$result = Validate_IPAddress  $IP ;
		
		if ($result)
		{
			Log-Message -Type "DEBUG" -Message "$FieldName $IP is of correct format"
			$Success.Value = $true
			$ErrorMsg.Value = $FieldName + " "  + $IP + " is of correct format"			
		}
		else
		{
			Log-Message -Type "ERROR" -Message "$FieldName $IP is of incorrect format"
			$Success.Value = $false
			$ErrorMsg.Value = $FieldName + " " + $IP + " is of incorrect format"			
		}
	}
	else
	{
		Log-Message -Type "ERROR" -Message "No value is provided for $FieldName field"
		$Success.Value = $false
		$ErrorMsg.Value = "No value is provided for "+ $FieldName + " field"
	}

}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Validate_Linux_Time_Zone ($Area, $Location,[REF]$Success, [REF]$ErrorMsg)
{
	
	if($Area -and $Location)
    {
        Log-Message -Type "DEBUG" -Message "Area and location for Linux Time Zone are provided"
		$Success.Value = $true
		$ErrorMsg.Value = "Area and location for Linux Time Zone are provided"

		$vm.TIME_ZONE_LINUX = Create_Linux_Time_Zone $vm.TIME_ZONE_LINUX_AREA $vm.TIME_ZONE_LINUX_LOCATION
    }
	else
	{			
		if(!$Area)
		{
			Log-Message -Type "ERROR" -Message "$ERROR_ID_56"
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_56
		}
		if(!$Location)
		{
			Log-Message -Type "ERROR" -Message "$ERROR_ID_57"
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_57
		}
	
	}
	

}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Create_Linux_Time_Zone ($Area, $Location)
{
    return ($Area + "/" + $Location)
}

#####################################################################################################
#
#This function retuns the time zone code based on the time zone passed only for windows customization
#
#
#####################################################################################################
Function Get_Windows_Time_Zone($TimeZone)
{
    $TimeZoneCode = 0
    switch ($TimeZone)
    {
        "(GMT-12:00) International Date Line West"                          {$TimeZoneCode = 000}
        
        "(GMT-11:00) Midway Island, Samoa"                                  {$TimeZoneCode = 001}
       
        "(GMT-10:00) Hawaii"                                                {$TimeZoneCode = 002}

        "(GMT-09:00) Alaska"                                                {$TimeZoneCode = 003}

        "(GMT-08:00) Tijuana, Baja California"                              {$TimeZoneCode = 004}

        "(GMT-08:00) Pacific Time (US & Canada)"                            {$TimeZoneCode = 004}

        "(GMT-07:00) Mountain Time (US & Canada)"                           {$TimeZoneCode = 010}
		
		"America/Denver"							                        {$TimeZoneCode = 010}
		
		"Etc/UTC"									                        {$TimeZoneCode = 085}
        
        #"(GMT-07:00) Chihuahua, La Paz, Mazatlan - Old"                     {$TimeZoneCode = 013}
        
        #"(GMT-07:00) Chihuahua, La Paz, Mazatlan - New"                     {$TimeZoneCode = 013}
        
        "(GMT-07:00) Arizona"                                               {$TimeZoneCode = 015}
        
        "(GMT-06:00) Saskatchewan"                                          {$TimeZoneCode = 025}
        
        "(GMT-06:00) Guadalajara, Mexico City, Monterrey - Old"             {$TimeZoneCode = 030}
        
        "(GMT-06:00) Guadalajara, Mexico City, Monterrey - New"             {$TimeZoneCode = 030}
        
        "(GMT-06:00) Central Time (US & Canada)"                            {$TimeZoneCode = 020}
        
        "(GMT-06:00) Central America"                                       {$TimeZoneCode = 033}
        
        "(GMT-05:00) Indiana (East)"                                        {$TimeZoneCode = 040}
        
        "(GMT-05:00) Eastern Time (US & Canada)"                            {$TimeZoneCode = 035}
        
        "(GMT-05:00) Bogota, Lima, Quito, Rio Branco"                       {$TimeZoneCode = 045}
        
        "(GMT-04:30) Caracas"                                               {$TimeZoneCode = 170}
        
        "(GMT-04:00) Santiago"                                              {$TimeZoneCode = 056}
        
        "(GMT-04:00) Manaus"                                                {$TimeZoneCode = 055}
        
        "(GMT-04:00) La Paz"                                                {$TimeZoneCode = 055}
        
        "(GMT-04:00) Atlantic Time (Canada)"                                {$TimeZoneCode = 050}
       
        "(GMT-03:30) Newfoundland"                                          {$TimeZoneCode = 060}
       
        "(GMT-03:00) Montevideo"                                            {$TimeZoneCode = 073}
       
        "(GMT-03:00) Greenland"                                             {$TimeZoneCode = 073}
       
        "(GMT-03:00) Georgetown"                                            {$TimeZoneCode = 070}
       
        "(GMT-03:00) Buenos Aires"                                          {$TimeZoneCode = 070}
       
        "(GMT-03:00) Brasilia"                                              {$TimeZoneCode = 065}
       
        "(GMT-02:00) Mid-Atlantic"                                          {$TimeZoneCode = 075}
       
        "(GMT-01:00) Cape Verde Is."                                        {$TimeZoneCode = 083}
       
        "(GMT-01:00) Azores"                                                {$TimeZoneCode = 080}
       
        "(GMT) Casablanca"                                                  {$TimeZoneCode = 090}
       
        "(GMT) Greenwich Mean Time : Dublin, Edinburgh, Lisbon, London"     {$TimeZoneCode = 085}
       
        "(GMT) Monrovia, Reykjavik"                                         {$TimeZoneCode = 090}
        
        "(GMT+01:00) Amsterdam, Berlin, Bern, Rome, Stockholm, Vienna"      {$TimeZoneCode = 110}
        
        "(GMT+01:00) Belgrade, Bratislava, Budapest, Ljubljana, Prague"     {$TimeZoneCode = 095}
        
        "(GMT+01:00) Brussels, Copenhagen, Madrid, Paris"                   {$TimeZoneCode = 105}
        
        "(GMT+01:00) Sarajevo, Skopje, Warsaw, Zagreb"                      {$TimeZoneCode = 100}
        
        "(GMT+01:00) West Central Africa"                                   {$TimeZoneCode = 113}
         
        "(GMT+02:00) Amman"                                                 {$TimeZoneCode = 130}
       
        "(GMT+02:00) Athens, Bucharest, Istanbul"                           {$TimeZoneCode = 130}
       
        "(GMT+02:00) Beirut"                                                {$TimeZoneCode = 130}
       
        "(GMT+02:00) Cairo"                                                 {$TimeZoneCode = 120}
       
        "(GMT+02:00) Harare, Pretoria"                                      {$TimeZoneCode = 140}
       
        "(GMT+02:00) Helsinki, Kyiv, Riga, Sofia, Tallinn, Vilnius"         {$TimeZoneCode = 125}
       
        "(GMT+02:00) Jerusalem"                                             {$TimeZoneCode = 135}
       
        "(GMT+02:00) Minsk"                                                 {$TimeZoneCode = 130}
       
        "(GMT+02:00) Windhoek"                                              {$TimeZoneCode = 130}
       
        "(GMT+03:00) Baghdad"                                               {$TimeZoneCode = 158}
       
        "(GMT+03:00) Kuwait, Riyadh"                                        {$TimeZoneCode = 150}
       
        "(GMT+03:00) Moscow, St. Petersburg, Volgograd"                     {$TimeZoneCode = 145}
       
        "(GMT+03:00) Nairobi"                                               {$TimeZoneCode = 155}
       
        "(GMT+03:00) Tbilisi"                                               {$TimeZoneCode = 155}
       
        "(GMT+03:30) Tehran"                                                {$TimeZoneCode = 160}
       
        "(GMT+04:00) Abu Dhabi, Muscat"                                     {$TimeZoneCode = 165}
       
        "(GMT+04:00) Baku"                                                  {$TimeZoneCode = 170}
       
        "(GMT+04:00) Caucasus Standard Time"                                {$TimeZoneCode = 170}
       
        "(GMT+04:00) Port Louis"                                            {$TimeZoneCode = 170}
       
        "(GMT+04:00) Yerevan"                                               {$TimeZoneCode = 170}
       
        "(GMT+04:30) Kabul"                                                 {$TimeZoneCode = 175}
       
        "(GMT+05:00) Ekaterinburg"                                          {$TimeZoneCode = 180}
       
        "(GMT+05:00) Islamabad, Karachi"                                    {$TimeZoneCode = 180}
       
        "(GMT+05:00) Tashkent"                                              {$TimeZoneCode = 180}
       
        "(GMT+05:30) Chennai, Kolkata, Mumbai, New Delhi"                   {$TimeZoneCode = 190}
       
        "(GMT+05:30) Sri Jayawardenepura"                                   {$TimeZoneCode = 190}
       
        "(GMT+05:45) Kathmandu"                                             {$TimeZoneCode = 193}
       
        "(GMT+06:00) Almaty, Novosibirsk"                                   {$TimeZoneCode = 201}
       
        "(GMT+06:00) Astana, Dhaka"                                         {$TimeZoneCode = 195}
        
        "(GMT+06:30) Yangon (Rangoon)"                                      {$TimeZoneCode = 203}
        
        "(GMT+07:00) Bangkok, Hanoi, Jakarta"                               {$TimeZoneCode = 205}
        
        "(GMT+07:00) Krasnoyarsk"                                           {$TimeZoneCode = 207}
      
        "(GMT+08:00) Beijing, Chongqing, Hong Kong, Urumqi"                 {$TimeZoneCode = 210}
      
        "(GMT+08:00) Irkutsk, Ulaan Bataar"                                 {$TimeZoneCode = 227}
      
        "(GMT+08:00) Kuala Lumpur, Singapore"                               {$TimeZoneCode = 215}
      
        "(GMT+08:00) Perth"                                                 {$TimeZoneCode = 225}
      
        "(GMT+08:00) Taipei"                                                {$TimeZoneCode = 220}
      
        "(GMT+09:00) Osaka, Sapporo, Tokyo"                                 {$TimeZoneCode = 235}
      
        "(GMT+09:00) Seoul"                                                 {$TimeZoneCode = 230}
      
        "(GMT+09:00) Yakutsk"                                               {$TimeZoneCode = 240}
      
        "(GMT+09:30) Adelaide"                                              {$TimeZoneCode = 250}
      
        "(GMT+09:30) Darwin"                                                {$TimeZoneCode = 245}
      
        "(GMT+10:00) Brisbane"                                              {$TimeZoneCode = 260}
      
        "(GMT+10:00) Canberra, Melbourne, Sydney"                           {$TimeZoneCode = 255}
      
        "(GMT+10:00) Guam, Port Moresby"                                    {$TimeZoneCode = 275}
      
        "(GMT+10:00) Hobart"                                                {$TimeZoneCode = 265}
      
        "(GMT+10:00) Vladivostok"                                           {$TimeZoneCode = 270}
      
        "(GMT+11:00) Magadan, Solomon Is., New Caledonia"                   {$TimeZoneCode = 280}
      
        "(GMT+12:00) Auckland, Wellington"                                  {$TimeZoneCode = 290}
      
        "(GMT+12:00) Fiji, Kamchatka, Marshall Is."                         {$TimeZoneCode = 285}
      
        "(GMT+13:00) Nuku'alofa"                                            {$TimeZoneCode = 300}
        
        default                                                             {$TimeZoneCode = 9999999}
  
    }
    return $TimeZoneCode
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Validate_Windows_Time_Zone ($TimeZone,[REF]$Success, [REF]$ErrorMsg)
{
    if($TimeZone)
    {
        $TimeZoneCode = Get_Windows_Time_Zone $TimeZone
        if($TimeZoneCode -ne 9999999)
        {
        
            Log-Message -Type "DEBUG" -Message "Time Zone provided $TimeZone is of correct format"
			$Success.Value = $true
			$ErrorMsg.Value = "Time Zone provided " + $TimeZone + " is of correct format"
        }
        else
        {
            Log-Message -Type "ERROR" -Message "$ERROR_ID_55"
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_55
        }
        
    }
    else
    {
            Log-Message -Type "ERROR" -Message "$ERROR_ID_54"
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_54
    }

}
#####################################################################################################
#
#
#
#
#####################################################################################################

Function Check_PRODUCT_KEY_Format($productkey,[REF]$Success, [REF]$ErrorMsg)
{
   if($productkey)
   {   
		$result = $productkey -match "^([A-Za-z0-9]{5}-){4}[A-Za-z0-9]{5}$"
		if ($result)
		{	
			Log-Message -Type "DEBUG" -Message "Product Key provided $productkey is of correct format"
			$Success.Value = $true
			$ErrorMsg.Value = "Product Key provided " + $productkey + " is of correct format"
			
		}
		else
		{
			Log-Message -Type "ERROR" -Message "$ERROR_ID_24"
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_24
		}
	}
	else
	{
			Log-Message -Type "ERROR" -Message "$ERROR_ID_47"
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_47
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_Work_Group_Format ($Work_Group,[REF]$Success, [REF]$ErrorMsg)
{
	if($Work_Group )
	{
		Log-Message -Type "DEBUG" -Message "Workgroup Option provided $Work_Group is valid"
		$Success.Value = $true
		$ErrorMsg.Value = "Workgroup Option provided " + $Work_Group + " is valid"
	}
	else
	{
		Log-Message -Type "ERROR" -Message "$ERROR_ID_32"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_32
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_WORK_GROUP_NAME_Format ($Work_Group_name,[REF]$Success, [REF]$ErrorMsg)
{
	if($Work_Group_name )
	{
        Log-Message -Type "DEBUG" -Message "Work Group Name provided $Work_Group_name is of correct format"
		$Success.Value = $true
		$ErrorMsg.Value = "Work Group Name provided " + $Work_Group_name + " is of correct format"
	}
	else
	{
		Log-Message -Type "ERROR" -Message "$ERROR_ID_32"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_32
	}
}

#####################################################################################################
#
#This function validates format of the domain name. Universal principal name is not supported.
#
#
#####################################################################################################
Function Check_DOMAIN_NAME_Format ($domain_name,[REF]$Success, [REF]$ErrorMsg)
{
	if($domain_name )
	{
        $domain_nametrimmed = $domain_name.Trim()
        
        if($domain_nametrimmed.StartsWith('.') -or $domain_nametrimmed.EndsWith('.'))
        {
               Log-Message -Type "ERROR" -Message "Incorrect domain format, period is not allowed at the start and end of the string $domain_nametrimmed"
        }
        else 
        {
              if($domain_nametrimmed -match "\b[a-z.]\b" -or $domain_nametrimmed -match "\b[A-Z.]\b")
              {
				   Log-Message -Type "DEBUG" -Message "Domain Name $domain_nametrimmed is of correct format"
				   $Success.Value = $true
				   $ErrorMsg.Value = "Domain User Name " + $domain_nametrimmed + " is of correct format"
              }
              else 
              {
					Log-Message -Type "ERROR" -Message "Incorrect Domain Name Format"
              }
        }
	}
	else
	{
		Log-Message -Type "ERROR" -Message "$ERROR_ID_33"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_33
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_DNS_SUFFIX_Format ($dns_suffix,[REF]$Success, [REF]$ErrorMsg)
{
	if($dns_suffix )
	{
		Log-Message -Type "DEBUG" -Message "Dns Suffix provided $dns_suffix is of correct format"
		$Success.Value = $true
		$ErrorMsg.Value = "Dns Suffix provided " + $dns_suffix + " is of correct format"
	}
	else
	{
		Log-Message -Type "ERROR" -Message "$ERROR_ID_34"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_34
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_DOMAIN_USER_Format ($domain_user,[REF]$Success, [REF]$ErrorMsg)
{
	if($domain_user )
	{
		Log-Message -Type "DEBUG" -Message "Domain User Name $domain_user is of correct format"
		$Success.Value = $true
		$ErrorMsg.Value = "Domain User Name " + $domain_user + " is of correct format"
	}
	else
	{
		Log-Message -Type "ERROR" -Message "$ERROR_ID_38"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_38
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_DOMAIN_PASSWORD_Format ($domain_password,[REF]$Success, [REF]$ErrorMsg)
{
	if($domain_password )
	{
		Log-Message -Type "DEBUG" -Message "Domain password provided $domain_password is of correct format"
		$Success.Value = $true
		$ErrorMsg.Value = "Domain password provided " + $domain_password + " is of correct format"
	}
	else
	{
		Log-Message -Type "ERROR" -Message "$ERROR_ID_39"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_39
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_ORGANIZATION_Name_Format ($organization_name,[REF]$Success, [REF]$ErrorMsg)
{
	if($organization_name )
	{
		Log-Message -Type "DEBUG" -Message "Organization Name provided $organization_name is of correct format"
		$Success.Value = $true
		$ErrorMsg.Value = "Organization Name provided " + $organization_name + " is of correct format"
	}
	else
	{
		Log-Message -Type "ERROR" -Message "$ERROR_ID_40"
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_40
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_ORGANIZATION_UNIT_Format ($organization_unit,[REF]$Success, [REF]$ErrorMsg)
{
	if($organization_unit )
	{
		Log "DEBUG" ("Organization Unit provided " + $organization_unit + " is of correct format")
		$Success.Value = $true
		$ErrorMsg.Value = "Organization Unit provided " + $organization_unit + " is of correct format"
	}
	else
	{
		LOG "ERROR" ($ERROR_ID_59)
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_59
	}
}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_ORGANIZATION_LOCATION_Format ($organization_location,[REF]$Success, [REF]$ErrorMsg)
{
	if($organization_location )
	{
		Log "DEBUG" ("Organization Location provided " + $organization_location + " is of correct format")
		$Success.Value = $true
		$ErrorMsg.Value = "Organization Location provided " + $organization_location + " is of correct format"
	}
	else
	{
		LOG "ERROR" ($ERROR_ID_60)
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_60
	}
}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_ORGANIZATION_STATE_Format ($organization_state,[REF]$Success, [REF]$ErrorMsg)
{
	if($organization_state )
	{
		Log "DEBUG" ("Organization State provided " + $organization_state + " is of correct format")
		$Success.Value = $true
		$ErrorMsg.Value = "Organization State provided " + $organization_state + " is of correct format"
	}
	else
	{
		LOG "ERROR" ($ERROR_ID_61)
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_61
	}
}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_ORGANIZATION_COUNTRY_Format ($organization_country,[REF]$Success, [REF]$ErrorMsg)
{
	if($organization_country )
	{
		$ShortName = ""
		$GetShortNameSuccess = $false
		$GetShortNameErrorMsg = ""
		
		GetShortCountryName $organization_country ([REF]$ShortName) ([REF]$GetShortNameSuccess) ([REF]$GetShortNameErrorMsg)
		
		if($GetShortNameSuccess -eq $true)
		{
			Log "DEBUG" ("Organization Country provided: " + $organization_country + " is of correct format")
			$Success.Value = $true
			$ErrorMsg.Value = "Organization Country provided: " + $organization_country + " is of correct format"
		}
		else
		{
			Log "ERROR" ("Organization Country provided: " + $organization_country + " is invalid")
			$Success.Value = $false
			$ErrorMsg.Value = $GetShortNameErrorMsg
		}	
		
	}
	else
	{
		LOG "ERROR" ($ERROR_ID_62)
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_62
	}
}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_OWNER_Name_Format ($owner_name,[REF]$Success, [REF]$ErrorMsg)
{
	if($owner_name )
	{	
		#Administrator and Guest are not allowed.
		
		if(($owner_name -like "Administrator") -or ($owner_name -like "Guest"))
		{
			Log "ERROR" ($ERROR_ID_17)
			Log "ERROR" ("Administrator and Guest are not allowable names to use")
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_17 + " Administrator and Guest are not allowable names to use"
		}		
		else
		{
			Log "DEBUG" ("Owner Name provided " + $owner_name + " is of correct format")
			$Success.Value = $true
			$ErrorMsg.Value = "Owner Name provided " + $owner_name + " is of correct format"
		}
	}
	else
	{
		LOG "ERROR" ($ERROR_ID_41)
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_41
	}
}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_LOCAL_ADMIN_PASSWORD_Format ($local_admin_password,[REF]$Success, [REF]$ErrorMsg)
{
	if($local_admin_password )
	{
		Log "DEBUG" ("Local Admin Password provided " + $local_admin_password + " is of correct format")
		$Success.Value = $true
		$ErrorMsg.Value = "Local Admin Password provided " + $local_admin_password + " is of correct format"
	}
	else
	{
		LOG "ERROR" ("Local Admin Password provided " + $local_admin_password + " is of incorrect format")
		$Success.Value = $false
		$ErrorMsg.Value = "Local Admin Password provided " + $local_admin_password + " is of incorrect format"
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_NIC_Data ([REF]$Success, [REF]$ErrorMsg)
{
	if($vm.NIC_NUM)
	{
		Log "DEBUG" ("Number of NICs is provided ")
		
		if(($vm.NIC_NUM -lt 1) -or ($vm.NIC_NUM  -gt 2))
		{
			LOG "ERROR" ($ERROR_ID_18)
			$Success.Value = $false
			$ErrorMsg.Value = $ERROR_ID_18
		}		
		else 
		{		
			Log "DEBUG" ("Number of NICs provided is valid")
		
			$Nic1ValidationSuccessful = $true
			$Nic2ValidationSuccessful = $true			
			
			if(($vm.NIC_NUM -eq 1) -or ($vm.NIC_NUM -eq 2))
			{
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate IP address format
				Check_IP_Address_Format "IP Address NIC1" $vm.IP_ADDRESS_NIC1 ([REF]$IsSuccess) ([REF]$ErrMsg)
				$Nic1ValidationSuccessful = $Nic1ValidationSuccessful -and $IsSuccess
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate IP address format of subnet mask
				Check_IP_Address_Format "Subnet Mask NIC1" $vm.SUB_NET_MASK_NIC1 ([REF]$IsSuccess) ([REF]$ErrMsg)
				$Nic1ValidationSuccessful = $Nic1ValidationSuccessful -and $IsSuccess
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate IP address format of Default gateway
				Check_IP_Address_Format "Default Gateway NIC1" $vm.DEFAULT_GATEWAY_NIC1  ([REF]$IsSuccess) ([REF]$ErrMsg)
				$Nic1ValidationSuccessful = $Nic1ValidationSuccessful -and $IsSuccess
					
				
				if($vm.OS_TYPE -eq "Linux")
				{
					#For Linux DNS IP address is optional.
					#However if Domain Name is provided DNS IP address is manddatory.
					
					$IsSuccess = $false
					$ErrMsg = ""		
					#Validate IP address format of DNS server
					Check_DNS_IP_Address_For_Linux $vm.DNS_IP_NIC1 ([REF]$IsSuccess) ([REF]$ErrMsg)
					$Nic1ValidationSuccessful = $Nic1ValidationSuccessful -and $IsSuccess
				}
				else
				{
					#For Window DNS IP address is mandatory.
					
					$IsSuccess = $false
					$ErrMsg = ""		
					#Validate IP address format of DNS server
					Check_IP_Address_Format "DNS NIC1" $vm.DNS_IP_NIC1 ([REF]$IsSuccess) ([REF]$ErrMsg)
					$Nic1ValidationSuccessful = $Nic1ValidationSuccessful -and $IsSuccess				
				}
				
				#Validate Alternate DNS Server only if provided.				
				if($vm.DNS_ALTERNATE_NIC1)
				{				
					$IsSuccess = $false
					$ErrMsg = ""		
					#Validate IP address format of DNS server
					Check_IP_Address_Format "Alternate DNS NIC1" $vm.DNS_ALTERNATE_NIC1 ([REF]$IsSuccess) ([REF]$ErrMsg)
					$Nic1ValidationSuccessful = $Nic1ValidationSuccessful -and $IsSuccess
				}
				
			}
			if($vm.NIC_NUM -eq 2)
			{
				$Nic2ValidationSuccessful = $true
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate IP address format
				Check_IP_Address_Format "IP Address NIC2" $vm.IP_ADDRESS_NIC2 ([REF]$IsSuccess) ([REF]$ErrMsg)
				$Nic2ValidationSuccessful = $Nic2ValidationSuccessful -and $IsSuccess
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate IP address format of subnet mask
				Check_IP_Address_Format "Subnet Mask NIC2" $vm.SUB_NET_MASK_NIC2 ([REF]$IsSuccess) ([REF]$ErrMsg)
				$Nic2ValidationSuccessful = $Nic2ValidationSuccessful -and $IsSuccess
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate IP address format of Default gateway
				Check_IP_Address_Format "Default Gateway NIC2" $vm.DEFAULT_GATEWAY_NIC2  ([REF]$IsSuccess) ([REF]$ErrMsg)
				$Nic2ValidationSuccessful = $Nic2ValidationSuccessful -and $IsSuccess
					
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate IP address format of DNS server
				Check_IP_Address_Format "DNS NIC2" $vm.DNS_IP_NIC2 ([REF]$IsSuccess) ([REF]$ErrMsg)
				$Nic2ValidationSuccessful = $Nic2ValidationSuccessful -and $IsSuccess
				
				#Validate Alternate DNS Server only if provided.				
				if($vm.DNS_ALTERNATE_NIC2)
				{				
					$IsSuccess = $false
					$ErrMsg = ""		
					#Validate IP address format of DNS server
					Check_IP_Address_Format "Alternate DNS NIC2" $vm.DNS_ALTERNATE_NIC2 ([REF]$IsSuccess) ([REF]$ErrMsg)
					$Nic2ValidationSuccessful = $Nic2ValidationSuccessful -and $IsSuccess
				}
			}
			
			if($Nic1ValidationSuccessful -and $Nic2ValidationSuccessful)
			{
				Log-Message -Type "DEBUG" -Message "NIC Validation Successful"
				$Success.Value = $true
				$ErrorMsg.Value = "NIC Validation Successful"
			}
			else
			{
				if($Nic1ValidationSuccessful -eq $false)
				{
					Log-Message -Type "ERROR" -Message "NIC1 Validation Failed"
					$Success.Value = $false
					$ErrorMsg.Value = "NIC1 Validation Failed"
				
				}
				
				if($Nic2ValidationSuccessful -eq $false)
				{	
					Log-Message -Type "ERROR" -Message "NIC2 Validation Failed"
					$Success.Value = $false
					$ErrorMsg.Value = "NIC2 Validation Failed"
				
				}
			
			}
		}		
		
	}
	else
	{
		LOG "ERROR" ($ERROR_ID_42)
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_42
	}
}


#####################################################################################################
#
#
#
#
#####################################################################################################
Function Validate_vCenter_Resource_Availability ([REF]$Success, [REF]$ErrorMsg)
{
	$Success.Value = $true

	Log-Message -Type "INFO" -Message "Validating the availability of source and destination hosts, source and destination dataStores, virtual machine names and templates provided"
    
	foreach ($vm in $Global_Vm_array)
    {
		$ResourceValidationSuccessful = $true

        if($vm.CREATEVM -like "YES") {
            Log-Message -Type "INFO" -Message "Validating the data provided for VM: $($vm.NEW_VM_NAME)"
        		
            $IsSuccess = $false
            $ErrMsg = ""		
            #Validate source host, source datastore and template availability all in one go
            Does_Template_Exist_Optimized $vm.GOLDEN_TEMPLATE_NAME $vm.DATA_CENTER $vm.VCENTER_IP ([REF]$IsSuccess) ([REF]$ErrMsg)
            $ResourceValidationSuccessful = $ResourceValidationSuccessful -and $IsSuccess
        			
            $IsSuccess = $false
            $ErrMsg = ""		
            #Validate Source Host IP 
            Does_VirtualMachine_Exist $vm.NEW_VM_NAME $vm.DEST_HOST_IP $vm.DATA_CENTER $vm.VCENTER_IP ([REF]$IsSuccess) ([REF]$ErrMsg)	$false
            $ResourceValidationSuccessful = $ResourceValidationSuccessful -and !$IsSuccess #!Success : VM with same name should not exits		
        			
            $IsSuccess = $false
            $ErrMsg = ""		
            #Validate destination host and destination datastore
            Does_DestHost_And_DestDataStore_Exist  $vm.DEST_DATASTORE_NAME   $vm.DEST_HOST_IP $vm.VCENTER_IP ([REF]$IsSuccess) ([REF]$ErrMsg)
            $ResourceValidationSuccessful = $ResourceValidationSuccessful -and $IsSuccess
        			
            if($ResourceValidationSuccessful -eq $true)
            {	
        	    Log-Message -Type "INFO" -Message "Resource Validation Succeeded for VM: $($vm.NEW_VM_NAME)"
            }
            else
            {
        	Log-Message -Type "ERROR" -Message "Resource Validation Failed for VM: $($vm.NEW_VM_NAME)"
        	$ErrorMsg.Value = "Resource Validation Failed for VM " + $vm.NEW_VM_NAME
        	$vm.TASK_STATUS = "Failed"
        	$vm.ERROR_MESSAGE = "Resource Validation Failed"
        	
            }
		}
		
   		$Success.Value = $Success.Value -and $ResourceValidationSuccessful

  	} # end of for loop

	
	if($Success.Value -eq $true)
	{
		$ErrorMsg.Value  = "Resource Validation of all VMs succeeded"	
		Log-Message -Type "INFO" -Message "Resource Validation completed successfully."
	}
	else
	{
		$ErrorMsg.Value  = "Resource Validation did not succeed"
		Log-Message -Type "ERROR" -Message "Resource Validation completed NOT successfully."
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_Workgroup_Domain_Data ([REF]$Success, [REF]$ErrorMsg)
{

$YES = "YES"
$NO = "NO"

$Success.Value = $true
$ErrorMsg.Value = "Success"
	
	if($vm.WORK_GROUP)
	{
		#Is WorkGroup Selected
		if($vm.WORK_GROUP -eq $YES)
		{		
			LOG $DEBUG ("WorkGroup Option Selected is YES. Computer will be added to WorkGroup")		

			#Is WorkGroup Name provided
			if($vm.WORK_GROUP_NAME)
			{
				LOG $DEBUG ("WorkGroup Name provided")		
			}
			else
			{
				LOG $LOGERROR ("WorkGroup is Selected but Work Group Name is not provided")
				$Success.Value = $false
				$ErrorMsg.Value = $ERROR_ID_48
			}
		}
        elseif($vm.WORK_GROUP -eq $NO)
		{
			LOG $DEBUG ("WorkGroup Option Selected is NO")	
			
			#Is Domain Name Provided
			if($vm.DOMAIN_NAME)
			{
				LOG $DEBUG ("Domain Name provided")
				
				$IsDomainNameFormatValid = $false
				$DomainNameErrMsg = ""
				
				Check_DOMAIN_NAME_Format $vm.DOMAIN_NAME ([REF]$IsDomainNameFormatValid) ([REF]$DomainNameErrMsg)
				
				if($vm.DOMAIN_USER -and $vm.DOMAIN_PASSWORD)
				{
					LOG $DEBUG ("Domain User and Domain Password provided")
				}
				else
				{
					if(!$vm.DOMAIN_USER)
					{
						LOG $LOGERROR ($ERROR_ID_50)
						$Success.Value = $false
						$ErrorMsg.Value = $ERROR_ID_50
					}
					
					if(!$vm.DOMAIN_PASSWORD)
					{
						LOG $LOGERROR ($ERROR_ID_51)
						$Success.Value = $false
						$ErrorMsg.Value = $ERROR_ID_51
					}
				
				}
			}
			else
			{
				LOG $LOGERROR ($ERROR_ID_49)	
				$Success.Value = $false
				$ErrorMsg.Value = $ERROR_ID_49
			}
			
		}		
	
	}
	else
	{		
		LOG $LOGERROR ($ERROR_ID_52)	
		$Success.Value = $false
		$ErrorMsg.Value = $ERROR_ID_52	
	}

}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_Domain_And_DNS_Data_For_Linux ([REF]$Success, [REF]$ErrorMsg)
{
	$Success.Value = $true
	$ErrorMsg.Value = "Success"
		
	#Is Domain Name Provided
	if($vm.DOMAIN_NAME)
	{	
		if($vm.DNS_IP_NIC1)
		{
			#Both data available.PASS
			$Success.Value = $true
			$ErrorMsg.Value = "Success. Both DNS and Domain data are available"
			Log-Message -Type "DEBUG" -Message "Both DNS and Domain data are provided"
		}
		else
		{
			#Domain data is provided but DNS data is not Provided. FAIL
			$Success.Value = $false
			$ErrorMsg.Value = "Domain data is provided but DNS data is not Provided"
			Log-Message -Type "ERROR" -Message "Domain data is provided but DNS data is not Provided"
		}		
	}
	else
	{
		if($vm.DNS_IP_NIC1)
		{
			#DNS data is provided but Domain data is not Provided. FAIL
			$Success.Value = $false
			$ErrorMsg.Value = "DNS data is provided but Domain data is not Provided."
			Log-Message -Type "ERROR" -Message "DNS data is provided but Domain data is not Provided."
		}
		else
		{
			#Both data not available.PASS
			$Success.Value = $true
			$ErrorMsg.Value = "Success. Both DNS and Domain data are not available"
			Log-Message -Type "DEBUG" -Message "Both DNS and Domain data are not provided"
		}
	}	

}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_Domain_Data_Linux ([REF]$Success, [REF]$ErrorMsg)
{
	$Success.Value = $true
	$ErrorMsg.Value = "Success"
		
	#Is Domain Name Provided
	if($vm.DOMAIN_NAME)
	{
		LOG $DEBUG ("Domain Name provided")
		
		$IsDomainNameFormatValid = $false
		$DomainNameErrMsg = ""
		
		Check_DOMAIN_NAME_Format $vm.DOMAIN_NAME ([REF]$IsDomainNameFormatValid) ([REF]$DomainNameErrMsg)				
		$Success.Value = $IsDomainNameFormatValid
		$ErrorMsg.Value = $DomainNameErrMsg
	}
	# else ### Making Domain Name Optional
	# {
		# LOG $LOGERROR ($ERROR_ID_58)	
		# $Success.Value = $false
		# $ErrorMsg.Value = $ERROR_ID_58
	# }	

}

################################################################################################################
#Product version validation for all VOS products 
################################################################################################################

Function Validate_VOS_Product_Version($VOS_VmType,$Product_Version,[REF]$IsSuccess,[REF]$ErrMsg)
{
$IsSuccess.Value = $true
$ErrMsg.Value = ""

	if ($VOS_VmType -match "CUCM_")
	{
		$SupportedVersion1052 = "10.[5-9].[2-9][0-9]?" #matches version 10.5.2,10.5.3,10.5.12ab....10.9.99# ##Variable to support CUCM-10.5.2,will be removed once CUCM is supported from 11.0.1 and above.#
		$SupportedVersion = "1[1-9].[0-9].[1-9][0-9]?" #matches version 11.0.1,11.5.3,11.5.12ab....19.9.99
		
	}
		
	if (($VOS_VmType -match "CUIC") -or ($VOS_VmType -match "LiveData") -or ($VOS_VmType -match "FINESSE_") -or ($VOS_VmType -match "MEDIASENSE_") -or ($VOS_VmType -match "VVB") -or ($VOS_VmType -match "CUICLDwithIDS") -or ($VOS_VmType -match "Cisco_IDS"))
	{
		$SupportedVersion = "1[1-9].[0-9].[1-9][0-9]?" #matches version 11.0.1,11.1.2,11.5.1,11.5.12ab....19.9.99
	}

	if($Product_Version)
	{	
		$Product_Version_Trimmed = $Product_Version.trim()			
		
		LOG $DEBUG ($VOS_VmType + "Product Version provided is: " + $Product_Version_Trimmed)
		
		if(($Product_Version_Trimmed -match $SupportedVersion) -or ($Product_Version_Trimmed -match $SupportedVersion1052))
		{
			$IsSuccess.Value = $true
			$ErrMsg.Value = $VOS_VmType + "Product Version provided " + $Product_Version_Trimmed + " is supported"
		}
		else
		{
			$IsSuccess.Value = $false
			LOG "ERROR" ("Product Version " + $Product_Version_Trimmed + " of " + $VOS_VmType + " is not supported")
			$ErrMsg.Value = "Product Version " + $Product_Version_Trimmed + " of " + $VOS_VmType + " is not supported"
		}
	}
	else
	{
		$IsSuccess.Value = $false
		LOG "ERROR" ("No value provided for" + $VOS_VmType + " Product Version")
		$ErrMsg.Value = "No value provided for" + $VOS_VmType + " Product Version"
	}
}

################################################################################################################
Function ValidatePublisherDataAvailability ($Global_Vm_array,[REF]$Success, [REF]$ErrorMsg)
{
	$Success.Value = $true
	$ErrorMsg.Value = "Success"
	
	
	$PublisherDataValidationSuccess = $false
	$PublisherDataValidationErrMsg = "Success"
	ValidateVOSPublisherDataAvailability $Global_Vm_array ([REF]$PublisherDataValidationSuccess) ([REF]$PublisherDataValidationErrMsg)

	if($PublisherDataValidationSuccess)
	{
		$Success.Value = $true
		$ErrorMsg.Value = "Success"
	}
	else
	{
		$Success.Value = $false
		$ErrorMsg.Value = "Publisher data validation failed."
	}

	
}
################################################################################################################

Function ValidateVOSPublisherDataAvailability ($Global_Vm_array,[REF]$Success, [REF]$ErrorMsg)
{
	$Success.Value = $true
	$PublisherData = ""
	
	foreach ($vm in $Global_Vm_array)
	{	
		$ValidationSuccessful = $true
	
		if(($vm.VM_TYPE -match "PUB") -or ($vm.VM_TYPE -match "PRIMARY"))
		{
			Log-Message -Type "DEBUG" -Message "Copying $($vm.VM_TYPE) publisher data for use with Subscriber"
			$PublisherData = $vm
		}
	
		if(($vm.VM_TYPE -match "SUB") -or ($vm.VM_TYPE -match "SECONDARY"))
		{
			if($vm.CREATEVM -like "YES")
			{	
				Log-Message -Type "DEBUG" -Message "Checking $($vm.VM_TYPE) Publisher Data Availability for VM $($vm.NEW_VM_NAME)"
				
				$IsSuccess = $false
				$ErrMsg = ""
				Check_IP_Address_Format " Publisher IP" $PublisherData.IP_ADDRESS_NIC1 ([REF]$IsSuccess) ([REF]$ErrMsg)
				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
				$IsSuccess = $false
				$ErrMsg = ""
				Check_Computer_Name $PublisherData.COMPUTER_NAME ([REF]$IsSuccess) ([REF]$ErrMsg)
				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess				
			}
			else
			{				
				Log-Message -Type "DEBUG" -Message "Skipped Validating PublisherData Availability for Subscriber $($vm.VM_TYPE)"
			}
			
			if($ValidationSuccessful -eq $true)
			{	
				Log-Message -Type "DEBUG" -Message "$($vm.VM_TYPE) Publisher Data Availability Check Succeeded for VM $($vm.NEW_VM_NAME)"

			}
			else
			{
				Log-Message -Type "ERROR" -Message "$($vm.VM_TYPE) Publisher Data Availability Check Failed for VM $($vm.NEW_VM_NAME)"
				$vm.TASK_STATUS = "Failed"
				$vm.ERROR_MESSAGE = $vm.VM_TYPE + " Publisher Data Availability Check Failed."
			}
			
			$Success.Value = $Success.Value -and $ValidationSuccessful			
			
		}		
		
	}
	
	if($Success.Value -eq $true)
	{
		$ErrorMsg.Value  = $vm.VM_TYPE + " Publisher Data Availability Check Succeeded for all Subscribers"	
	}
	else
	{
		$ErrorMsg.Value  = $vm.VM_TYPE + " Publisher Data Availability Check failed"	
	}

}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Validate_User_Input_Data_From_XL([REF]$Success, [REF]$ErrorMsg)
{

Log-Message -Type "INFO" -Message "Validating the data provided"

$ProceedWithFurtherValidation = $false
$Success.Value = $true

    foreach ($vm in $Global_Vm_array)
    {
        
		#Reset the flag.
		$ValidationSuccessful = $true
       		
		if($vm.CREATEVM -like "YES" -or $vm.OPERATION -ne [DBNull]::Value )
		{       
                            
			if($vm.NEW_VM_NAME -ne [DBNull]::Value -and $vm.NEW_VM_NAME -ne "NEW_VM_NAME")
			{
				
				$ProceedWithFurtherValidation = $true
                               					
				Log-Message -Type "INFO" -Message "Validating the data provided for VM: $($vm.NEW_VM_NAME)"
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate template data
				Validate_Template_Data $vm.GOLDEN_TEMPLATE_NAME ([REF]$IsSuccess) ([REF]$ErrMsg)
				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess	
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate New Virtual Machine Name
				Validate_VirtualMachine_Name $vm.NEW_VM_NAME ([REF]$IsSuccess) ([REF]$ErrMsg)
				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate destination host data
				ValidateVMHostData $vm.DEST_HOST_IP  "destination" ([REF]$IsSuccess) ([REF]$ErrMsg)
				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
                				
				$IsSuccess = $false
				$ErrMsg = ""		
				#Validate Destination DataStore Data
				Validate_DataStore_Data $vm.DEST_DATASTORE_NAME  "destination" ([REF]$IsSuccess) ([REF]$ErrMsg)
				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
                
                				
				if($vm.CUSTOMIZATION -eq "YES") {
    				
                    $IsSuccess = $false
    				$ErrMsg = ""		
    				#Validate Computer Name
                    Check_Computer_Name $vm.COMPUTER_NAME ([REF]$IsSuccess) ([REF]$ErrMsg)
    				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
                
                }				
				
				if($vm.OS_TYPE -eq $LINUX -and $vm.CUSTOMIZATION -like "YES" -and $vm.CREATEVM -like "YES") {													
                    $IsSuccess = $false
					$ErrMsg = ""		
					#Validate DNS Suffix data
					Check_Domain_And_DNS_Data_For_Linux ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					$IsSuccess = $false
					$ErrMsg = ""		
					#Validate Product Version
					Validate_VOS_Product_Version $vm.VM_TYPE $vm.PRODUCT_VERSION ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
                
                    $IsSuccess = $false
					$ErrMsg = ""
					#Domain Information Validation for CUIC&LD and Finesse
					if(($vm.VM_TYPE -match "FINESSE_") -or ($vm.VM_TYPE -match "CUIC") -or ($vm.VM_TYPE -match "LiveData") -or ($VOS_VmType -match "CUICLDwithIDS") -or ($VOS_VmType -match "Cisco_IDS"))
					{
                        Check_DNS_Domain $vm.DOMAIN_NAME ([REF]$IsSuccess) ([REF]$ErrMsg)
						$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
                
					}
							
                    $IsSuccess = $false
					$ErrMsg = ""		
					#Validate Linux Time zone
					Validate_Linux_Time_Zone $vm.TIME_ZONE_LINUX_AREA $vm.TIME_ZONE_LINUX_LOCATION ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess			
				
					#Validate domain data. Domain Data is optional. However, if DNS IP is provided then Domain Name is mandatory.
					$IsSuccess = $false
					$ErrMsg = ""		
					Check_Domain_Data_Linux ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					$IsSuccess = $false
					$ErrMsg = ""	
					#Validate organization name
					Check_ORGANIZATION_Name_Format $vm.ORGANIZATION_Name  ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess	
				
					$IsSuccess = $false
					$ErrMsg = ""	
					#Validate organization unit
					Check_ORGANIZATION_UNIT_Format $vm.ORGANIZATION_UNIT  ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					$IsSuccess = $false
					$ErrMsg = ""	
					#Validate organization location
					Check_ORGANIZATION_LOCATION_Format $vm.ORGANIZATION_LOCATION  ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					$IsSuccess = $false
					$ErrMsg = ""	
					#Validate organization state
					Check_ORGANIZATION_STATE_Format $vm.ORGANIZATION_STATE ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					$IsSuccess = $false
					$ErrMsg = ""	
					#Validate organization country
					Check_ORGANIZATION_COUNTRY_Format $vm.ORGANIZATION_COUNTRY ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					#$IsSuccess = $false
					#$ErrMsg = ""	
					#Validate NTP Server
					#Check_IP_Address_Format "NTP Server" $vm.NTP_SERVER ([REF]$IsSuccess) ([REF]$ErrMsg)
					#$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
					
				}
				elseif(($vm.OS_TYPE -match "Windows") -and ($vm.CUSTOMIZATION -eq "YES") )
				{					
					$IsSuccess = $false
					$ErrMsg = ""	
					#Validate organization name
					Check_ORGANIZATION_Name_Format $vm.ORGANIZATION_Name  ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess	
                
					$IsSuccess = $false
					$ErrMsg = ""		
					#Validate owner name		
					Check_OWNER_Name_Format $vm.OWNER_Name  ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					$IsSuccess = $false
					$ErrMsg = ""		
					Check_Workgroup_Domain_Data ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess		
				
					#Validate product key format
					$IsSuccess = $false
					$ErrMsg = ""	
					Check_PRODUCT_KEY_Format $vm.PRODUCT_KEY  ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
				
					#Validate Time Zone for Windows
					$IsSuccess = $false
					$ErrMsg = ""
					Validate_Windows_Time_Zone  $vm.TIME_ZONE_WINDOWS ([REF]$IsSuccess) ([REF]$ErrMsg)
					$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
                
					
				}	
				if($vm.CUSTOMIZATION -eq "YES")
        		{
    				$IsSuccess = $false
    				$ErrMsg = ""		
    				#Validate number of NICs selected
					Check_NIC_Data ([REF]$IsSuccess) ([REF]$ErrMsg)
    				$ValidationSuccessful = $ValidationSuccessful -and $IsSuccess
    				
    				if($ValidationSuccessful -eq $true)
    				{	
    					Log-Message -Type "INFO" -Message "Validation Succeeded for VM $($vm.NEW_VM_NAME)"
    				}
    				else
          			{
						$vm.TASK_STATUS = "Failed"
    					Log-Message -Type "ERROR" -Message "Validation Failed for VM $($vm.NEW_VM_NAME)"
    					$vm.ERROR_MESSAGE = "Validation of data provided in the input file failed."					
    				}
                }
 
			}
			else
			{
  
            	if(!$vm.OPERATION)
	        {
				   $ValidationSuccessful = $false
				   Log-Message -Type "ERROR" -Message "Validation Failed for VM Type $($vm.VM_TYPE)"
				   Log-Message -Type "ERROR" -Message "No Value provided for New VM Name for VM Type $($vm.VM_TYPE)"
				   $vm.ERROR_MESSAGE = "No Value provided for New VM Name"
				   $vm.TASK_STATUS = "Failed"
				}
			}
		}
	
        else
        {                
            if (!$vm.OPERATION) {
			    Log-Message -Type "DEBUG" -Message "Value provided for CREATEVM is NO for VM Type $($vm.VM_TYPE). Skipping VM Creation"
            }
            
		}		
		
		$Success.Value = $Success.Value -and $ValidationSuccessful
        #  LOG "INFO" ("VALIDATION STATUS " + $Success.Value)
    }
	
	if($ProceedWithFurtherValidation -eq $true)
	{
		if($Success.Value -eq $true)
		{
			$ErrorMsg.Value  = "Validation of data for all VMs succeeded"	
		}
		else
		{
			$ErrorMsg.Value  = "Validation of data for all VMs did not succeeded"
		}
	}
	
    else
	{
		$Success.Value = $false
		$ErrorMsg.Value  = "User did not select any VMs for creation."	
	}
}
#####################################################################################################
#
#This function is for getting the size of a template in a given Datastore
#
#
#####################################################################################################
Function Get_Template_Size ($TemplateName, $DataCenterName, $VCenter)
{   
	Log-Message "INFO" "Get_Template_Size TemplateName = $TemplateName, DataCenterName = $DataCenterName, vCenter = $VCenter"
    $FolderSize = 0 #This variable will be returned from this function	
    $DataStoreObj = Get-Datastore -Id (Get-Template $TemplateName -Server $VCenter -Location $DataCenterName | Get-View | Select-Object Datastore | foreach {$_.Datastore}) -Server $VCenter
    $DSView = $DataStoreObj | Get-View    
    $dsBrowser = Get-View $DSView.browser
    $rootPath = "["+$DSView.summary.Name+"]"
    Log-Message "DEBUG" "rootpath = $rootPath"

    $fileQueryFlags = New-Object VMware.Vim.FileQueryFlags
    $fileQueryFlags.FileSize = $true
    $fileQueryFlags.FileType = $true
    $fileQueryFlags.Modification = $true
        
    $searchSpec = New-Object VMware.Vim.HostDatastoreBrowserSearchSpec
    $searchSpec.details = $fileQueryFlags
    $searchSpec.sortFoldersFirst = $true
        
    $searchResult = $dsBrowser.SearchDatastoreSubFolders($rootPath, $searchSpec)   
    
	$folderpathmatchpattern = $TemplateName + "/"
	
	$foldermatch = $false
	
    foreach ($result in $searchResult) {
		if($result.FolderPath -match $folderpathmatchpattern) {

			Log-Message "DEBUG" "Found the folder containing the files of the template $TemplateName"
			Log-Message "DEBUG" "Adding up the individual file sizes"	
			foreach($file in $result.File) {
				Log-Message "DEBUG" "file name $($file.Path) is of size $($file.FileSize)"
				$FolderSize = $FolderSize + $file.FileSize				
			}
			
			$foldermatch = $true
			break
		}
		
		if($foldermatch -eq $true) {
			break
		}
    }
    Log-Message "INFO" "Size of the template $TemplateName is $FolderSize"
    return $FolderSize
}

#####################################################################################################
#
#
#
#
#####################################################################################################

Function Create_DataStore_Obj_Array()
{
    $TemplateNameAndSizeMap = @{}
    $DataStoreArray = @() #this array will be returned from this function
    	
    foreach ($vm in $Global_Vm_array) {	

    	if ($vm.CREATEVM -like "YES") {
			if ( $vm.DEST_DATASTORE_NAME -and $vm.DEST_HOST_IP ) {						
				$EntryExists = $false
			   
				foreach($entry in $DataStoreArray) {	
					if(($entry.DEST_HOST_IP -like $vm.DEST_HOST_IP) -and ($entry.DEST_DATASTORE_NAME -like $vm.DEST_DATASTORE_NAME)) {							
						Log-Message "DEBUG" "Combination of $($vm.DEST_DATASTORE_NAME) and $($vm.DEST_HOST_IP) exists in DataStoreArray"
						#Already exists. Hence do not add. Break out of the loop
						$EntryExists = $true
						break
					}				
				}
				
				if($EntryExists -eq $false) {						
					Log-Message "DEBUG" "Combination of $($vm.DEST_DATASTORE_NAME) and $($vm.DEST_HOST_IP) does not exist in DataStoreArray"
					#This combination of Host and Datastore does not exist. Hence add it.
					$objDS = New-Object System.Object
					$objDS | Add-Member -type NoteProperty -name DEST_HOST_IP -value $vm.DEST_HOST_IP
					$objDS | Add-Member -type NoteProperty -name DEST_DATASTORE_NAME -value $vm.DEST_DATASTORE_NAME
					$objDS | Add-Member -type NoteProperty -name Sum_Of_All_Template_Size_MB -value 0
					$objDS | Add-Member -type NoteProperty -name Datastore_FreeSpace_MB -value 0
					$objDS | Add-Member -type NoteProperty -name VALIDATION_SUCCEEDED -value $false
                    $objDS | Add-Member -type NoteProperty -name VCENTER_IP -value $vm.VCENTER_IP
					$DataStoreArray = $DataStoreArray + $objDS					
				}			   
			}   
		}	   
    
    }   
	
    foreach ($DS in $DataStoreArray) {

        Log-Message "DEBUG" "Destination datastore name = $($DS.DEST_DATASTORE_NAME)"
        $TotalTemplateSize = 0
        
         foreach ($vm in $Global_Vm_array) {
			
            if ($vm.CREATEVM -like "YES") {
				
                if(($DS.DEST_HOST_IP -like $vm.DEST_HOST_IP) -and ($DS.DEST_DATASTORE_NAME -like $vm.DEST_DATASTORE_NAME)) {
					
                    $Template_size_with_buffer = 0
					$TemplateNameLookUpstr = $vm.VCENTER_IP + "/" + $vm.DATA_CENTER + "/" + $vm.GOLDEN_TEMPLATE_NAME
					
					if($TemplateNameAndSizeMap.contains($TemplateNameLookUpstr)) {
						
                        #if the map already contains the size of the template then use it.
						$Template_size_with_buffer = $TemplateNameAndSizeMap[$TemplateNameLookUpstr]
					
                    } else {
                       			
                        $Template_size = Get_Template_Size $vm.GOLDEN_TEMPLATE_NAME $vm.DATA_CENTER $vm.VCENTER_IP
                         
                        if($Template_size -gt 0) {						
							
                            $Template_size = $Template_size/(1024*1024)
                            $Template_size_with_buffer = $Template_size + 5120
                            Log-Message "DEBUG" "Template size: $Template_size MB"
                            Log-Message "DEBUG" "Template size with buffer: $Template_size_with_buffer MB"
							
							# map does not contain the size of the template save it.
							$TemplateNameAndSizeMap[$TemplateNameLookUpstr] = $Template_size_with_buffer												
						
                        } else {
							
								Log-Message "ERROR" "Template size calculated is 0. Please check whether the template exists"
							
						}					
						
					}
					
					$TotalTemplateSize = $TotalTemplateSize + $Template_size_with_buffer
				}
			}
         }
         
         $datastore = Get-Datastore -VMHost (Get-VMHost -Name $DS.DEST_HOST_IP -Server $DS.VCENTER_IP) -Name $DS.DEST_DATASTORE_NAME -Server $DS.VCENTER_IP
         $Datastore_FreeSpace_MB = $datastore.FreeSpaceMB
         
         #update Sum_Of_All_Template_Size_MB and Datastore_FreeSpace_MB members of datastore object
		 $DS.Sum_Of_All_Template_Size_MB = $TotalTemplateSize
		 $DS.Datastore_FreeSpace_MB = $Datastore_FreeSpace_MB		 
        
    }
	
    return $DataStoreArray
}
#####################################################################################################
#
#
#
#
#####################################################################################################

Function Validate_DataStore_Space([REF]$Success, [REF]$ErrorMsg)
{
    $DataStore_Obj_Array = Create_DataStore_Obj_Array
    
	$Success.Value = $true
	
    foreach ($DsObj  in $DataStore_Obj_Array)
    {
        if ($DsObj.Sum_Of_All_Template_Size_MB -gt $DsObj.Datastore_FreeSpace_MB)
        {			
			###
			foreach($VirtualMac in $Global_Vm_array)
			{
				if(($VirtualMac.CREATEVM -like "YES") -and (($VirtualMac.DEST_HOST_IP -like $DsObj.DEST_HOST_IP) -and ( $VirtualMac.DEST_DATASTORE_NAME -like $DsObj.DEST_DATASTORE_NAME)))
				{
					$VirtualMac.TASK_STATUS = "Failed"
					$VirtualMac.ERROR_MESSAGE = "Destination datastore free space validation failed"
					
					Log-Message "ERROR" "VM $($VirtualMac.NEW_VM_NAME) cannot be deployed in destination datastore $($DsObj.DEST_DATASTORE_NAME) in host $($DsObj.DEST_HOST_IP) due to limited free space"
				}
			}
			###
			
            Log-Message "ERROR" "Required free space in datastore: $($DsObj.DEST_DATASTORE_NAME) of host: $($DsObj.DEST_HOST_IP) is $($DsObj.Sum_Of_All_Template_Size_MB) MB"
            Log-Message "ERROR" "Available free space in datastore: $($DsObj.DEST_DATASTORE_NAME) of host: $($DsObj.DEST_HOST_IP) is $($DsObj.Datastore_FreeSpace_MB) MB"
			Write-Host "`r"
			$DsObj.VALIDATION_SUCCEEDED = $false
			$Success.Value = $Success.Value -and $false
        }
    
    }
	
	if($Success.Value -eq $true)
	{
		Log-Message "INFO" "Datastore free space validation succeeded. Specified Datastores have enough free space for deploying the VMs"	
		$ErrorMsg.Value = "Datastore free space validation succeeded. Specified Datastores have enough free space for deploying the VMs"
	}
	else
	{		
		$ErrorMsg.Value = "Datastore free space validation failed. Please check the datastores reported for insufficient free space. Specify different datastore in the inputfile and re-run the script"
	}

}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_IF_VM_DEPLOYED()
{
     $VMValidationSuccessful = $true
     $PrintMsg = $true
	 
     foreach ($vm in $Global_Vm_array)
     { 
		if(($vm.CREATEVM -like "YES") -and ($vm.TASK_STATUS -eq "Success"))
		{
			if($PrintMsg -eq $true)
			{
				Write-Host Validating the deployed VMs -foregroundcolor cyan
				$PrintMsg = $false
			}
		
			$VMValidationIsSuccess = $false
			$ValidateVMErrMsg = ""		
			#Validate IP address format
			Does_VirtualMachine_Exist $vm.NEW_VM_NAME $vm.DEST_HOST_IP $vm.DATA_CENTER $vm.VCENTER_IP ([REF]$VMValidationIsSuccess) ([REF]$ValidateVMErrMsg) $true
			$VMValidationSuccessful = $VMValidationSuccessful -and $VMValidationIsSuccess

			if($VMValidationIsSuccess -eq $true)
			{
				$PostVMValidationIsSuccess = $false
				$PostVMValidationErrMsg = ""
				#Check if .vmdk file actually exists
				Post_VM_Validation $vm.NEW_VM_NAME $vm.DEST_HOST_IP $vm.DEST_DATASTORE_NAME $vm.VCENTER_IP ([REF]$PostVMValidationIsSuccess) ([REF]$PostVMValidationErrMsg)
				$VMValidationSuccessful = $VMValidationSuccessful -and $PostVMValidationIsSuccess
				
				if($PostVMValidationIsSuccess -eq $false)
				{
					$vm.ERROR_MESSAGE = "Post VM Creation Validation Failed " + $PostVMValidationErrMsg
					#$vm.TASK_STATUS = "Error"
					$vm.TASK_STATUS = "Failed"
				}
				else
				{
					$vm.ERROR_MESSAGE = "VM deployed successfully"

				}
			}
			else
			{
				$vm.ERROR_MESSAGE = "Post VM Creation Validation Failed " + $ValidateVMErrMsg
				$vm.TASK_STATUS = "Error"
			}	
			
		}
         
     }
	 
	 if($PrintMsg -eq $false)
	 {
		 if(!$VMValidationSuccessful)
		 {
			Log-Message "ERROR" "Validation of deployed VMs failed. Please check the logs for detailed info"
		 }
		 else
		 {
			Log-Message "INFO" "Validation of deployed VMs successful"
		 }
	 }
	 
}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_Computer_Name ($ComputerName ,[REF]$Success, [REF]$ErrorMsg)
{
	$Allowedpattern = "^([a-zA-Z0-9\-]*)$"
	$AlphaPattern = "([a-zA-Z])"
	
	if ( $ComputerName )
	{	
		if($ComputerName.Length -le 15)
		{		
			#check if the specified computer name complies to the pattern
			
			if($compname -match $Allowedpattern )
			{
				
				if($compname -match $charpattern )
				{
					Log-Message "DEBUG" "Computer name $ComputerName is of correct format"
					$Success.Value = $true
					$ErrorMsg.Value = "Computer name " + $ComputerName + " is of correct format"
				}
				else
				{
					#write-host "does not contain alphabets"
					Log-Message "ERROR" "$ERROR_ID_7"
					Log-Message "ERROR" "The specified computer name does not contain alpha numerics"
					$Success.Value = $false
					$ErrorMsg.Value = $ERROR_ID_7
					
				}
				
			}
			else
			{
				Log-Message "ERROR" "$ERROR_ID_7"
				$Success.Value = $false
				$ErrorMsg.Value = $ERROR_ID_7			
			}	

		}
		else
		{
			Log-Message "ERROR" "$ERROR_ID_7"
			$Success.Value = $false
	        $ErrorMsg.Value = $ERROR_ID_7
		}	    
	}
	else
	{
		Log-Message "ERROR" "$ERROR_ID_31"
		$Success.Value = $false
	    $ErrorMsg.Value = $ERROR_ID_31
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_Computer_Name_Format ($ComputerName ,[REF]$Success, [REF]$ErrorMsg)
{
	if ( $ComputerName )
	{	
		if(($ComputerName.Length -le 15) -and (!( $ComputerName.contains(".") -or $ComputerName.contains("\") -or $ComputerName.contains("/")  -or $ComputerName.contains(":")  -or $ComputerName.contains("*")  -or $ComputerName.contains("?")  -or $ComputerName.contains('`') -or $ComputerName.contains('<') -or $ComputerName.contains('>')  -or $ComputerName.contains('|') )))
		{			
			LOG "DEBUG" ("Computer name " + $ComputerName + " is of correct format")
			$Success.Value = $true
	        $ErrorMsg.Value = "Computer name " + $ComputerName + " is of correct format"
		}
		else
		{
			LOG  $LOGERROR ($ERROR_ID_7)
			$Success.Value = $false
	        $ErrorMsg.Value = $ERROR_ID_7
		}	    
	}
	else
	{
		LOG $LOGERROR ($ERROR_ID_31)
		$Success.Value = $false
	    $ErrorMsg.Value = $ERROR_ID_31
	}
}

#####################################################################################################
#
#
#
#
#####################################################################################################
Function Check_For_DNS_Names ($hostAddress)
{
  
   $ipAddress=$hostAddress
   $ipTest=$null
   
   #LOG $INFO ("HOST ADDRESS = " + $hostAddress)
 
  if([system.net.IPAddress]::tryparse($hostAddress,[ref]$ipTest))
  {
  	if (($hostAddress.split(".")|Measure-Object).count -ne 4)
  	{
      	   LOG $ERROR ("INVALID IP ADDRESS CONFIGURED. Value = " + $hostAddress)
  	}
  }    
       
   return $ipAddress
  
}

#####################################################################################################
#
#
#
#
#####################################################################################################

Function ValidateVMNetwork ($NetworkName ,[REF]$Success, [REF]$ErrorMsg)

{

    if($NetworkName)
    { 
        $Success.Value = $true
    	$ErrorMsg.Value = "VM Network " + $NetworkName + " is valid"
    }
    else
    {
        $Success.Value = $false
	    $ErrorMsg.Value = "Field for VM_NETWORK should not be blank"
        LOG $LOGERROR ("No value provided for field VM_NETWORK")
    }
}

#####################################################################################################
#
# Method to process the WinImage config for Vos platforms
#
#
#####################################################################################################

Function winImageProcessing ($TimeStamp, $DirName)
{

    # first check to see if winImage is installed
    if (Test-Path "C:\Progra~2\WinImage")
    {
        $ImageSource = $DirName + "\" + $vm.VM_TYPE + "_platformConfig.flp"
        $SourceBaseFileName = "$($GTHomePath)\base.flp"
        $WinImageFileName = $DirName + "\platformConfig.xml"
        $CopyPlatformImage = copy-item $SourceBaseFileName -destination $ImageSource
        $WinImageArgumentList = $vm.VM_TYPE + "_platformConfig.flp /H /I " + $WinImageFileName

        Log-Message "INFO" "Making floppy image file, if you are using un-licensed winimage, a dialog will pop up, you must click OK on that dialog in order for this process to continue... "
        Log-Message "DEBUG" "ImageSource Path = $ImageSource"
        Log-Message "DEBUG" "SourceBaseFileName Path = $SourceBaseFileName"
        $InjectXMLToFLP = start-process -filepath C:\Progra~2\WinImage\WinImage.exe -ArgumentList $WinImageArgumentList -WorkingDirectory $DirName -WindowStyle Hidden -wait

        Log-Message "INFO" "Done making the floppy image file..."
        #Upload FLP Image to ESXi Host Datastore
        $FLPImageDestination = "DS:\floppies\" + $vm.NEW_VM_NAME + "_platformConfig.flp"
        Log-Message "DEBUG" "FLPImageDestination Path = $FLPImageDestination"

        $CreateNewPowerShellDriveMapping = new-psdrive -name DS -PSProvider VimDatastore -Root "\" -Datastore (get-datastore $vm.DEST_DATASTORE_NAME -Server $vm.VCENTER_IP)
        $UploadFLPToTargetVMDatasoreFolder = copy-datastoreitem -Item $ImageSource -Destination $FLPImageDestination -Force
        $RemovePowerShellDriveMapping = remove-psdrive -name DS

        Log-Message "INFO" "Mount the floppy image into the datastore"
        #Finally mount the floppy image drive after the VM has been created; applies to Linux system only
        #Mount FLP Image to the correct VM and set the floppy to be connected at power on
        $FLPDatastorePath = "[" + $vm.DEST_DATASTORE_NAME + "] floppies/" + $vm.NEW_VM_NAME + "_platformConfig.flp"
        Log-Message "DEBUG" "FLPDatastore Path = $FLPDatastorePath"

        $MountFLPImage = get-vm -name $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | Get-FloppyDrive -Server $vm.VCENTER_IP | Set-FloppyDrive -FloppyImagePath $FLPDatastorePath -Confirm:$false -StartConnected:$true        
        
        # Seems that we don't need to manually change the boot order to the following: Hard disk, Floppy Disk, CD-ROM 
        #LOG $INFO ("Changing the boot order to the following:  Hard disk, Floppy Disk, CD-ROM... ")              
        #changeBootOrder

    }
    else
    {
    
        Log-Message "ERROR" "WinImage not installed in c:\Program files (x86)"
    }
 } 

#####################################################################################################
#
# Method to change the boot order for VOS platforms
# Used the code from http://www.vnugglets.com/2012/02/change-vm-boot-order-via-powershell.html
#
#####################################################################################################
 Function changeBootOrder()
 {
	Add-PSSnapin VMWare.VimAutomation.Core -ea "SilentlyContinue"

	## the VM to configure
	$strVMName = $vm.NEW_VM_NAME

	## the device name of the hard disk to which to boot
	$strBootHDiskDeviceName = "Hard disk 1"

	## get the .NET View object for the VM, with a couple of select properties
	$viewVM = Get-View -ViewType VirtualMachine -Property Name, Config.Hardware.Device -Filter @{"Name" = "^$strVMName$"}
	 
	## get the VirtualDisk device, then grab its Key (DeviceKey, used later)
	$intHDiskDeviceKey = ($viewVM.Config.Hardware.Device | ?{$_.DeviceInfo.Label -eq $strBootHDiskDeviceName}).Key
	## bootable Disk BootOption device, for use in setting BootOrder (the corresponding VirtualDisk device is bootable, assumed)
	$oBootableHDisk = New-Object -TypeName VMware.Vim.VirtualMachineBootOptionsBootableDiskDevice -Property @{"DeviceKey" = $intHDiskDeviceKey}
	 
	## bootable Floppy drive
	$oBootableFloppyDisk = New-Object -TypeName VMware.Vim.VirtualMachineBootOptionsBootableFloppyDevice 

	## bootable CDROM device (per the docs, the first CDROM with bootable media found is used)
	$oBootableCDRom = New-Object -Type VMware.Vim.VirtualMachineBootOptionsBootableCdromDevice
	 
	## create the VirtualMachineConfigSpec with which to change the VM's boot order
	$spec = New-Object VMware.Vim.VirtualMachineConfigSpec -Property @{
	    "BootOptions" = New-Object VMware.Vim.VirtualMachineBootOptions -Property @{
	        ## set the boot order in the spec as desired
	        BootOrder = $oBootableHDisk, $oBootableFloppyDisk, $oBootableCDRom
	    } ## end new-object
	} ## end new-object
	 
	## reconfig the VM to use the spec with the new BootOrder
	$viewVM.ReconfigVM_Task($spec)

 }
