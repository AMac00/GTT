#TODO
#Remove commented-out code in Log-Message
#Fix If/Else statement in RecordSession

# Inputs for calling Main.ps1

[CmdletBinding()]
Param(
    [Parameter(Mandatory=$True)]
    [string]$XLPath,
    [Parameter(Mandatory=$True)]
    [string]$BuildPath,
    [Parameter(Mandatory=$False)]
    [boolean]$DebugMode

)

#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
# Start of functions
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################


#####################################################################################################
# Function Log-Message : Logs messages to console to be captured by Record-Session
#####################################################################################################  
Function Log-Message ($Type, $Message) {

    $currenttime = Get-Date
    
    switch ($type)
    {
        "ERROR"   {Write-Host "$currenttime --> ERROR: $Message" -ForegroundColor Red; break }
        "WARNING" {Write-Host "$currenttime --> WARNING: $Message" -ForegroundColor Yellow; break}
        "DEBUG"   {if ($DebugMode)   {Write-Host "$currenttime --> DEBUG: $Message" -ForegroundColor Cyan; break}}
        "SPECIAL" {if ($SpecialMode) {Write-Host "$currenttime --> SPECIAL: $Message" -ForegroundColor DarkMagenta; break}}
        default   {Write-Host "$currenttime --> INFO: $Message"; break}

    }


    #replaced if/else block with switch statement, left in for this version
    <#
    if ($type -eq "ERROR") 
    {
        Write-Host "$currenttime --> ERROR: $Message" -ForegroundColor Red 
    } 
    elseif ($type -eq "WARNING") 
    {
        Write-Host "$currenttime --> WARNING: $Message" -ForegroundColor Yellow
    } 
    elseif ($type -eq "DEBUG") 
    {
        if ($DebugMode) 
        {
            Write-Host "$currenttime --> DEBUG: $Message" -ForegroundColor Cyan
        }
    } 
    elseif ($type -eq "SPECIAL") 
    {
        if ($SpecialMode) 
        {
            Write-Host "$currenttime --> SPECIAL: $Message" -ForegroundColor DarkMagenta
        }
    } 
    else {
        Write-Host "$currenttime --> INFO: $Message" 
    }
    #>
}

#####################################################################################################
# Function RecordSession : Starts logging in to a file by invoking the command Start-Transcript
#####################################################################################################  
 function RecordSession 
 { 
    $strRet = ""
	$strRet = Start-Transcript $LogFileNameWithFullPath -append -force
}

#####################################################################################################
# Function Test-File-Exists : Tests whether a file path exists
#####################################################################################################  
Function Test-File-Exists ($FilePath) {

    $result = $true
    $tryAgain = $true
    while ($tryagain)
    {
        try 
        {
            Test-Path $FilePath
            Log-Message -Type "INFO" -Message "$FilePath found."
            $tryAgain = $false
        }
        catch
        {
            Log-Message -Type "ERROR" -Message "$FilePath not found."

            $ta = Read-Host "Try again? (Enter to try again): "
            if ($ta -ne "")
            {
                $tryagain = $false
                $result = $false
            }         
        }
    }
    Remove-Variable tryagain, ta -Force
    return $result
}

#####################################################################################################
# Function ExitScript : Exits the execution of the script.
# This function should be called if we need to exit the script.
# Removes the temporary csv created, stops logging and disconnects from the vCenter
#####################################################################################################
Function ExitScript {

	if($IsParametersCSVCreated -eq $true)
	{
        Log-Message -Type "INFO" -Message "Removing CSV File"
		Remove-Item $CSVFileName
	}
	

	if($IsConnectionEstablished -eq $true)
	{
        Log-Message -Type "INFO" -Message "Disconnecting from vCenter(s)..."
        foreach ($vCenter_Session in $Global_vCenter_Session_Array) {
            Log-Message -Type "INFO" -Message $vCenter_Session.SESSION
            Disconnect-VIServer -Server $vCenter_Session.SESSION -Confirm:$false 
        }
        Log-Message -Type "INFO" "...Finished disconnecting"
		
	}
    Stop-Transcript
    exit	
}

#####################################################################################################
# Function Load-Script : Loads scripts and modules into powershell
#####################################################################################################
Function Load-Script ($FilePath)
{

    $result = $true
    $tryAgain = $true
    while ($tryagain)
    {
        try 
        {
            Import-Module -Name $FilePath -Force -ErrorAction Stop
            Log-Message -Type "INFO" -Message "Loaded Module $FilePath"
            $tryAgain = $false
			$ta = ""
        } 
        catch 
        {
            Log-Message -Type "ERROR" -Message "Failed to load $FilePath"

            $ta = Read-Host "Try again? (Enter to try again): "
            if ($ta -ne "")
            {
                $tryagain = $false
                $result = $false
            }
        }
    }
#
    Remove-Variable tryagain, ta -Force
    return $result

}

#####################################################################################################
# Function Add-Items-To-VM-Object : Adds items to the vm array
#####################################################################################################

Function Add-Items-To-VM-Object ($servername, $key, $value) {

    $objVM | Add-Member -type NoteProperty -name $key -value $value
    Log-Message -Type "SPECIAL" "Adding key/value to $servername... $key=$value"    

}

#####################################################################################################
#  Function CreateVirtualMachine : Creates a virtual machine.
#  Invokes other functions to create VMs based on the type of OS
#  After issuing the VM creation command gets the status of the creation of VMs
#####################################################################################################
function CreateVirtualMachine($NewVmName) {                
  
    
    Log-Message -Type "INFO" -Message "Getting Template:  Location = $($vm.DATA_CENTER), Name = $($vm.GOLDEN_TEMPLATE_NAME), vCenter IP = $($vm.VCENTER_IP)"

    if ($vm.OPERATION -eq [DBNull]::Value) {
        $template = Get-Template -Location $vm.DATA_CENTER -Name $vm.GOLDEN_TEMPLATE_NAME -Server $vm.VCENTER_IP 
    }
 
    #Get the hostname
    Log-Message -Type "INFO" -Message "Getting Destination Host: Name = $($vm.DEST_HOST_IP), vCenter IP = $($vm.VCENTER_IP)"
    $vmhost = Get-VMHost -Name $vm.DEST_HOST_IP -Server $vm.VCENTER_IP 
  
    #Get the datastore
    Log-Message -Type "INFO" -Message "Getting Destination Datastore: Name = $($vm.DEST_DATASTORE_NAME), vCenter IP = $($vm.VCENTER_IP)"
    $Datastore = Get-Datastore -Name $vm.DEST_DATASTORE_NAME -VMHost $vmhost -Server $vm.VCENTER_IP 
   
   
    if($vm.OS_TYPE -match "Windows") {
        
	    VMWindows #Calling function for Windows VM creation.
              				
    } elseif(($vm.OS_TYPE -eq "Linux") -and ($vm.OPERATION -eq [DBNull]::Value)) {
  	   
        # No Customization is needed for VOS platforms
	    VMLinuxWithoutCustomization #Calling function for Linux VM creation.                
   
    } elseif(($vm.OS_TYPE -eq "CentOS") -and ($vm.OPERATION -eq [DBNull]::Value)) {

       VMLinux #Calling function for Linux VM creation.    
    }
  
    #Calling the function GetTaskSnapShot to get the status of VM Creation tasks.
    GetTaskSnapShot
	  
}

#####################################################################################################
# Function VMWindows : Creates a Windows VM
# Creates customization Spec based on the OS and WorkGroup/Domain information provided.
# Invokes the command for deploying the VM using the template specified
#####################################################################################################
function VMWindows {

	$Timezone = Get_Windows_Time_Zone $vm.TIME_ZONE_WINDOWS

	$Date = Get-Date
	$WinSpecName = $vm.NEW_VM_NAME + "_" +  $Date.Day +  "_" + $Date.Month + "_" + $Date.Year + "_" + $Date.Hour + "_" + $Date.Minute + "_" + $Date.Second + "_" + $Date.Millisecond		
        
    $WinSpec = New-OSCustomizationSpec -FullName $vm.OWNER_Name -OrgName $vm.ORGANIZATION_Name -OSType Windows -Server $vm.VCENTER_IP -Name $WinSpecName -Type Persistent -TimeZone $Timezone -AdminPassword $BIhash.DOMAINADMINPASSWORD -Workgroup $vm.WORK_GROUP_NAME -NamingScheme Fixed -NamingPrefix $vm.COMPUTER_NAME -ChangeSid	

    if($WinSpec) {	
		$vm.OS_CUST_SPEC_NAME = $WinSpecName
		
		Log-Message -Type "INFO" -Message "Creating CustomizationNICMapping for VM $NewVmName"
		
		$DNSStringNIC1 = @()
		$DNSStringNIC1 += $vm.DNS_IP_NIC1
		if($vm.DNS_ALTERNATE_NIC1)
		{
			$DNSStringNIC1 += $vm.DNS_ALTERNATE_NIC1
		}

		#Edit default customization spec 
		$firstcustomizationspec = Get-OSCustomizationSpec $WinSpecName -Server $vm.VCENTER_IP | Get-OSCustomizationNicMapping -Server $vm.VCENTER_IP | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $vm.IP_ADDRESS_NIC1 -SubnetMask $vm.SUB_NET_MASK_NIC1 -DefaultGateway $vm.DEFAULT_GATEWAY_NIC1 -Dns $DNSStringNIC1 -Server $vm.VCENTER_IP

		if($vm.NIC_NUM -eq "2")
		{
            $DNSStringNIC2 = @()
            $DNSStringNIC2 += $vm.DNS_IP_NIC2
			if($vm.DNS_ALTERNATE_NIC2)
			{
				$DNSStringNIC2 += $vm.DNS_ALTERNATE_NIC2
			}
            
            Log-Message -Type "INFO" -Message "Adding 2nd CustomizationNICMapping for VM $NewVmName"
			$secondcustomizationspec = Get-OSCustomizationSpec $WinSpecName -Server $vm.VCENTER_IP | New-OSCustomizationNicMapping -IpMode UseStaticIP -IPAddress $vm.IP_ADDRESS_NIC2 -SubnetMask $vm.SUB_NET_MASK_NIC2 -DefaultGateway $vm.DEFAULT_GATEWAY_NIC2 -Dns $DNSStringNIC2 -Server $vm.VCENTER_IP	

        }
        
		Log-Message -Type "INFO" -Message "Invoking command for modifying VM $NewVmName with WinSpec = $WinSpec"
		  
        Log-Message -Type "INFO" -Message "Template name = $template, Datastore name = $Datastore"
            
		$VMCreationTask = New-VM -VMHost $vmhost -Name $NewVmName -Template $template -OSCustomizationSpec $WinSpec -Datastore $Datastore -DiskStorageFormat $vm.VM_DISKTYPE -RunAsync -Server $vm.VCENTER_IP
		
        if($VMCreationTask -and $VMCreationTask.Id) {
			
            $RunningTasks[ $VMCreationTask.Id ]  = $NewVmName
			Log-Message -Type "INFO" -Message "Creation of VM $NewVmName in progress"		
			$vm.TASK_OBJ = $VMCreationTask
			$vm.TASK_ID  = $VMCreationTask.Id 
			$vm.TASK_STATUS = "Running"
			$vm.PERCENT_COMPLETE= -1
			$vm.ERROR_MESSAGE = "VM Creation In Progress"
		} else {				
    	    Log-Message -Type "INFO" -Message "Creation of VM $NewVmName Failed"
    	    $vm.TASK_OBJ = ""
    	    $vm.TASK_ID  = "NULL"
    	    $vm.TASK_STATUS = "ERROR"
    	    $vm.PERCENT_COMPLETE= -1
    	    $vm.ERROR_MESSAGE = "Failed to initiate VM creation."
        }
 	
	}
}

#####################################################################################################
# Function VMLinuxWithoutCustomization : Creates a Linux VM and does not apply customization
# Invokes the command for deploying the VM using the template specified
#####################################################################################################
function VMLinuxWithoutCustomization 
{			
	
	Log-Message -Type "INFO" -Message "Invoking command for creation of VM $NewVmName"
	#Create the VM with the required options
	        
    $LinuxVMCreationTask = New-VM -VMHost $vmhost -Name $NewVmName -Template $template -Datastore $Datastore -DiskStorageFormat $vm.VM_DISKTYPE -RunAsync -Server $vm.VCENTER_IP
        
    if($LinuxVMCreationTask -and $LinuxVMCreationTask.Id) 
    {
		
        $RunningTasks[ $LinuxVMCreationTask.Id ] =  $NewVmName
	
		Log-Message -Type "INFO" -Message "Creation of linux VM $NewVmName in progress"
		
		$vm.TASK_OBJ = $LinuxVMCreationTask
        $vm.TASK_ID  = $LinuxVMCreationTask.Id 
        $vm.TASK_STATUS = "Running"
        $vm.PERCENT_COMPLETE= -1
        $vm.ERROR_MESSAGE = ""
		
	} 
    else 
    {
	    
        Write-Host LinuxVMCreationTask $LinuxVMCreationTask TaskID $LinuxVMCreationTask.Id
	    Write-Host "`r"
		Log-Message -Type "INFO" -Message "Creation of linux VM $NewVmName Failed"
		$vm.TASK_OBJ = ""
		$vm.TASK_ID  = "NULL"
        $vm.TASK_STATUS = "ERROR"
        $vm.PERCENT_COMPLETE= -1
        $vm.ERROR_MESSAGE = "Failed to modify VM."
	
	}
           
}
#####################################################################################################
# Function VMLinux : Creates a Linux VM
# Creates customization Spec based on the OS and WorkGroup/Domain information provided.
# Invokes the command for deploying the VM using the template specified
#####################################################################################################
function VMLinux 
{

	$Timezone = Get_Windows_Time_Zone $vm.TIME_ZONE_WINDOWS

	$Date = Get-Date
	$LinSpecName = $vm.NEW_VM_NAME + "_" +  $Date.Day +  "_" + $Date.Month + "_" + $Date.Year + "_" + $Date.Hour + "_" + $Date.Minute + "_" + $Date.Second + "_" + $Date.Millisecond

    $DNSString = '"'+$vm.DNS_IP_NIC1+'"'
	if($vm.DNS_ALTERNATE_NIC1)
	{
		$DNSString = $DNSString+',"'+$vm.DNS_ALTERNATE_NIC1+'"'
	}

    $LinSpec = New-OSCustomizationSpec -OSType Linux -Domain $vm.DOMAIN_NAME -Name $LinSpecName -Type Persistent -NamingScheme Fixed -NamingPrefix $vm.COMPUTER_NAME -DnsServer $DNSString -DnsSuffix $vm.DOMAIN_NAME -Server $vm.VCENTER_IP

	if($LinSpec) {	
		$vm.OS_CUST_SPEC_NAME = $LinSpecName
		
		Log-Message -Type "INFO" -Message "Creating CustomizationNICMapping for VM $NewVmName"
		
		#Edit default customization spec 
		$firstcustomizationspec = Get-OSCustomizationSpec $LinSpecName -Server $vm.VCENTER_IP | Get-OSCustomizationNicMapping -Server $vm.VCENTER_IP | Set-OSCustomizationNicMapping -IpMode UseStaticIP -IpAddress $vm.IP_ADDRESS_NIC1 -SubnetMask $vm.SUB_NET_MASK_NIC1 -DefaultGateway $vm.DEFAULT_GATEWAY_NIC1 -Server $vm.VCENTER_IP

		Log-Message -Type "INFO" -Message "Invoking command for modifying VM $NewVmName with WinSpec= $LinSpec"
		  
        Log-Message -Type "INFO" -Message "Template name = $template, Datastore name = $Datastore"
            
		$VMCreationTask = New-VM -VMHost $vmhost -Name $NewVmName -Template $template -OSCustomizationSpec $LinSpec -Datastore $Datastore -DiskStorageFormat $vm.VM_DISKTYPE -RunAsync -Server $vm.VCENTER_IP
		
        if($VMCreationTask -and $VMCreationTask.Id) 
        {
			
            $RunningTasks[ $VMCreationTask.Id ]  = $NewVmName

			Log-Message -Type "INFO" -Message "Creation of VM $NewVmName in progress"
			$vm.TASK_OBJ = $VMCreationTask
			$vm.TASK_ID  = $VMCreationTask.Id 
			$vm.TASK_STATUS = "Running"
			$vm.PERCENT_COMPLETE= -1
			$vm.ERROR_MESSAGE = "VM Creation In Progress"
		} 
        else 
        {				

    	    Log-Message -Type "INFO" -Message "Creation of VM $NewVmName Failed"
    	    $vm.TASK_OBJ = ""
    	    $vm.TASK_ID  = "NULL"
    	    $vm.TASK_STATUS = "ERROR"
    	    $vm.PERCENT_COMPLETE= -1
    	    $vm.ERROR_MESSAGE = "Failed to initiate VM creation."
        }
 	
	}
        
}

#####################################################################################################
# Function GetTaskSnapShot : Gets the status of VM Creation tasks.
# This function should be called after issuing the New-VM command for a VM
#####################################################################################################
Function GetTaskSnapShot
{
    $runningTasksCount = $RunningTasks.Count	
	if($runningTasksCount -gt 0)
	{	
		$a = Get-Date
		$Date_Time = "" + $a.Day  + "/" + $a.Month + "/" + $a.Year + " " + $a.Hour + ":" + $a.Minute + ":" + $a.Second
		
		Write-Host "`r`n"	
		Write-Host ******************** $Date_Time  Refreshing Task Status**************** -foregroundcolor cyan
		Log-Message -Type "INFO" -Message "Running task count = $runningTasksCount"
		
		foreach ($vm in $Global_Vm_array)
		{
			if(($vm.CREATEVM -like "YES") -and ($vm.TASK_OBJ -ne "NULL") -and ($vm.OPERATION -eq [DBNull]::Value))
			{
				if($vm.TASK_STATUS -eq "Running")
				{				
					$tsk = Get-View -Id $vm.TASK_ID -Server $vm.VCENTER_IP
					if($tsk)
					{

						if($tsk.Info.State -eq "Error")
						{						
							$RunningTasks.Remove($vm.TASK_ID)
						
							$vm.TASK_STATUS = "Error"
							$vm.ERROR_MESSAGE = $tsk.Info.Error.LocalizedMessage
							
							Write-Host "`r"				
							Write-Host Creation of VM: $vm.NEW_VM_NAME resulted in an error -foregroundcolor Red
							Write-Host Error description: $vm.ERROR_MESSAGE -foregroundcolor Red
						}
						elseif($tsk.Info.State -eq "Success")
						{						
							$RunningTasks.Remove($vm.TASK_ID)
						
							$vm.TASK_STATUS = "Success"
							$vm.ERROR_MESSAGE = "No Error"
							
							Write-Host "`r"		
							Write-Host Creation of VM: $vm.NEW_VM_NAME completed successfully -foregroundcolor Green	
						}
						elseif($tsk.Info.State -eq "Running")
						{
							$vm.TASK_STATUS = "Running"
							$vm.ERROR_MESSAGE = "No Error"
							
							if($tsk.Info.Progress)
							{
								Write-Host "`r"
								Write-Host Creation of VM: $vm.NEW_VM_NAME in progress Task Id is: ($vm.TASK_ID) Status: $tsk.Info.Progress Percent Complete -foregroundcolor yellow
								$tsk.Info.Progress = $tsk.Info.Progress
							}
							else
							{		
								Write-Host "`r"
								Write-Host Creation of VM: $vm.NEW_VM_NAME in progress Task Id is: ($vm.TASK_ID) Status: 0 Percent Complete -foregroundcolor yellow
								$tsk.Info.Progress = 0
							}					
						}
						elseif($tsk.Info.State -eq "Queued")
						{
							Write-Host "`r"
							Write-Host Creation of VM: $vm.NEW_VM_NAME is queued Task Id is: ($vm.TASK_ID) -foregroundcolor yellow				
						}
					}
					else
					{	
						$vm.TASK_STATUS = "ERROR"
						$RunningTasks.Remove($vm.TASK_ID)
						Write-Host "`r"
						Write-Host Unable to get VM creation status of $vm.NEW_VM_NAME Task Id : ($vm.TASK_ID) -foregroundcolor red						
						Write-Host Use the VMWare vsphere client to monitor the status of the task
						Write-Host "`r"
						$vm.ERROR_MESSAGE = "VM creation was initiated but unable to retrieve the current status. Use the VMWare vsphere client to monitor the status of the task."
					}
				}
				else
				{
					if($vm.TASK_STATUS -eq "Error")
					{						
						Write-Host "`r"				
						Write-Host Creation of VM: $vm.NEW_VM_NAME resulted in an error -foregroundcolor Red
						Write-Host Error description: $vm.ERROR_MESSAGE
					}
					elseif($vm.TASK_STATUS -eq "Success")
					{
						Write-Host "`r"		
						Write-Host Creation of VM: $vm.NEW_VM_NAME completed successfully -foregroundcolor Green		
					}
				}
			}
		}
		
		Write-Host "`r"
		Write-Host ******************************************************************** -foregroundcolor cyan
		Write-Host "`r`n"
	}
}

#####################################################################################################
# Function Monitor_Task : Monitors the status of VM creation by polling every 30 seconds
# This function should be called after issuing the New-VM command for all the VMs
#####################################################################################################
Function Monitor_Task 
{
    $runningTasksCount = $RunningTasks.Count

	Log-Message -Type "INFO" -Message "Task status will be refreshed every 30 seconds"
    Log-Message -Type "INFO" -Message "Running task count = $runningTasksCount"
    while($runningTasksCount -gt 0) {	
		$a = Get-Date
		$Date_Time = "" + $a.Day  + "/" + $a.Month + "/" + $a.Year + " " + $a.Hour + ":" + $a.Minute + ":" + $a.Second 
		
		Write-Host "`r"
		Write-Host ********************** $Date_Time Refreshing Task status ****************************** -foregroundcolor cyan 
		
		foreach ($vm in $Global_Vm_array) 
        {
			if(($vm.CREATEVM -like "YES") -and ($vm.TASK_OBJ -ne "NULL")) 
            {	
				if($vm.TASK_STATUS -eq "Running")
                {					
					$tsk = Get-View -Id $vm.TASK_ID -Server $vm.VCENTER_IP
										
					if($tsk) 
                    {	
                    
                    
                    
                    
                    				
						if($tsk.Info.State -eq "Error") {						
							$RunningTasks.Remove($vm.TASK_ID)                    
												
							$vm.TASK_STATUS = "Error"
							$Err = $tsk.Info.Error.LocalizedMessage
							$vm.ERROR_MESSAGE = $Err
							
							Write-Host "`r"				
							Write-Host Creation of VM: $vm.NEW_VM_NAME resulted in an error -foregroundcolor Red
							Write-Host Error description $Err -foregroundcolor Red
						} 
                        elseif($tsk.Info.State -eq "Success") 
                        {
							$RunningTasks.Remove($vm.TASK_ID)                    
						
							$vm.TASK_STATUS = "Success"
							$vm.ERROR_MESSAGE = "No Error"
							Write-Host "`r"		
							Write-Host Creation of VM: $vm.NEW_VM_NAME completed successfully -foregroundcolor Green		
						} 
                        elseif($tsk.Info.State -eq "Running")	
                        {
							$vm.TASK_STATUS = "Running"
							$vm.ERROR_MESSAGE = "No Error"
							
							if($tsk.Info.Progress) 
                            {
								Write-Host "`r"
								Write-Host Creation of VM: $vm.NEW_VM_NAME in progress Task Id is: ($vm.TASK_ID) Status: $tsk.Info.Progress Percent Complete -foregroundcolor yellow
								$vm.PERCENT_COMPLETE = $tsk.Info.Progress
							} 
                            else 
                            {					
								Write-Host "`r"
								Write-Host Creation of VM: $vm.NEW_VM_NAME in progress Task Id is: ($vm.TASK_ID) Status: 0 Percent Complete -foregroundcolor yellow
								$tsk.Info.Progress = 0
							}	
						} 
                        elseif($tsk.Info.State -eq "Queued") 
                        {
							$vm.TASK_STATUS = "Running"
							Write-Host "`r"
							Write-Host Creation of VM: $vm.NEW_VM_NAME is queued Task Id is: ($vm.TASK_ID) -foregroundcolor yellow				
						}
					} #if($tsk)					
					else 
{	
						$vm.TASK_STATUS = "ERROR"
						$RunningTasks.Remove($vm.TASK_ID)
						Write-Host "`r"
						Write-Host Unable to get VM creation status of $vm.NEW_VM_NAME Task Id : ($vm.TASK_ID) -foregroundcolor red						
						Write-Host Use the VMWare vsphere client to monitor the status of the task
						$vm.ERROR_MESSAGE = "VM creation was initiated but unable to retrieve the current status. Use the VMWare vsphere client to monitor the status of the task."
						Write-Host "`r"
					}					
				} else {
					if($vm.TASK_STATUS -eq "Error")	{						
						Write-Host "`r"				
						Write-Host Creation of VM: $vm.NEW_VM_NAME resulted in an error -foregroundcolor Red
						Write-Host Error description: $vm.ERROR_MESSAGE -foregroundcolor Red
					} elseif($vm.TASK_STATUS -eq "Success")	{
						Write-Host "`r"		
						Write-Host Creation of VM: $vm.NEW_VM_NAME completed successfully -foregroundcolor Green	
					}				
				}
			}
		}
		
        $runningTasksCount = $RunningTasks.Count

	    Write-Host "`r"
	    Write-Host ************************************************************************************ -foregroundcolor cyan
	    Write-Host "`r`n"
	
	    if($runningTasksCount -eq 0) {
		    break
	    }
    
	    Start-Sleep -Seconds 30
	
    } #while loop
}


#####################################################################################################
# Function DeployVirtualMachines : Iterates through each of the VMs selected for deploying.
# Invokes CreateVirtualMachine function to create the VM.
# Invokes Monitor_task function after all VMs creation is initiated
# Invokes DeleteOSCustomizationSpec for deleting the customization spec from vCenter
#####################################################################################################
Function DeployVirtualMachines ([REF]$Success, [REF]$ErrorMsg) {

	foreach ($vm in $Global_Vm_array) {

		if ($vm.CREATEVM -like "YES") {			
			#Function call to create the VM
			
			CreateVirtualMachine $vm.NEW_VM_NAME
		}
            
	}

    $runningTasksCount = $RunningTasks.Count
	if($runningTasksCount -gt 0) {	
		Write-Host "`r"
		Write-Host VM deployment in Progress Please wait... -foregroundcolor cyan

		#This calls the function for monitoring the status of the VM creation
		Monitor_Task   

		Write-Host "`r`n"
		Write-Host VM deployment is complete. -foregroundcolor cyan
		Write-Host "`r`n"
		
		foreach ($vm in $Global_Vm_array) {
			if ($vm.CREATEVM -like "YES") {
                if ($vm.USE_RESERVATIONS -like "None") {
                    Log-Message -Type "INFO" -Message "Removing any CPU and Memory reservations on: $($vm.NEW_VM_NAME)"
                    $removereservation = Get-VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | Get-VMResourceConfiguration -Server $vm.VCENTER_IP |  Set-VMResourceConfiguration -MemReservationMB 0 -CpuReservationMhz 0
                } elseif ($vm.USE_RESERVATIONS -like "MEM-ONLY") {
                    Log-Message -Type "INFO" -Message "Removing any CPU reservations on: $($vm.NEW_VM_NAME)"
                    $removereservation = Get-VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | Get-VMResourceConfiguration -Server $vm.VCENTER_IP |  Set-VMResourceConfiguration -CpuReservationMhz 0
                }

                if ($vm.GOLDEN_TEMPLATE_NAME -match "GT-Win") {
                    if ($vm.DISK_2_SIZE -eq "" -or  $vm.DISK_2_SIZE -eq "0") {
                        Log-Message -Type "INFO" -Message "Disk 2 Size for Windows Template is not set or equal to 0.  Removing second disk on: $($vm.NEW_VM_NAME)"
                        Get-HardDisk -vm $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | where {$_.Name -eq "Hard Disk 2"} | Remove-HardDisk -Confirm:$false
                    }
                }

				Log-Message -Type "INFO" -Message "Setting primary network adapter of VM: $($vm.NEW_VM_NAME) to $($vm.VM_NETWORK)"

                $visiblenetworkadapter = get-virtualportgroup -vmhost $vm.DEST_HOST_IP -name $vm.VM_NETWORK -Server $vm.VCENTER_IP

				if ($visiblenetworkadapter) {
					$setvisibleadapter = Get-VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | Get-NetworkAdapter -Server $vm.VCENTER_IP | Where-Object { $_.Name -like "*1"} | Set-NetworkAdapter -PortGroup $visiblenetworkadapter -Server $vm.VCENTER_IP -Confirm:$false
				} else {
					Log-Message -Type "INFO" -Message "The network name doesn't appear to be a distributed switch.  Searching to see if it's a standard switch"
					$visiblenetworkadapter = get-virtualportgroup -vmhost $vm.DEST_HOST_IP -standard -name $vm.VM_NETWORK -Server $vm.VCENTER_IP 
					if ($visiblenetworkadapter) {
						$setvisibleadapter = Get-VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | Get-NetworkAdapter -Server $vm.VCENTER_IP | Where-Object { $_.Name -like "*1"} | Set-NetworkAdapter -PortGroup $visiblenetworkadapter -Server $vm.VCENTER_IP -Confirm:$false
					} else {
						Log-Message -Type "ERROR" -Message "A standard switch couldn't be found either.  Is the VM_NETWORK set properly?"
					}
				}

                if ($vm.NIC_NUM -eq "2") {
					Log-Message -Type "INFO" -Message "Setting secondary network adapter of VM $($vm.NEW_VM_NAME) to $($vm.PRIV_NETWORK)"
				
					$privatenetworkadapter = get-virtualportgroup -vmhost $vm.DEST_HOST_IP -name $vm.PRIV_NETWORK -Server $vm.VCENTER_IP
					if ($privatenetworkadapter) {
						$setprivateadapter = Get-VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | Get-NetworkAdapter -Server $vm.VCENTER_IP | Where-Object { $_.Name -like "*2"} | Set-NetworkAdapter -PortGroup $privatenetworkadapter -Server $vm.VCENTER_IP -Confirm:$false
					} else {
						Write-Host "The network name doesn't appear to be a distributed switch.  Searching to see if it's a standard switch"
						$privatenetworkadapter = get-virtualportgroup -vmhost $vm.DEST_HOST_IP -standard -name $vm.PRIV_NETWORK
						if ($privatenetworkadapter) {
							$setprivateadapter = Get-VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | Get-NetworkAdapter -Server $vm.VCENTER_IP | Where-Object { $_.Name -like "*2"} | Set-NetworkAdapter -PortGroup $privatenetworkadapter -Server $vm.VCENTER_IP -Confirm:$false
						} else {
							Log-Message -Type "ERROR" -Message "A standard switch couldn't be found either.  Is the PRIV_NETWORK set properly?"
						}
					}
				}

                ###Adjust VM Specifications Section
				
				if ($vm.CPU_COUNT.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting CPU count on $($vm.NEW_VM_NAME) to $($vm.CPU_COUNT)"
					$setcpu = get-VM -name $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | set-VM -NumCpu $vm.CPU_COUNT -Server $vm.VCENTER_IP -Confirm:$false
				}
					
				if ($vm.MEMORY.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting Memory on $($vm.NEW_VM_NAME) to $($vm.MEMORY)"
					$setmemory = get-VM -name $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | set-VM -MemoryGB $vm.MEMORY -Server $vm.VCENTER_IP -Confirm:$false
				}
					
				if ($vm.DISK_1_SIZE.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting Disk1 Size on $($vm.NEW_VM_NAME) to $($vm.DISK_1_SIZE)"
					$disk1size = Get-HardDisk -vm $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | where {$_.Name -eq "Hard Disk 1"} | Set-HardDisk -CapacityGB $vm.DISK_1_SIZE -Server $vm.VCENTER_IP -Confirm:$false
				}
					
				if ($vm.DISK_2_SIZE.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting Disk2 Size on $($vm.NEW_VM_NAME) to $($vm.DISK_2_SIZE)"
					$disk2size = Get-HardDisk -vm $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | where {$_.Name -eq "Hard Disk 2"} | Set-HardDisk -CapacityGB $vm.DISK_2_SIZE -Server $vm.VCENTER_IP -Confirm:$false
				}

                if ($vm.DISK_3_SIZE.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting Disk3 Size on $($vm.NEW_VM_NAME) to $($vm.DISK_3_SIZE)"
					$disk3size = Get-HardDisk -vm $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | where {$_.Name -eq "Hard Disk 3"} | Set-HardDisk -CapacityGB $vm.DISK_3_SIZE -Server $vm.VCENTER_IP -Confirm:$false
				}

                if ($vm.DISK_4_SIZE.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting Disk4 Size on $($vm.NEW_VM_NAME) to $($vm.DISK_4_SIZE)"
					$disk4size = Get-HardDisk -vm $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | where {$_.Name -eq "Hard Disk 4"} | Set-HardDisk -CapacityGB $vm.DISK_4_SIZE -Server $vm.VCENTER_IP -Confirm:$false
				}

                if ($vm.DISK_5_SIZE.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting Disk5 Size on $($vm.NEW_VM_NAME) to $($vm.DISK_5_SIZE)"
					$disk5size = Get-HardDisk -vm $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | where {$_.Name -eq "Hard Disk 5"} | Set-HardDisk -CapacityGB $vm.DISK_5_SIZE -Server $vm.VCENTER_IP -Confirm:$false
				}

                if ($vm.DISK_6_SIZE.length -gt 0) {
					Log-Message -Type "INFO" -Message "Setting Disk6 Size on $($vm.NEW_VM_NAME) to $($vm.DISK_6_SIZE)"
					$disk6size = Get-HardDisk -vm $vm.NEW_VM_NAME -Server $vm.VCENTER_IP | where {$_.Name -eq "Hard Disk 6"} | Set-HardDisk -CapacityGB $vm.DISK_6_SIZE -Server $vm.VCENTER_IP -Confirm:$false
				}

                ###End of Adjust VM Specifications Section

			}
		}
		
	}
	
	#Once all the VMs have been deployed, delete the OS Customization Spec.
	DeleteOSCustomizationSpec

	$Success.Value = $true
	$ErrorMsg.Value = "VMs Deployed Successful"
}

#####################################################################################################
# Function DeleteOSCustomizationSpec : Removes the OS customization spec from the vCenter
#####################################################################################################
Function DeleteOSCustomizationSpec
{
	Log-Message -Type "INFO" -Message "Deleting OSCustomization files from the vCenter"
		
	foreach ($vm in $Global_Vm_array)
	{
		if(($vm.CREATEVM -like "YES") -and ($vm.OS_TYPE -match "Windows") -and ($vm.TASK_STATUS -eq "Success")) {
		
        	Log-Message -Type "INFO" -Message "Deleting the OSCustomization Spec: $($vm.OS_CUST_SPEC_NAME) from vCenter, please wait.."
			Remove-OSCustomizationSpec -OSCustomizationSpec $vm.OS_CUST_SPEC_NAME -Server $vm.VCENTER_IP -Confirm:$false
			Log-Message -Type "INFO" -Message "OSCustomization spec $($vm.OS_CUST_SPEC_NAME) deleted successfully"
		
        } elseif (($vm.CREATEVM -like "YES") -and ($vm.OS_TYPE -match "CentOS") -and ($vm.TASK_STATUS -eq "Success")) {

            Log-Message -Type "INFO" -Message "Deleting the OSCustomization Spec: $($vm.OS_CUST_SPEC_NAME) from vCenter, please wait.."
			Remove-OSCustomizationSpec -OSCustomizationSpec $vm.OS_CUST_SPEC_NAME -Server $vm.VCENTER_IP -Confirm:$false
			Log-Message -Type "INFO" -Message "OSCustomization spec $($vm.OS_CUST_SPEC_NAME) deleted successfully"

        }
	}

	$Success.Value = $true
	$ErrorMsg.Value = "Successfully deleted the OSCustomization files from the vCenter"
	
}

#####################################################################################################
# Function RunPSOnWindowsVM : Invokes powershell commands on VMs
#####################################################################################################  

Function RunPSOnWindowsVM ($script,$vmname,$credential,$retries,$vcenter) {

    $origRetries = $retries
    Log-Message -Type "INFO" -Message "Invoking script on $vmname"
    while (-Not $invokevmscriptcomplete)
    {
        try
        {
            $invokevmscript = Invoke-VMScript -ScriptText $script -VM $vmname -GuestCredential $credential -Server $vcenter -ErrorAction Stop
            Log-Message -Type "INFO" -Message "Invoke script on $vmname = Success"
            $invokevmscriptcomplete = 1
        }
        catch 
        {
            if ($_.Exception.Message -match "Failed to authenticate") {
                Log-Message -Type "WARNING" -Message "Status Code 01. Failed to authenticate. Retries remaining = $retries"
            }
            elseif ($_.Exception.Message -match "VMware Tools")
            {
                Log-Message -Type "WARNING" -Message "Status Code 02. VMware Tools. Retries remaining = $retries"
            }
            else
            {
                Log-Message -Type "ERROR" -Message "$_.Exception.Message"
                Log-Message -Type "ERROR" -Message "An unexpected error was encountered. Retries remaining = $retries"
            }
        
            if ($retries -eq 0)
            {
                Write-Host "$script could not be invoked on $vm" -ForegroundColor Yellow -BackgroundColor Red
                Write-Host "To try again, press 'Enter'" -ForegroundColor Yellow -BackgroundColor Red
                Write-Host "To quit, input something else" -ForegroundColor Yellow -BackgroundColor Red
                $ta = Read-Host

                if ($ta -ne "")
                {
                    $invokevmscriptcomplete = 1
                }
                else
                {
                    $retries = $origRetries
                }
            }
            else
            {
                Log-Message -Type "INFO" -Message "Starting sleep for 120s while waiting for $vmname"
                Start-Sleep -s 120
                $retries = $retries - 1
            }
        }
    }

    return $invokevmscript.ScriptOutput
}

#####################################################################################################
# Function PowerOnVM : Executes all VM tasks from the time they are ready to be powered on
#####################################################################################################  

Function PowerOnVM 
{
	Log-Message -Type "INFO" -Message "Auto Powering on Virtual Machines and executing scripts"

    if (-not $disablenetscaler) {
        try 
        {
            $nssession1 = Connect-NSAppliance -NSName $BIHash.NETSCALERHOST1 -NSUserName $BIHash.NETSCALERUSERNAME -NSPassword $BIHash.NETSCALERPASSWORD
            Log-Message "INFO" "Connection to $($BIHash.NETSCALERHOST1) (NetScaler Host 1) was successful"
        
        }
        catch 
        {
            Log-Message "ERROR" "Could not connect to $($BIHash.NETSCALERHOST1) (NetScaler Host 1). Not performing any NetScaler configuration"
            $disablenetscaler = $true
        }

        try 
        {
            $nssession2 = Connect-NSAppliance -NSName $BIHash.NETSCALERHOST2 -NSUserName $BIHash.NETSCALERUSERNAME -NSPassword $BIHash.NETSCALERPASSWORD
            Log-Message "INFO" "Connection to $($BIHash.NETSCALERHOST2) (NetScaler Host 2) was successful"

        } 
        catch 
        {
            Log-Message "ERROR" "Could not connect to $($BIHash.NETSCALERHOST2) (NetScaler Host 2). Not performing any NetScaler configuration"
            $disablenetscaler = $true
        }
    }

    if (-not $disablenetscaler) 
    {

        Log-Message "INFO" "Creating Public DNS Entries"

        foreach ($vm in $Global_Vm_array) {

            if (($vm.CREATEVM -like "YES") -and ($vm.TASK_STATUS -eq "Success")) 
{
                $fqdn = $vm.NEW_VM_NAME + "." + $vm.DOMAIN_NAME
                $ipaddrnic1 = $vm.IP_ADDRESS_NIC1
                Log-Message "INFO" "Creating Public DNS Entry for $fqdn with IP address $ipaddrnic1"

                try 
                {
                    #nitroconfigurationfunctions.psm1
                    New-DNSAddRec -NSSession $nssession1 -Hostname $fqdn -IPAddress $ipaddrnic1
                } 
                catch 
                {
                    Log-Message "WARNING" "$_.Exception.Message"
                    Log-Message "WARNING" "This error occured on $($BIHash.NETSCALERHOST1) - 304 error likely means that the record already exists"
                }

                try 
                {
                    #nitroconfigurationfunctions.psm1
                    New-DNSAddRec -NSSession $nssession2 -Hostname $fqdn -IPAddress $ipaddrnic1
                } 
                catch 
                {
                    Log-Message "WARNING" "$_.Exception.Message"
                    Log-Message "WARNING" "This error occured on $($BIHash.NETSCALERHOST2) - 304 error likely means that the record already exists"
                }

                $invokedDNS = $null
                try
                {
                    $dnsscript = "$dns = resolve-dnsname $ipaddrnic1$;"
                    $invokedDNS = Invoke-VMScript -ScriptText $dnsscript -VM $vm.new_vm_name -GuestCredential $credential -Server $vcenter -ErrorAction Stop
                }
                catch
                {
                    Log-Message "WARNING" "DNS check failed. This may be caused by a script error"
                }
                
                if ($invokeDNS -ne $null)
                {
                    Log-Message "INFO" "DNS check for $ipaddrnic1 succeeded"
                }

            }

        }

        Log-Message "INFO" "Saving Load Balancer Configuration and Disconnecting Session on $($BIHash.NETSCALERHOST1)"
        Save-NSConfig -NSSession $nssession1
        Disconnect-NSAppliance $nssession1

        Log-Message "INFO" "Saving Load Balancer Configuration and Disconnecting Session on $($BIHash.NETSCALERHOST2)"
        Save-NSConfig -NSSession $nssession2
        Disconnect-NSAppliance $nssession2
    }

    Log-Message "INFO" "Powering on any Windows VMs"
    foreach ($vm in $Global_Vm_array) {
        if (($vm.CREATEVM -like "YES") -and ($vm.AUTO_POWERON -eq "YES") -and ($vm.TASK_STATUS -eq "Success") -and ($vm.OS_TYPE -match "Windows")) {

            Log-Message "INFO" "Powering on $($vm.NEW_VM_NAME)"
            $startvm = Start-VM -VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP
            $poweronwindowsvms = 1

            ###Move VM Section
            try {

                if ($vm.OS_TYPE -match "Windows") {
					$folderToMoveName = "Windows"
				} else {
					$folderToMoveName = "Linux"
				}

                Log-Message "INFO" "Moving VM to $folderToMoveName folder"
                $CustVMFolder = Get-Datacenter -Name $vm.DATA_CENTER -Server $vm.VCENTER_IP | Get-Folder -Name $BIhash.VM_FOLDER -Type VM -Server $vm.VCENTER_IP
                $ServerVMFolder = Get-Folder -Name $folderToMoveName -Location $CustVMFolder -Type VM -NoRecursion -Server $vm.VCENTER_IP -ErrorAction SilentlyContinue
                $MoveVM = Move-VM -VM $vm.NEW_VM_NAME -InventoryLocation $ServerVMFolder #-Server $vm.VCENTER_IP

            } catch {

                Log-Message "ERROR" "Failed to move $($vm.NEW_VM_NAME). It will need to be moved manually from its default location"
            }
            ###End of Move VM Section
        }
    }

    if ($poweronwindowsvms) {
        Log-Message "INFO" "Sleeping for 8 minutes while Windows VMs execute poweron and perform initial customization" 
        ExecuteScriptsSleep "480"
    }
    $domainadminpasswordsecure = ConvertTo-SecureString -String $BIhash.DOMAINADMINPASSWORD -AsPlainText -Force

    $DomainAdminUser = $BIhash.DOMAINADMINUSERNAME
    $DomainAdminCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainAdminUser, $domainadminpasswordsecure

    $DomainUser = $BIhash.ENVIRONMENTCODE+'\Administrator'
    $DomainCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainUser, $domainadminpasswordsecure

    $DefaultUser = '.\Administrator'
    $DefaultCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DefaultUser, $domainadminpasswordsecure

    foreach ($vm in $Global_Vm_array) {
        
        if (($vm.CREATEVM -like "YES") -and ($vm.AUTO_POWERON -eq "YES") -and ($vm.TASK_STATUS -eq "Success") -and ($vm.VM_TYPE -match "ActiveDirectory_PDC")) {
            
            Log-Message "INFO" "Executing Primary DC"
            Log-Message "INFO" "Will login with $DefaultUser"

            if ($BIhash.TIMEZONE -eq "Etc/UTC") {
                Log-Message "INFO" "Timezone is UTC. Invoking script to set UTC timezone properly"
                $script = '$CurrentTimeZone = [System.TimeZone]::CurrentTimeZone | Select-Object StandardName;if ($CurrentTimeZone -match "{StandardName=GMT Standard Time}") {	tzutil.exe /s "UTC" };'
                RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP
            } else {
                Log-Message "INFO" "Testing Connection..."
                $script = 'Write-Host "Connection Success"'
                RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP
            }

            Log-Message "INFO" "Copying AD PDC files and folders.  This may take a few minutes..."
            Copy-VMGuestFile -Source $FileHash.Setup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying Setup"
            Copy-VMGuestFile -Source $FileHash.NewPassword -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying NewPassword"
            Copy-VMGuestFile -Source $FileHash.ADPrimary -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying AD-Primary"
            Copy-VMGuestFile -Source $FileHash.ADPrimaryFinal -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying AD-Primary-Final"
			Copy-VMGuestFile -Source $FileHash.SSLCerts -Destination "c:\Software\SSLCerts\wildcard.pfx" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying wildcard.pfx"

            Copy-VMGuestFile -Source $FileHash.GPOBackups -Destination "c:\Software\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            $script = 'Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory("c:\Software\GPO Backups.zip", "c:\Software\GPO Backups");Remove-Item -Path "c:\Software\GPO Backups.zip" -Force;'
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "10" $vm.VCENTER_IP
            Log-Message "INFO" "Done copying GPOBackups"

            Copy-VMGuestFile -Source $FileHash.ADMXTemplates -Destination "c:\Software\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            $script = 'Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory("c:\Software\ADMX Templates.zip", "C:\Windows\PolicyDefinitions");Remove-Item -Path "c:\Software\ADMX Templates.zip" -Force;'
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "10" $vm.VCENTER_IP
            Log-Message "INFO" "Done copying ADMX Templates"

            Copy-VMGuestFile -Source $FileHash.GPWMIFilter -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\GPWmiFilter\GPWmiFilter.psm1" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying GPWMIFilter"

            Log-Message "INFO" "Invoking Setup.ps1"
            $script = '&"C:\Software\Setup Scripts\Setup.ps1" -ServerType PDC -DomainName "'+$BIhash.DOMAIN_NAME+'" -CertificatePassword "'+$BIhash.ADFSCERTIFICATEPASSWORD+'" -SafeModePass "'+$BIhash.ADSAFEMODEPASS+'"';
            Log-Message "DEBUG" "$script"
            
            $invokeretries = 10
            $invokecompletion = $false
            while (-Not $invokecompletion) 
            {
                try 
                {
                
                    Invoke-VMScript -ScriptText $script -VM $vm.NEW_VM_NAME -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -ErrorAction Stop
                    Start-Sleep -s 30
                    Log-Message -Type "INFO" -Message "Invoke script on $($vm.NEW_VM_NAME) = Success"
                    $invokecompletion = 1

                } 
                catch 
                {
                
                    if ($_.Exception.Message -match "Failed to authenticate") 
                    {
                        Log-Message -Type "WARNING" -Message "Status Code 01. Failed to authenticate. Retries remaining = $invokeretries"
                    } 
                    elseif ($_.Exception.Message -match "VMware Tools") 
                    {
                        Log-Message -Type "WARNING" -Message "Status Code 02. VMware Tools. Retries remaining = $invokeretries"
                    } 
                    else 
                    {
                        Start-Sleep -s 30
                        Log-Message -Type "INFO" -Message "Invoke script on $($vm.NEW_VM_NAME) = Success"
                        $invokecompletion = 1
                    }

                    if (-Not $invokecompletion) 
                    {
                        if ($invokeretries -eq 0) 
                        {
                            Write-Host "Script has failed $invokeretries times."
                            $rt = Read-Host "Try again? (n to quit)"

                            if ($rt -notlike "n")
                            {
                                $invokeretries = 10
                            }
                            else
                            {
                                $invokecompletion = 1
                            }
                        } 
                        else 
                        {
                            Log-Message -Type "INFO" -Message "Starting sleep for 120s while waiting for $($vm.NEW_VM_NAME)"
                            Start-Sleep -s 120
                            $invokeretries = $invokeretries - 1
                        }
                    }
                }
            }
    
            RestartVM $vm.NEW_VM_NAME $vm.VCENTER_IP
            Log-Message "INFO" "Sleeping for 6 minutes while Domain Controller base installation is completed."
            ExecuteScriptsSleep "360"
            
            if (($BIhash.MTDOMAIN) -and ($BIhash.MTDOMAINDNSSERVERS)) {
            
                $script = '&"C:\Software\Setup Scripts\AD-Primary.ps1" -SystemID "'+$BIhash.SYSTEMID+'" -DomainName "'+$BIhash.DOMAIN_NAME+'" -UserName "'+$BIhash.VCENTERUSERNAME+'" -UserPass "'+$BIhash.VCENTERPASSWORD+'" `
                 -CustName "'+$BIhash.CUSTOMERNAME+'" -DnsNatIP "'+$DNSNatAddressList+'" -KMSHostname "'+$BIhash.KMSHOSTNAME+'" -ManagementDomain "'+$BIhash.MANAGEMENTDOMAIN+'" `
                 -ManagementDomainDNSServers "'+$BIhash.MANAGEMENTDOMAINDNSSERVERS+'" -PublicDomain "'+$BIhash.PUBLICDOMAIN+'" `
                -PublicDomainDNSServers "'+$BIhash.PUBLICDOMAINDNSSERVERS+'" -GeneralGPOName "'+$BIhash.GENERALGPONAME+'" -NTPGPOName "'+$BIhash.NTPGPONAME+'" -SiteGPOPrefix "'+$BIhash.SITEGPOPREFIX+'" `
                -ManagementEnterpriseDomainsGroup "'+$BIhash.MANAGEMENTDOMAINSECURITYGROUP+'" -ManagementDomainPDC "'+$BIhash.MANAGAEMENTDOMAINPDC+'" `
                -ManagementDomainSecurityGroupPath "'+$BIhash.MANAGEMENTDOMAINSECURITYGROUPPATH+'" -ADSites "'+$SitesToAddList+'" -ADFSAccountPass "'+$BIhash.ADFSSVCACCOUNTPASS+'" `
                -MTDomain "'+$BIhash.MTDOMAIN+'" -MTDomainDNSServers "'+$BIhash.MTDOMAINDNSSERVERS+'"';
            
            } else {

                $script = '&"C:\Software\Setup Scripts\AD-Primary.ps1" -SystemID "'+$BIhash.SYSTEMID+'" -DomainName "'+$BIhash.DOMAIN_NAME+'" -UserName "'+$BIhash.VCENTERUSERNAME+'" -UserPass "'+$BIhash.VCENTERPASSWORD+'" `
                 -CustName "'+$BIhash.CUSTOMERNAME+'" -DnsNatIP "'+$DNSNatAddressList+'" -KMSHostname "'+$BIhash.KMSHOSTNAME+'" -ManagementDomain "'+$BIhash.MANAGEMENTDOMAIN+'" `
                 -ManagementDomainDNSServers "'+$BIhash.MANAGEMENTDOMAINDNSSERVERS+'" -PublicDomain "'+$BIhash.PUBLICDOMAIN+'" `
                -PublicDomainDNSServers "'+$BIhash.PUBLICDOMAINDNSSERVERS+'" -GeneralGPOName "'+$BIhash.GENERALGPONAME+'" -NTPGPOName "'+$BIhash.NTPGPONAME+'" -SiteGPOPrefix "'+$BIhash.SITEGPOPREFIX+'" `
                -ManagementEnterpriseDomainsGroup "'+$BIhash.MANAGEMENTDOMAINSECURITYGROUP+'" -ManagementDomainPDC "'+$BIhash.MANAGAEMENTDOMAINPDC+'" `
                -ManagementDomainSecurityGroupPath "'+$BIhash.MANAGEMENTDOMAINSECURITYGROUPPATH+'" -ADSites "'+$SitesToAddList+'" -ADFSAccountPass "'+$BIhash.ADFSSVCACCOUNTPASS+'"';

            }
            Log-Message "DEBUG" "$script"

            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainCredential "10" $vm.VCENTER_IP

            RestartVM $vm.NEW_VM_NAME $vm.VCENTER_IP

            Log-Message "INFO" "Reading passwords file"
            $script = 'Get-Content "C:\Software\Setup Scripts\passwords.txt"' 
            $passwordsresult = RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainCredential "10" $vm.VCENTER_IP

            Log-Message "INFO" "Executing AD-Primary-Final"
            $script = '&"C:\Software\Setup Scripts\AD-Primary-Final.ps1" -ServerIP "'+$vm.IP_ADDRESS_NIC1+'" -PrimaryDNSIP "'+$vm.DNS_IP_NIC1+'" -SecondaryDNSIP "'+$vm.DNS_ALTERNATE_NIC1+'"'
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainCredential "10" $vm.VCENTER_IP

            Log-Message "INFO" "Finished executing all PDC scripts"
            

        } elseif (($vm.CREATEVM -like "YES") -and ($vm.AUTO_POWERON -eq "YES") -and ($vm.TASK_STATUS -eq "Success") -and ($vm.VM_TYPE -match "ActiveDirectory")) {

            Log-Message "INFO" "Executing Secondary DC"

            if ($BIhash.TIMEZONE -eq "Etc/UTC") {
                Log-Message "INFO" "Timezone is UTC. Invoking script to set UTC timezone properly"
                $script = '$CurrentTimeZone = [System.TimeZone]::CurrentTimeZone | Select-Object StandardName;if ($CurrentTimeZone -match "{StandardName=GMT Standard Time}") {	tzutil.exe /s "UTC" };'
                RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP
            } else {
                Log-Message "INFO" "Testing Connection..."
                $script = 'Write-Host "Connection Success"'
                RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP
            }

            Log-Message "INFO" "Copying AD DC files and folders.  This may take a few minutes..."

            Copy-VMGuestFile -Source $FileHash.Setup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying Setup"
            Copy-VMGuestFile -Source $FileHash.NewPassword -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying NewPassword"
            Copy-VMGuestFile -Source $FileHash.ADSecondary -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying AD-Secondary"
            Copy-VMGuestFile -Source $FileHash.SSLCerts -Destination "c:\Software\SSLCerts\wildcard.pfx" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying wildcard.pfx"

            Copy-VMGuestFile -Source $FileHash.ADMXTemplates -Destination "c:\Software\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            $script = 'Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory("c:\Software\ADMX Templates.zip", "C:\Windows\PolicyDefinitions");Remove-Item -Path "c:\Software\ADMX Templates.zip" -Force;'
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "10" $vm.VCENTER_IP
            Log-Message "INFO" "Done copying ADMX Templates"
 
            Copy-VMGuestFile -Source $FileHash.GPWMIFilter -Destination "C:\Windows\System32\WindowsPowerShell\v1.0\Modules\GPWmiFilter\GPWmiFilter.psm1" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying GPWMIFilter"
            
            Log-Message "INFO" "Invoking Setup"
            $script = '&"C:\Software\Setup Scripts\Setup.ps1" -ServerType DC -DomainName "'+$BIhash.DOMAIN_NAME+'" -CertificatePassword "'+$BIhash.ADFSCERTIFICATEPASSWORD+'" -DomainUserName "'+$BIhash.DOMAINADMINUSERNAME+'" -DomainUserPass "'+$BIhash.DOMAINADMINPASSWORD+'" -SafeModePass "'+$BIhash.ADSAFEMODEPASS+'"';
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "10" $vm.VCENTER_IP

            RestartVM $vm.NEW_VM_NAME $vm.VCENTER_IP
            
            if (-not $passwordsresult) {
                Log-Message "INFO" "Reading passwords file"
                $script = 'Get-Content "C:\Software\Setup Scripts\passwords.txt"' 
                $passwordsresult = RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "10" $vm.VCENTER_IP
            }

            ###Update Primary Domain Controller DNS
            if ($vm.SERVERNUM -eq "02" -and $vm.CLUSTERNUM -eq "01") {

                Log-Message "INFO" "Secondary DC has been deployed. Updating DNS on Primary DC for the following:  DNS1 = $($vm.DNS_IP_NIC1) DNS2 = $($vm.DNS_ALTERNATE_NIC1)"
                
                $script = '$subnetmasks = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object {$_.ipaddress -like '+$vm._DNS_ALTERNATE_NIC1+'}; '
                $script = $script + 'Foreach ($subnetmask in $subnetmasks) { $interfaceindex = $subnetmask.InterfaceIndex }; '
                $script = $script + '$dnsservers = Set-DnsClientServerAddress -InterfaceIndex $interfaceindex -ServerAddresses ("'+$vm.DNS_IP_NIC1+'","'+$vm.DNS_ALTERNATE_NIC1+'"); '
                Log-Message "DEBUG" $script
                RunPSOnWindowsVM $script $pdcname $DomainAdminCredential "10" $pdcvcenter
            }
            
            ###Run final Secondary Domain Controller Execution Scripts
            Log-Message "INFO" "Invoking AD-Secondary"
            $script = '&"C:\Software\Setup Scripts\AD-Secondary.ps1" -DomainUserName "'+$BIhash.DOMAINADMINUSERNAME+'" -DomainUserPass "'+$BIhash.DOMAINADMINPASSWORD+'"';
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "10" $vm.VCENTER_IP

        }
    }

    foreach ($vm in $Global_Vm_array)
	{
        $DefaultUser = $vm.NEW_VM_NAME+'\Administrator'
        $DefaultCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DefaultUser, $domainadminpasswordsecure

        if (($vm.CREATEVM -like "YES") -and ($vm.NIC_NUM -eq "2") -and ($vm.TASK_STATUS -eq "Success")) {
            $privatehostname = $vm.NEW_VM_NAME + 'p'
            Log-Message "INFO" "Creating DNS entry for Private Host $privatehostname with IP $($vm.IP_ADDRESS_NIC2)"
            
            $script = 'Add-DNSServerResourceRecordA -Name '+ $privatehostname + ' -ZoneName ' + $vm.DOMAIN_NAME + ' -IPv4Address ' + $vm.IP_ADDRESS_NIC2 + ' -AllowUpdateAny'
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $pdcname $DomainAdminCredential "10" $pdcvcenter
        }

        if (($vm.CREATEVM -like "YES") -and (($vm.OS_TYPE -match "Linux") -or ($vm.OS_TYPE -match "CentOS")) -and ($vm.TASK_STATUS -eq "Success")) {
            Log-Message "INFO" "Creating DNS entry for Linux server $($vm.NEW_VM_NAME) with IP $($vm.IP_ADDRESS_NIC1)"
            
            $script = 'Add-DNSServerResourceRecordA -Name '+ $vm.NEW_VM_NAME + ' -ZoneName ' + $vm.DOMAIN_NAME + ' -IPv4Address ' + $vm.IP_ADDRESS_NIC1 + ' -AllowUpdateAny -CreatePtr'
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $pdcname $DomainAdminCredential "10" $pdcvcenter

			if (($vm.AUTO_POWERON -eq "YES") -and (($vm.SERVERNUM -match "01") -or ($vm.VM_TYPE -match "VVB_"))) {
                Log-Message "INFO" "Powering on $($vm.NEW_VM_NAME)"
                $startvm = Start-VM -VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP
                $sleepforpubs = 1

                ###Move VM Section
                try {

                    if ($vm.OS_TYPE -match "Windows") {
					    $folderToMoveName = "Windows"
				    } else {
					    $folderToMoveName = "Linux"
				    }

                    Log-Message "INFO" "Moving VM to $folderToMoveName folder"
                    $CustVMFolder = Get-Datacenter -Name $vm.DATA_CENTER -Server $vm.VCENTER_IP | Get-Folder -Name $BIhash.VM_FOLDER -Type VM -Server $vm.VCENTER_IP
                    $ServerVMFolder = Get-Folder -Name $folderToMoveName -Location $CustVMFolder -Type VM -NoRecursion -Server $vm.VCENTER_IP -ErrorAction SilentlyContinue
                    $MoveVM = Move-VM -VM $vm.NEW_VM_NAME -InventoryLocation $ServerVMFolder #-Server $vm.VCENTER_IP

                } catch {

                    Log-Message "ERROR" "Failed to move $($vm.NEW_VM_NAME). It will need to be moved manually from its default location"
                }
                ###End of Move VM Section
            }
            
        }

        if (($vm.CREATEVM -like "YES") -and ($vm.OS_TYPE -match "CentOS") -and ($vm.TASK_STATUS -eq "Success")) {
            Log-Message "INFO" "Creating DNS entry for CentOS server $($vm.NEW_VM_NAME) with IP $($vm.IP_ADDRESS_NIC1)"
            $script = 'Add-DNSServerResourceRecordA -Name '+ $vm.NEW_VM_NAME + ' -ZoneName ' + $vm.DOMAIN_NAME + ' -IPv4Address ' + $vm.IP_ADDRESS_NIC1 + ' -AllowUpdateAny -CreatePtr'
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $pdcname $DomainAdminCredential "10" $pdcvcenter

            if ($vm.AUTO_POWERON -eq "YES") {
                Log-Message "INFO" "Powering on $($vm.NEW_VM_NAME)"
                $startvm = Start-VM -VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP

                ###Move VM Section
                try {

                    if ($vm.OS_TYPE -match "Windows") {
				        $folderToMoveName = "Windows"
			        } else {
				        $folderToMoveName = "Linux"
			        }

                    Log-Message "INFO" "Moving VM to $folderToMoveName folder"
                    $CustVMFolder = Get-Datacenter -Name $vm.DATA_CENTER -Server $vm.VCENTER_IP | Get-Folder -Name $BIhash.VM_FOLDER -Type VM -Server $vm.VCENTER_IP
                    $ServerVMFolder = Get-Folder -Name $folderToMoveName -Location $CustVMFolder -Type VM -NoRecursion -Server $vm.VCENTER_IP -ErrorAction SilentlyContinue
                    $MoveVM = Move-VM -VM $vm.NEW_VM_NAME -InventoryLocation $ServerVMFolder #-Server $vm.VCENTER_IP

                } catch {

                    Log-Message "ERROR" "Failed to move $($vm.NEW_VM_NAME). It will need to be moved manually from its default location"
                }
                ###End of Move VM Section
            }
            
        }

		if (($vm.CREATEVM -like "YES") -and ($vm.AUTO_POWERON -eq "YES") -and ($vm.TASK_STATUS -eq "Success")) {
            
            if ($vm.OS_TYPE -match "Windows" -and $vm.VM_TYPE -NotMatch "ActiveDirectory") {
                
                if ($vm.VM_TYPE -match "UCCE") {
                    $ServerType = "ICM"
                } else {
                    $ServerType = "Standard"
                }

                if ($BIhash.TIMEZONE -eq "Etc/UTC") {
                    Log-Message "INFO" "Timezone is UTC. Invoking script to set UTC timezone properly"
                    $script = '$CurrentTimeZone = [System.TimeZone]::CurrentTimeZone | Select-Object StandardName;if ($CurrentTimeZone -match "{StandardName=GMT Standard Time}") {	tzutil.exe /s "UTC" };'
                    RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP
                } else {
                    Log-Message "INFO" "Testing Connection..."
                    $script = 'Write-Host "Connection Success"'
                    RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP
                }

                Log-Message "INFO" "Copying Windows files and folders.  This may take a few minutes..."

                $goldentemplatename = $vm.GOLDEN_TEMPLATE_NAME
                if(Test-Path "$HOME_PATH\ServerResources\Templates\$goldentemplatename") {
                    Log-Message "INFO" "Copying files from template specific files"
                    Copy-VMGuestFile -Source "$HOME_PATH\ServerResources\Templates\$goldentemplatename\*.*" -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
                } else {
                    Log-Message "INFO" "No template specific files to copy"
                }
                
                Copy-VMGuestFile -Source $FileHash.Setup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
                Log-Message "INFO" "Done copying Setup"

				Copy-VMGuestFile -Source $FileHash.SSLCerts -Destination "c:\Software\SSLCerts\wildcard.pfx" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
				Log-Message "INFO" "Done copying wildcard.pfx"

                Copy-VMGuestFile -Source $FileHash.CACerts -Destination "c:\Software\SSLCerts\bundle.crt" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
				Log-Message "INFO" "Done copying bundle.crt"
                
                if ($vm.VM_TYPE -Match "ADFS_") {
                    Copy-VMGuestFile -Source $FileHash.ADFSTheme -Destination "c:\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
                    $script = 'Add-Type -AssemblyName System.IO.Compression.FileSystem; [System.IO.Compression.ZipFile]::ExtractToDirectory("c:\adfstheme.zip", "c:\adfstheme");Remove-Item -Path "c:\adfstheme.zip" -Force;'
                    Log-Message "DEBUG" "$script"
                    RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "10" $vm.VCENTER_IP
                    Log-Message "INFO" "Done copying ADFSTheme"

                    Copy-VMGuestFile -Source $FileHash.ADFSSetup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
				    Log-Message "INFO" "Done copying ADFS-Setup.ps1"
                }

                if ($vm.VM_TYPE -match "UCCE") {
                    Copy-VMGuestFile -Source $FileHash.ICMSetup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
				    Log-Message "INFO" "Done copying ICM-Setup.ps1"
                    Copy-VMGuestFile -Source $FileHash.ServerCerts -Destination "C:\icm\ssl\certs\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
				    Log-Message "INFO" "Done copying host.pem"
                    Copy-VMGuestFile -Source $FileHash.PrivateCerts -Destination "C:\icm\ssl\keys\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
				    Log-Message "INFO" "Done copying host.key"
                }

                if ($vm.VM_TYPE -match "CVP_") {
                    Copy-VMGuestFile -Source $FileHash.CVPSetup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DefaultCredential -Server $vm.VCENTER_IP -Force
				    Log-Message "INFO" "Done copying CVP-Setup.ps1"
                }
                
                if ($vm.VM_TYPE -match "CVP_Call") {
                    
                    Log-Message "INFO" "Server Type is CVP Call.  Invoking script to Update RMI Server IP" 
                    $script = "cmd.exe /c perl C:\Cisco\CVP\bin\updatermiserverip\updatermiserverip.pl"
					RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP

                } elseif ($vm.VM_TYPE -match "CVP_OAMP") {
                    Log-Message "INFO" "Server Type is CVP Ops.  Invoking script to Update RMI Server IP"
                    $script = "cmd.exe /c perl C:\Cisco\CVP\bin\updatermiserverip\updatermiserverip.pl"
					RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "30" $vm.VCENTER_IP
                }

                Log-Message "INFO" "Invoking Setup"
                if ($vm.NIC_NUM -eq "2") {
                    
                    if ($vm.JOIN_DOMAIN -eq "NO") {
                        $script = '&"C:\Software\Setup Scripts\Setup.ps1" -ServerType "'+$ServerType+'" -DomainName "'+$BIhash.DOMAIN_NAME+'" -CertificatePassword "'+$BIhash.ADFSCERTIFICATEPASSWORD+'" -DomainUserName "'+$BIhash.DOMAINADMINUSERNAME+'" -DomainUserPass "'+$BIhash.DOMAINADMINPASSWORD+'" -PrivateIP "'+$vm.IP_ADDRESS_NIC2+'" -RemotePrivateCIDR "'+$vm.REMOTE_PRIVATE_CIDR+'" -LeaveInWorkgroup:$true';
                    } else {
                        $script = '&"C:\Software\Setup Scripts\Setup.ps1" -ServerType "'+$ServerType+'" -DomainName "'+$BIhash.DOMAIN_NAME+'" -CertificatePassword "'+$BIhash.ADFSCERTIFICATEPASSWORD+'" -DomainUserName "'+$BIhash.DOMAINADMINUSERNAME+'" -DomainUserPass "'+$BIhash.DOMAINADMINPASSWORD+'" -PrivateIP "'+$vm.IP_ADDRESS_NIC2+'" -RemotePrivateCIDR "'+$vm.REMOTE_PRIVATE_CIDR+'"';
                    }
                    

                } else {

                    if ($vm.JOIN_DOMAIN -eq "NO") {
                        $script = '&"C:\Software\Setup Scripts\Setup.ps1" -ServerType "'+$ServerType+'" -DomainName "'+$BIhash.DOMAIN_NAME+'" -CertificatePassword "'+$BIhash.ADFSCERTIFICATEPASSWORD+'" -DomainUserName "'+$BIhash.DOMAINADMINUSERNAME+'" -DomainUserPass "'+$BIhash.DOMAINADMINPASSWORD+'" -LeaveInWorkgroup:$true';
                    } else {
                        $script = '&"C:\Software\Setup Scripts\Setup.ps1" -ServerType "'+$ServerType+'" -DomainName "'+$BIhash.DOMAIN_NAME+'" -CertificatePassword "'+$BIhash.ADFSCERTIFICATEPASSWORD+'" -DomainUserName "'+$BIhash.DOMAINADMINUSERNAME+'" -DomainUserPass "'+$BIhash.DOMAINADMINPASSWORD+'"';
                    }
                   
                }
                
                Log-Message "DEBUG" "$script"
                RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DefaultCredential "10" $vm.VCENTER_IP
                $WindowsServersAdded = $true

                RestartVM $vm.NEW_VM_NAME $vm.VCENTER_IP
                
            }
        }
    }

    if ($WindowsServersAdded) {

        Log-Message "INFO" "Windows Servers have been deployed. Script will resume in 2 minutes"
        ExecuteScriptsSleep "120"

    }

    foreach ($vm in $Global_Vm_array) {

        if (($vm.CREATEVM -like "YES") -and ($vm.AUTO_POWERON -eq "YES") -and ($vm.TASK_STATUS -eq "Success")) {
            
            if ($vm.OS_TYPE -match "Windows" -and $vm.VM_TYPE -NotMatch "ActiveDirectory") {

                if ($vm.VM_TYPE -match "CVP_Call") {
                
                    Log-Message "INFO" "Invoking CVP Replication Setup"
                    if ($vm.NEW_VM_NAME -ne $PrimaryCVPServer) {

                        if (($vm.SERVERNUM -match "02") -and ($vm.CLUSTERNUM -match "01")) {

                            Log-Message "INFO" "CVP Server is secondary in cluster 01.  Both MedialFile and Dialer Replication will be setup"
                            $script = '&"C:\Software\Setup Scripts\CVP-FileCopy-Setup.ps1" -IsPrimary:$false -PrimaryCVPServer "'+$PrimaryCVPServer+'" -SecondaryCVPServer "'+$SecondaryCVPServer+'" -EnableDialer:$true';

                        } else {
                            
                            Log-Message "INFO" "CVP Server is either not 02 or not in cluster 01. MediaFile Replication will be setup, but Dialer won't be"
                            $script = '&"C:\Software\Setup Scripts\CVP-FileCopy-Setup.ps1" -IsPrimary:$false -PrimaryCVPServer "'+$PrimaryCVPServer+'" -SecondaryCVPServer "'+$SecondaryCVPServer+'" -EnableDialer:$false';
                            
                        }

                    } else {
                        Log-Message "INFO" "This is the primary CVP Server.  Both MedialFile and Dialer Replication will be setup"
                        $script = '&"C:\Software\Setup Scripts\CVP-FileCopy-Setup.ps1" -IsPrimary:$true -PrimaryCVPServer "'+$PrimaryCVPServer+'" -SecondaryCVPServer "'+$SecondaryCVPServer+'" -EnableDialer:$true'

                    }
                                        
                    Log-Message "DEBUG" "$script"
                    RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "10" $vm.VCENTER_IP

                }

                #Install ADFS
                if ($vm.VM_TYPE -Match "ADFS_") {
                    
                    if ($vm.SERVERNUM -notmatch "01") {
                        Log-Message "INFO" "Invoking AD FS Setup for Primary Server"
                        $script = '&"C:\Software\Setup Scripts\ADFS-Setup.ps1" -IsPrimary:$false -DomainName "'+$BIhash.DOMAIN_NAME+'" -ADFSCompanyName "'+$BIhash.ADFSCOMPANYNAME+'" -ADFSThemeFolder "'+$BIhash.ADFSTHEMEFOLDER+'" -ADFSPrimaryServer "'+$adfsprimaryname+'" -ADFSSVCAccountName "'+$BIhash.ADFSSVCACCOUNTNAME+'" -ADFSSVCAccountPass "'+$BIhash.ADFSSVCACCOUNTPASS+'"';
                    } else {
                        Log-Message "INFO" "Invoking AD FS Setup for Secondary Server"
                        $script = '&"C:\Software\Setup Scripts\ADFS-Setup.ps1" -IsPrimary:$true -DomainName "'+$BIhash.DOMAIN_NAME+'" -ADFSCompanyName "'+$BIhash.ADFSCOMPANYNAME+'" -ADFSThemeFolder "'+$BIhash.ADFSTHEMEFOLDER+'" -ADFSPrimaryServer "'+$adfsprimaryname+'" -ADFSSVCAccountName "'+$BIhash.ADFSSVCACCOUNTNAME+'" -ADFSSVCAccountPass "'+$BIhash.ADFSSVCACCOUNTPASS+'"';
                    }
                    Log-Message "DEBUG" "$script"
                    RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "10" $vm.VCENTER_IP
                    RestartVM $vm.NEW_VM_NAME $vm.VCENTER_IP
                    
                }


                #Install ICM
                if ($vm.VM_TYPE -match "UCCE") {

                    Log-Message "INFO" "Invoking ICM Setup for $($vm.NEW_VM_NAME)"
                    $script = '&"C:\Software\Setup Scripts\ICM-Setup.ps1" -SystemID "'+$BIhash.SYSTEMID+'" -ServerNumber "'+$vm.SERVERNUM+'"';
                    Log-Message "DEBUG" "$script"
                    RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "10" $vm.VCENTER_IP
                    RestartVM $vm.NEW_VM_NAME $vm.VCENTER_IP
                    
                } 

                #Install CVP
                if ($vm.VM_TYPE -match "CVP_" -and $vm.vm_type -notlike "*RPT*") {
                    Log-Message "INFO" "Invoking CVP Setup for $($vm.NEW_VM_NAME)"
                    $script = '&"C:\Software\Setup Scripts\CVP-Setup.ps1" -WildcardCertPass "'+$BIhash.ADFSCERTIFICATEPASSWORD+'"';
                    Log-Message "DEBUG" "$script"
                    RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "10" $vm.VCENTER_IP
                    RestartVM $vm.NEW_VM_NAME $vm.VCENTER_IP
                }
            } 
        } 
    }

    if ($sleepforpubs) {

        Log-Message "INFO" "Beginning publishers: Sleeping for 40 minutes before starting connectivity checks"
        ExecuteScriptsSleep "2400"
        $TomcatTestAttempts = 15

        foreach ($vm in $Global_Vm_array) {


            if (($vm.CREATEVM -like "YES") -and ($vm.OS_TYPE -match "Linux") -and ($vm.TASK_STATUS -eq "Success")) {
                
                if (($vm.AUTO_POWERON -eq "YES") -and (($vm.SERVERNUM -match "01") -or ($vm.VM_TYPE -match "VVB_"))) {

                    $localuserpwsecure = ConvertTo-SecureString -String $vm.AdminAndClusterClearPW -AsPlainText -Force

                    $localusername = $vm.AdminUserName
                    $localcreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $localusername, $localuserpwsecure
                
                    Log-Message "INFO" "Starting connectivity check for $($vm.NEW_VM_NAME)"
                    $TomcatTestFail = $true

                    if ($TomcatTestAttempts -eq 0) {
                        $TomcatTestAttempts = 2
                    }

                    while ($TomcatTestFail -and $TomcatTestAttempts -gt 0) {
                        
                        try 
                        {
                            
                            $TomcatTest = Invoke-VMScript -VM $vm.NEW_VM_NAME -ScriptText "netstat -an | grep 443" -GuestCredential $localcreds -ErrorAction Stop

                            if ($TomcatTest.ScriptOutput) 
                            {
                                Log-Message "INFO" "Connectivity check has succeeded for $($vm.NEW_VM_NAME)"
                                $TomcatTestFail = $false
                                $TomcatTestAttempts = 0
                            } 
                            else 
                            {
                                Log-Message "INFO" "The connectivity check succeeded, but processes are still unavailable for $($vm.NEW_VM_NAME)"
                            }
                        } 
                        catch 
                        {
                            Log-Message "INFO" "Connectivity check for $($vm.NEW_VM_NAME) has failed"
                            $TomcatTestAttempts = $TomcatTestAttempts - 1
                        }


                        if ($TomcatTestFail -and $TomcatTestAttempts -gt 0) 
                        {   
                            Log-Message "INFO" "The number of attempts remaining is $TomcatTestAttempts - Will try again in 4 minutes"
                            ExecuteScriptsSleep "240"
                        } 
                        elseif ($TomcatTestFail) 
                        {
                            Log-Message "ERROR" "$($vm.NEW_VM_NAME) failed to complete setup. Use the VMware Console to verify this servers status"
                            $ta = Read-Host "Press 'n' to continue setup, press anything else to try again"
                            if ($ta -notlike "n")
                            {
                                $TomcatTestAttempts = 2
                                $TomcatTestFail = $true
                            }
                            else
                            {
                                $TomcatTestAttempts = 0
                                $TomcatTestFail = $false
                            }
                        }
                    }      
                }
            }
        }

        Log-Message "INFO" "Sleeping for 4 minutes while Primary applications initialize"
        ExecuteScriptsSleep "240"

    }

    
    Log-Message "INFO" "Executing Subscriber and Secondary Servers"
    foreach ($vm in $Global_Vm_array)
	{
        ###Add Finesse Secondary to Finesse Configuration###

        if (($FinesseSecArr) -and ($vm.VM_TYPE -match "ActiveDirectory_PDC_")) {

            Log-Message "INFO" "Copying Finesse-Setup.ps1 to Primary AD"
            Copy-VMGuestFile -Source $FileHash.FinesseSetup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DomainAdminCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying Finesse-Setup.ps1"

            foreach ($Finesse in $FinesseSecArr) {

                Log-Message "INFO" "Calling Finesse-Setup to add Secondary Server $($Finesse.SECONDARY) to $($Finesse.PRIMARY)"
                $script = '&"C:\Software\Setup Scripts\Finesse-Setup.ps1" -Method ADD_SECONDARY -FinesseServer "'+$Finesse.PRIMARY+'" -SecondaryNode "'+$Finesse.SECONDARY+'" -Username "'+$Finesse.USERNAME+'" -Password "'+$Finesse.PASSWORD+'"';
                Log-Message 'DEBUG' $script
                RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "1" $vm.VCENTER_IP
                
            }

        }

        ###End of Add Finesse Secondary to Finesse Configuration###

		if (($vm.CREATEVM -like "YES") -and ($vm.TASK_STATUS -eq "Success") -and ($vm.OS_TYPE -match "Linux")) {
            
           if (($vm.SERVERNUM -notmatch "01") -and ($vm.VM_TYPE -notmatch "VVB_")) {

                ###Power On VMs
                if ($vm.AUTO_POWERON -eq "YES") {
                    Log-Message "INFO" "Powering on $($vm.NEW_VM_NAME)"
                    $startvm = Start-VM -VM $vm.NEW_VM_NAME -Server $vm.VCENTER_IP
                    $sleepforsubs = $true

                    ###Move VM Section
                    try {

                        if ($vm.OS_TYPE -match "Windows") {
					        $folderToMoveName = "Windows"
				        } else {
					        $folderToMoveName = "Linux"
				        }

                        Log-Message "INFO" "Moving VM to $folderToMoveName folder"
                        $CustVMFolder = Get-Datacenter -Name $vm.DATA_CENTER -Server $vm.VCENTER_IP | Get-Folder -Name $BIhash.VM_FOLDER -Type VM -Server $vm.VCENTER_IP
                        $ServerVMFolder = Get-Folder -Name $folderToMoveName -Location $CustVMFolder -Type VM -NoRecursion -Server $vm.VCENTER_IP -ErrorAction SilentlyContinue
                        $MoveVM = Move-VM -VM $vm.NEW_VM_NAME -InventoryLocation $ServerVMFolder #-Server $vm.VCENTER_IP

                    } catch {

                        Log-Message "ERROR" "Failed to move $($vm.NEW_VM_NAME). It will need to be moved manually from its default location"
                    }
                    ###End of Move VM Section
                }
                ###End of Power On VMs
                
            }
            
        }
    }

    if ($sleepforsubs) {

        Log-Message "INFO" "Sleeping for 30 minutes before beginning connectivity checks"
        ExecuteScriptsSleep "1800"
        $TomcatTestAttempts = 15

        foreach ($vm in $Global_Vm_array) {

            if (($vm.CREATEVM -like "YES") -and ($vm.OS_TYPE -match "Linux") -and ($vm.TASK_STATUS -eq "Success")) {
                
                if (($vm.AUTO_POWERON -eq "YES") -and ($vm.SERVERNUM -notmatch "01") -and ($vm.VM_TYPE -notmatch "VVB_")) {
                
                    $localuserpwsecure = ConvertTo-SecureString -String $vm.AdminAndClusterClearPW -AsPlainText -Force

                    $localusername = $vm.AdminUserName
                    $localcreds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $localusername, $localuserpwsecure

                    Log-Message "INFO" "Starting connectivity check for $($vm.NEW_VM_NAME)"
                    $TomcatTestFail = $true

                    if ($TomcatTestAttempts -eq 0) {
                        $TomcatTestAttempts = 2
                    }

                    while ($TomcatTestFail -and $TomcatTestAttempts -gt 0) {
                        
                        try
                        {  
                            $TomcatTest = Invoke-VMScript -VM $vm.NEW_VM_NAME -ScriptText "netstat -an | grep 443" -GuestCredential $localcreds -ErrorAction Stop

                            if ($TomcatTest.ScriptOutput) 
                            {
                                Log-Message "INFO" "Connectivity check has succeeded for $($vm.NEW_VM_NAME)"
                                $TomcatTestFail = $false
                                $TomcatTestAttempts = 0
                            } 
                            else 
                            {
                                Log-Message "INFO" "The connectivity check succeeded, but processes are still unavailable for $($vm.NEW_VM_NAME)"
                            }                        
                        } 
                        catch 
                        {
                            Log-Message "INFO" "Connectivity check for $($vm.NEW_VM_NAME) has failed"
                        }

                        $TomcatTestAttempts = $TomcatTestAttempts - 1
                        if ($TomcatTestFail -and $TomcatTestAttempts -gt 0) 
                        {                 
                            Log-Message "INFO" "The number of attempts remaining is $TomcatTestAttempts - Will try again in 4 minutes"
                            ExecuteScriptsSleep "240"
                        } 
                        elseif ($TomcatTestFail) 
                        {
                            Log-Message "ERROR" "$($vm.NEW_VM_NAME) failed to complete setup. Use the VMware Console to verify this servers status"
                                                        $ta = Read-Host "Press 'n' to continue setup, press anything else to try again"
                            if ($ta -notlike "n")
                            {
                                $TomcatTestAttempts = 2
                                $TomcatTestFail = $true
                            }
                            else
                            {
                                $TomcatTestAttempts = 0
                                $TomcatTestFail = $false
                            }
                        }
                    }
                }
            }
        }

        Log-Message "INFO" "Sleeping for 4 minutes while Subscriber applications initialize"
        ExecuteScriptsSleep "240"
        
    }

    Log-Message "INFO" "Executing Final Cluster Configurations"

    foreach ($vm in $Global_Vm_array)
	{

        if (($DelegationArray) -and ($vm.VM_TYPE -match "ActiveDirectory") -and ($vm.SERVERNUM -eq "01")) {

            $DelegationArraySplit = $DelegationArray.split(",")

            foreach ($Delegation in $DelegationArraySplit) 
            {
                
                Do
                {
                    try 
                    {

                        Log-Message "INFO" "Removing $Delegation if it exists"
                        $script = 'Remove-DnsServerZoneDelegation -Name ' +$vm.DOMAIN_NAME+ ' -ChildZoneName ' +$Delegation+ ' -Force:$true'
                        Log-Message 'DEBUG' $script
                        $invokevmscript = Invoke-VMScript -ScriptText $script -VM $vm.NEW_VM_NAME -GuestCredential $DomainAdminCredential -Server $vm.VCENTER_IP -ErrorAction Stop

                    } 
                    catch 
                    {
                        Log-Message "ERROR" "Failed to remove delegation for $Delegation"
                        $ta = Read-Host "Press 'n' to continue setup with errors, press anything else to try again"
                        if ($ta -notlike "n")
                        {
                            $ta = $true
                        }
                        else
                        {
                            $ta = $false
                        }
                    }
                } While ($ta)

                do
                {
                    try 
                    {

                        $script = 'Add-DnsServerZoneDelegation -Name ' +$vm.DOMAIN_NAME+ ' -ChildZoneName ' +$Delegation+ ' -IPAddress ' +$BIhash.NETSCALERSNIP1 + ' -NameServer ' +$BIhash.NETSCALERSNIP1FQDN
                        Log-Message 'DEBUG' $script
                        $invokevmscript = Invoke-VMScript -ScriptText $script -VM $vm.NEW_VM_NAME -GuestCredential $DomainAdminCredential -Server $vm.VCENTER_IP -ErrorAction Stop

                        Log-Message "INFO" "Successfully added delegation for $Delegation pointing to $($BIhash.NETSCALERSNIP1) and $($BIhash.NETSCALERSNIP1FQDN)"               
                    } 
                    catch 
                    {
                        Log-Message "ERROR" "Failed to add delegation for $Delegation pointing to $($BIhash.NETSCALERSNIP1) and $($BIhash.NETSCALERSNIP1FQDN)"
                        $ta = Read-Host "Press 'n' to continue setup with errors, press anything else to try again"
                        if ($ta -notlike "n")
                        {
                            $ta = $true
                        }
                        else
                        {
                            $ta = $false
                        }
                    }
                }while ($ta)

                do
                {
                    try 
                    {
                        $script = 'Add-DnsServerZoneDelegation -Name ' +$vm.DOMAIN_NAME+ ' -ChildZoneName ' +$Delegation+ ' -IPAddress ' +$BIhash.NETSCALERSNIP2 + ' -NameServer ' +$BIhash.NETSCALERSNIP2FQDN
                        Log-Message 'DEBUG' $script
                        $invokevmscript = Invoke-VMScript -ScriptText $script -VM $vm.NEW_VM_NAME -GuestCredential $DomainAdminCredential -Server $vm.VCENTER_IP -ErrorAction Stop

                        Log-Message "INFO" "Successfully added delegation for $Delegation pointing to $($BIhash.NETSCALERSNIP2) and $($BIhash.NETSCALERSNIP2FQDN)"

                    } 
                    catch 
                    {
                        Log-Message "ERROR" "Failed to add delegation for $Delegation pointing to $($BIhash.NETSCALERSNIP2) and $($BIhash.NETSCALERSNIP2FQDN)"
                        $ta = Read-Host "Press 'n' to continue setup with errors, press anything else to try again"
                        if ($ta -notlike "n")
                        {
                            $ta = $true
                        }
                        else
                        {
                            $ta = $false
                        }
                    }
                }while ($ta)
            }
        }

		if (($VVBArray) -and ($vm.VM_TYPE -match "CVP_OAMP")) {

            Log-Message "INFO" "Server Type is CVP Ops.  Copying VVB-Ops-Setup.ps1"
            Copy-VMGuestFile -Source $FileHash.VVBOpsSetup -Destination "c:\Software\Setup Scripts\" -VM $vm.NEW_VM_NAME -LocalToGuest -GuestCredential $DomainAdminCredential -Server $vm.VCENTER_IP -Force
            Log-Message "INFO" "Done copying VVB-Ops-Setup.ps1"
            
            Log-Message "INFO" "Invoking VVB-Ops-Setup.ps1"
            $script = '&"C:\Software\Setup Scripts\VVB-Ops-Setup.ps1" -ServerAddresses '+$VVBArray;
            Log-Message "DEBUG" "$script"
            RunPSOnWindowsVM $script $vm.NEW_VM_NAME $DomainAdminCredential "30" $vm.VCENTER_IP
            
        }

    }

    Log-Message "INFO" "Done Powering On VMs and Executing Scripts"

    if ($passwordsresult) {
        Write-Host Copy and paste the text below -ForegroundColor yellow  
        Write-Host ******************* -ForegroundColor yellow  
        Write-Host $passwordsresult -ForegroundColor yellow
        Write-Host ******************* -ForegroundColor yellow
    }
                
}

#####################################################################################################
# Function ExecuteScriptsSleep : Sleeps while VM's are performing tasks
#####################################################################################################  

Function ExecuteScriptsSleep ($timetosleep) {
    
    while ($timetosleep -gt 0) {
        Start-Sleep -s 120
        $timetosleep = $timetosleep-120
        if ($timetosleep -gt 0) {
            Log-Message "INFO" "Sleeping for $timetosleep more seconds"
        }
        
    }
    
}

#####################################################################################################
# Function RestartVM : Restarts the Guest OS
#####################################################################################################  

Function RestartVM ($vmname, $VCenter) {
    Log-Message "INFO" "Initiating restart of $vmname"
    $restart = Get-VM $vmname -Server $VCenter | Restart-VMGuest -Server $VCenter
    Start-Sleep -Seconds 40
    do {
        Start-Sleep -Seconds 20
        Log-Message "INFO" "Waiting for VM reboot"
        $VMInfo = Get-VM $vmname -Server $VCenter
        $GuestIP = $VMInfo.Guest.IPAddress
    }
    until ($GuestIP)
    Start-Sleep -Seconds 30
    Log-Message "INFO" "$vmname restart completed"
}


Function PauseOnError ($errorLocation)
{

    switch ($errorLocation)
    {
        1 {Write-Host }

    }


}





































#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################
# Start of Main Script
#####################################################################################################
#####################################################################################################
#####################################################################################################
#####################################################################################################

Write-Host ""
$HOME_PATH = (Get-Item $XLPath -ErrorAction SilentlyContinue).Directory.FullName

# Print Version
Log-Message -Type "INFO" -Message "GTT Version 206"

if ($HOME_PATH) {
    Log-Message -Type "INFO" -Message "HOME_PATH = $HOME_PATH"
} else {
    Log-Message -Type "ERROR" -Message "Failed to locate the file $XLPath" -ForegroundColor Red
    exit
}

$DateAndTime = Get-Date
$TimeStamp = "" + $DateAndTime.Day + "_" + $DateAndTime.Month + "_" + $DateAndTime.Year + "_" + $DateAndTime.Hour + "_" + $DateAndTime.Minute + "_" + $DateAndTime.Second + "_" + $DateAndTime.Millisecond
Log-Message -Type "INFO" -Message "TimeStamp = $TimeStamp"

$LogFileNameWithFullPath = "$HOME_PATH\Log\PSLOG_$TimeStamp.log"
Log-Message -Type "INFO" -Message "LogFileNameWithFullPath = $LogFileNameWithFullPath"

# Calling RecordSession function to start logging
RecordSession

# Getting VMware Setup
Log-Message -Type "INFO" -Message "Loading VMware Snapin"
#Add-PSSnapin VMware.VimAutomation.Core -ErrorAction Stop
#Save-Module -Name VMware.VimAutomation.Core -Path "C:\Program Files\WindowsPowerShell\Modules"  ##This is the command that's needed if errors pop-up
Import-Module VMware.VimAutomation.Core -ErrorAction Stop


Log-Message -Type "INFO" -Message "Setting execution policy to Bypass"
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -ErrorAction Stop

#Setting base paths
$SCRIPT_PATH = "$HOME_PATH\Scripts"
Log-Message -Type "INFO" -Message "SCRIPT_PATH = $SCRIPT_PATH"
$MODULE_PATH = "$HOME_PATH\Modules"
Log-Message -Type "INFO" -Message "MODULE_PATH = $MODULE_PATH"
$SERVER_RESOURCES_PATH = "$HOME_PATH\ServerResources"
Log-Message -Type "INFO" -Message "WIN_FILES_PATH = $SERVER_RESOURCES_PATH"

# Loading Additional Scripts & Modules
$ScriptsToLoad = `
    "$SCRIPT_PATH\Utils.PS1", `
    "$SCRIPT_PATH\Report.PS1", `
    "$SCRIPT_PATH\GeneratePlatformConfigXML.ps1", `
    "$SCRIPT_PATH\OVFToolUtils.PS1"

Foreach ($ScriptToLoad in $ScriptsToLoad) {
    try {
        . $ScriptToLoad -ErrorAction Stop
        Log-Message -Type "INFO" -Message "Loaded Script $ScriptToLoad"
    } catch {
        Log-Message -Type "ERROR" -Message "Failed to load $ScriptToLoad"
        ExitScript
    }

}

$ModulesToLoad = `
    "$MODULE_PATH\NITROConfigurationFunctions.psm1", `
    "$MODULE_PATH\GlobalConfigurationFunctions.psm1"

Foreach ($ModuleToLoad in $ModulesToLoad) {
    
    $loadscript = Load-Script -FilePath $ModuleToLoad
    if (-not $loadscript) {
        ExitScript
    }
}

# Adding files and folders to FileHash and ensuring they are present in the tool
$FileHash = $null
$FileHash = @{}

$FileHash.add("BuildPath","$BuildPath")
$FileHash.add("Setup","$SERVER_RESOURCES_PATH\Setup.ps1")
$FileHash.add("NewPassword","$SERVER_RESOURCES_PATH\New-SWRandomPassword.ps1")
$FileHash.add("ADPrimary","$SERVER_RESOURCES_PATH\AD-Primary.ps1")
$FileHash.add("ADPrimaryFinal","$SERVER_RESOURCES_PATH\AD-Primary-Final.ps1")
$FileHash.add("ADSecondary","$SERVER_RESOURCES_PATH\AD-Secondary.ps1")
$FileHash.add("GPOBackups","$SERVER_RESOURCES_PATH\GPO Backups.zip")
$FileHash.add("ADMXTemplates","$SERVER_RESOURCES_PATH\ADMX Templates.zip")
$FileHash.add("ADFSTheme","$SERVER_RESOURCES_PATH\adfstheme.zip")
$FileHash.add("Templates","$SERVER_RESOURCES_PATH\Templates")
$FileHash.add("GPWMIFilter","$SERVER_RESOURCES_PATH\GPWmiFilter.psm1")
$FileHash.add("ADFSSetup","$SERVER_RESOURCES_PATH\ADFS-Setup.ps1")
$FileHash.add("ICMSetup","$SERVER_RESOURCES_PATH\ICM-Setup.ps1")
$FileHash.add("CVPSetup","$SERVER_RESOURCES_PATH\CVP-Setup.ps1")
$FileHash.add("VVBOpsSetup","$SERVER_RESOURCES_PATH\VVB-Ops-Setup.ps1")
$FileHash.add("FinesseSetup","$SERVER_RESOURCES_PATH\Finesse-Setup.ps1")

Write-Host $FileHash.Setup

foreach ($key in $FileHash.keys) {

    $value = $FileHash[$key]
    if (Test-Path $value) {
        Log-Message -Type "INFO" -Message "Successfully tested $value"
    } else {
        Log-Message -Type "ERROR" -Message "$value does not exist. Exiting."
        ExitScript 
    }

}

# Reading BuildInfo Text File
$BIhash = $null
$BIhash = @{}

try {
    Foreach ($BuildLine in Get-Content -Path $BuildPath) {
        $BuildFields = $BuildLine.Split("`t")
        $BuildKey = $BuildFields[0]
        $BuildValue = $BuildFields[1]

        if ($BuildKey -like "*PASS*") {
            Log-Message -Type "DEBUG" -Message "Adding field to BIhash. Key=$BuildKey Value=*********"
        } else {
            Log-Message -Type "DEBUG" -Message "Adding field to BIhash. Key=$BuildKey Value=$BuildValue"
        }
        $BIhash.add($BuildFields[0],$BuildFields[1])

        if(-Not $BuildFields[1]) {
            if ($BuildFields[0] -match "SECONDARYDNS") {
                Log-Message -Type "WARNING" -Message "The build info parameter $BuildFields is empty. This is normal if configuring a single-sided system"
            } elseif ($BuildFields[0] -match "DOMAINADMINPASSWORD") {
                Log-Message -Type "ERROR" -Message "The build info parameter $BuildFields must be present.  Exiting."
                $domainuserwarning = 1
				ExitScript
            } elseif ($BuildFields[0] -match "DOMAINADMINUSERNAME") {
                Log-Message -Type "ERROR" -Message "The build info parameter $BuildFields must be present. Exiting."
                ExitScript
            } elseif ($BuildFields[0] -match "ADSAFEMODEPASS") {
                Log-Message -Type "WARNING" -Message "The build info parameter $BuildFields is empty. The script will validate later whether a DC is being deployed.  If a DC is being deployed it will fail"
            } elseif ($BuildFields[0] -match "NETSCALERUSERNAME" -or $BuildFields[0] -match "NETSCALERPASSWORD" -or $BuildFields[0] -match "NETSCALERHOST1" -or $BuildFields[0] -match "NETSCALERHOST2") {
                Log-Message -Type "WARNING" -Message "The build info parameter $BuildFields is empty. NetScaler configuration will not be performed"
                $disablenetscaler = 1
                $buildwarnings = 1
            } else {
                Log-Message -Type "WARNING" -Message "The build info parameter $BuildFields is empty. This may lead to downstream failures"
                $buildwarnings = 1
            }
        }
    }
} catch {
    Log-Message -Type "ERROR" -Message "Failed to read Build Info. Exiting"
    ExitScript
}

# Removing BuildInfo Text File
try {
    #Remove-Item -Path $BuildPath
    Log-Message -Type "DEBUG" -Message "Successfully removed build file"
} catch {
    Log-Message -Type "WARNING" -Message "Failed to remove Build File @ $BuildPath.  You should manually delete this" 
}

# If build warnings exist, prompt the user before continuing
if ($buildwarnings) {
    $choice = ""
    Write-Host ""
    Write-Host "Warnings were generated while reading build info.  Please review them above." -ForegroundColor DarkYellow
    while ($choice -notmatch "[y|n]"){       
        $choice = read-host "Do you want to continue? (Y/N)"
        Write-Host ""
    }

    if ($choice -eq "n"){
        ExitScript
    }
    
}

# Set Operating Systems to Variables  --> THIS MIGHT NOT BE USED
$LINUX = "Linux"
$WINDOWS_2K3 = "Windows2003"
$WINDOWS_2K8 = "Windows2008"
$WINDOWS_2K12 = "Windows2012"
$WINDOWS_2K16 = "Windows2016"

# Copy excel file to CSV

$IsParametersCSVCreated = $false
$CSVFileName = "$HOME_PATH\BuildInfo\$TimeStamp-Parameters.csv"
Log-Message -Type "INFO" -Message "Server info will be copied to CSVFileName = $CSVFileName"

$Headers = Get-GlobalCSVHeaders

if($XLPath -match ".xlsm") {
    [System.Threading.Thread]::CurrentThread.CurrentCulture = New-Object "System.Globalization.CultureInfo" "en-US"
    # 6 is csv format
    $xlCSV = 6           
    $Excel = New-Object -Com Excel.Application 
    $Excel.visible = $False 
    $Excel.displayalerts=$False 
    $WorkBook = $Excel.Workbooks.Open($XLPath) 
    # save the .xlsm as .csv file for importing
    $Workbook.SaveAs($CSVFileName,$xlCSV) 
    $Workbook.Close()
    $Excel.quit()	
    		
    Start-Sleep -s 4
	
    if (Test-Path $CSVFileName) {
    	$IsParametersCSVCreated = $true

    	$vms = Import-CSV $CSVFileName -header $Headers
    	       
    	if($vms) {
            $excelpath =  $TimeStamp + "_" + "VMAutomationDataSheet.xlsm"
            $destpath = "$HOME_PATH\Archive\" + $excelpath
    				
    		#Archiving the .xlsm input file
    		Copy-Item $XLPath $destpath
    	}
    	else {			
    		Log-Message -Type "ERROR" -Message "Error importing the CSV file.  Please check the structure of the excel sheet provided as input and try again. Exiting."
            ExitScript			
    	}
    			
    } else {
    	
    	Log-Message -Type "ERROR" -Message "Error saving the input file as .CSV . Please check the structure of the excel sheet provided as input and try again. Exiting."
    	ExitScript
    }
} else {
    Log-Message -Type "ERROR" -Message "Not a supported input file format. Please provide the input file in .xlsm format only. Exiting."
    ExitScript
}

# Read the CSV file to the VM array and store data in array
$IsConnectionEstablished = $false
$Global_Vm_array = @()
Log-Message -Type "INFO:" -Message "Reading CSV file to vm array and storing data"

foreach ($vm in $vms) {	

    $objVM = New-Object System.Object

    if ($vm.NEW_VM_NAME -eq "" -or $vm.NEW_VM_NAME -eq "NEW_VM_NAME") {

    } else {

        foreach ($Header in $Headers) {
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key $Header -value $vm.$Header
        }
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "CUSTOMIZATION"  -value "YES"
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "OPERATION" -value ""
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "SOURCE_VMNAME" -value ""
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "DEST_GOLDEN_TEMPLATE_NAME" -value $vm.NEW_VM_NAME
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "COMPUTER_NAME" -value $vm.NEW_VM_NAME
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "WORK_GROUP" -value "YES"
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "WORK_GROUP_NAME" -value "WORKGROUP"
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "DOMAIN_NAME" -value $BIhash.DOMAIN_NAME
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "TIME_ZONE_LINUX" -value ""
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "DOMAIN_USER" -value ""
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "DOMAIN_PASSWORD" -value ""
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "PRODUCT_KEY" -value $BIhash.PRODUCT_KEY
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "OWNER_Name" -value $BIhash.OWNER_NAME
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "ORGANIZATION_Name" -value $BIhash.ORGANIZATION_NAME
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "ORGANIZATION_UNIT" -value $BIhash.ORGANIZATION_UNIT
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "ORGANIZATION_LOCATION" -value $BIhash.ORGANIZATION_LOCATION
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "ORGANIZATION_STATE" -value $BIhash.ORGANIZATION_STATE
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "ORGANIZATION_COUNTRY" -value $BIhash.ORGANIZATION_COUNTRY
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "ENVIRONMENT" -value $BIhash.ENVIRONMENT
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "USE_RESERVATIONS" -value $BIhash.USERESERVATIONS
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "DNS_IP_NIC2" -value $vm.DNS_IP_NIC1
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "DNS_ALTERNATE_NIC2" -value $vm.DNS_ALTERNATE_NIC1
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "OS_CUST_SPEC_NAME" -value ""
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "CCMFIRSTNODE" -value "yes"
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "IPSECFIRSTNODE" -value "yes"
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "CCMDBIPADDR" -value ""
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTPSERVERHOST" -value ""
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTPSERVERIPADDR" -value ""
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "IPSECMASTERHOST" -value ""
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "IPSECMASTERIPADDR" -value ""

        if ($vm.VM_TYPE -match "CVP_Call_SVR" -and $vm.SERVERNUM -eq "01" -and $vm.CLUSTERNUM -eq "01") {
            $PrimaryCVPServer = $vm.NEW_VM_NAME
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "CCMDBHost" -value ""
        } elseif ($vm.VM_TYPE -match "CVP_Call_SVR") {

            if ($vm.SERVERNUM -eq "02" -and $vm.CLUSTERNUM -eq "01") {

                $SecondaryCVPServer = $vm.NEW_VM_NAME
            }


            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "CCMDBHost" -value $PrimaryCVPServer
        } else {
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "CCMDBHost" -value ""
        }

        if ($vm.VM_TYPE -match "SideB") {
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER" -value $BIhash.SIDEBNTP1
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER2" -value $BIhash.SIDEBNTP2
        } elseif ($vm.VM_TYPE -match "SideC") {
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER" -value $BIhash.SIDECNTP1
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER2" -value $BIhash.SIDECNTP2
        } elseif ($vm.VM_TYPE -match "SideD") {
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER" -value $BIhash.SIDEDNTP1
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER2" -value $BIhash.SIDEDNTP2
        } else {
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER" -value $BIhash.SIDEANTP1
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "NTP_SERVER2" -value $BIhash.SIDEANTP2
        }


        $TIMEZONEsplit = $BIhash.TIMEZONE.Split("/")

    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "TIME_ZONE_LINUX_AREA" -value $TIMEZONEsplit[0]
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "TIME_ZONE_LINUX_LOCATION" -value $TIMEZONEsplit[1]
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "TIME_ZONE_WINDOWS" -value $BIhash.TIMEZONE

        if ($vm.NIC_NUM -eq "2") {
            
            Log-Message "DEBUG" "Found server with two NICs: $($vm.NEW_VM_NAME)"
            $CIDR = CIDR $vm.SUB_NET_MASK_NIC2
            $RemotePrivateSubnet = $vm.REMOTE_PRIVATE_SUBNET + "/" + $CIDR
            Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "REMOTE_PRIVATE_CIDR" -value $RemotePrivateSubnet

        }

        $AdminUserName = Get-GlobalCiscoCreds -VMType $vm.VM_TYPE -CredEnvironment $BIhash.ENVIRONMENT -CredType "AdminUser"
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "AdminUserName" -value $AdminUserName

        $AdminAndClusterPW = Get-GlobalCiscoCreds -VMType $vm.VM_TYPE -CredEnvironment $BIhash.ENVIRONMENT -CredType "AdminPass"
		Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "AdminAndClusterPW" -value $AdminAndClusterPW

        $AppAdminUserName = Get-GlobalCiscoCreds -VMType $vm.VM_TYPE -CredEnvironment $BIhash.ENVIRONMENT -CredType "AppUser"
		Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "AppAdminUserName" -value $AppAdminUserName

        $AppAdminPW = Get-GlobalCiscoCreds -VMType $vm.VM_TYPE -CredEnvironment $BIhash.ENVIRONMENT -CredType "AppPass"
		Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "AppAdminPW" -value $AppAdminPW

        $AppAdminClearPW = Get-GlobalCiscoCreds -VMType $vm.VM_TYPE -CredEnvironment $BIhash.ENVIRONMENT -CredType "AppClearPass"
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "AppAdminClearPW" -value $AppAdminClearPW

        $AdminAndClusterClearPW = Get-GlobalCiscoCreds -VMType $vm.VM_TYPE -CredEnvironment $BIhash.ENVIRONMENT -CredType "AdminClearPass"
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "AdminAndClusterClearPW" -value $AdminAndClusterClearPW

    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "TASK_OBJ" -value  "NULL"
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "TASK_ID"  -value  "NULL"
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "TASK_STATUS" -value "No Error"
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "PERCENT_COMPLETE" -value -1
    	Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "ERROR_MESSAGE" -value "Did Not Initiate VM Creation"
        Add-Items-To-VM-Object -servername $vm.NEW_VM_NAME -key "VCENTER_SESSION" -value ""

        if (-Not ($vcenterips)) {
            $vcenterips = $vm.VCENTER_IP
        } elseif (-Not ($vcenterips -like "*"+$vm.VCENTER_IP+"*")) {         
            $vcenterips = "$vcenterips,"+$vm.VCENTER_IP
        }

        if ($vm.VM_TYPE -match "ActiveDirectory" -and $vm.CREATEVM -eq "YES") {

            if (-Not $BIhash.ADSAFEMODEPASS) {
                Log-Message -Type "ERROR" -Message "ADFS Safe Mode Password must be supplied when creating ActiveDirectory VMs. Exiting"
                ExitScript
            }

        }

        if ($vm.VM_TYPE -match "ActiveDirectory" -and $vm.SERVERNUM -eq "01") {
            $pdcname = $vm.NEW_VM_NAME
            $pdcvcenter = $vm.VCENTER_IP
            Log-Message -Type "INFO" -Message "Stored Primary Domain Controller Name: pdcname = $pdcname, vcenter = $pdcvcenter"
            if ($vm.CREATEVM -eq "YES") {
                $pdcdeployed = 1
                Log-Message -Type "INFO" -Message "The Primary Domain Controller has been selected for deployment: pdcdeployed = $pdcdeployed"

                $DNSNatAddressList = $vm.DNS_NAT_IP_NIC1
                if ($vm.DNS_ALT_NAT_IP_NIC1.length -gt 7) {
                    $DNSNatAddressList = $DNSNatAddressList+','+$vm.DNS_ALT_NAT_IP_NIC1;
                }

                Log-Message -Type "INFO" -Message "The Management Domain DNS servers will use the following IPs when setup for forwarding: $DNSNatAddressList"

                $SitesToAddList = $BIhash.SIDEADATACENTERID.ToUpper()+'-'+$BIhash.SIDEADCSITESUBNET;

                if ($BIhash.SIDEBDATACENTERID) {
                    if ($BIhash.SIDEBDATACENTERID -ne $BIhash.SIDEADATACENTERID) {
                        $SitesToAddList = $SitesToAddList+','+$BIhash.SIDEBDATACENTERID.ToUpper()+'-'+$BIhash.SIDEBDCSITESUBNET
                    }
                }

                Log-Message -Type "INFO" -Message "AD Sites list set to: SitesToAddList = $SitesToAddList"

            } 
        } elseif (-not $nonpdcvmdeployed) {
            if ($vm.CREATEVM -eq "YES") {
                $nonpdcvmdeployed = 1
                Log-Message -Type "INFO" -Message "At least one non-Primary Domain Controller server is being deployed: nonpdcvmdeployed = $nonpdcvmdeployed"
            }
        }

        if ($vm.VM_TYPE -match "ADFS_" -and $vm.SERVERNUM -eq "01") {
            $adfsprimaryname = $vm.NEW_VM_NAME
            Log-Message -Type "INFO" -Message "Stored Primary AD FS Server Name: $adfsprimaryname"

            if ($vm.CREATEVM -eq "YES") {

                $NewDomainToDelegate = "sso"
                if ($DelegationArray) {
                    $DelegationArray = $DelegationArray+","+$NewDomainToDelegate
                } else {
                    $DelegationArray = $NewDomainToDelegate
                }

                Log-Message -Type "INFO" -Message "Updated delegations to create to include: $DelegationArray"

            }
        }
        
        if ($vm.VM_TYPE -match "FINESSE_") {
            
            if ($vm.SERVERNUM -eq "01") {

                $FinessePubName = $vm.NEW_VM_NAME
                
                if ($vm.CREATEVM -eq "YES") {

                    $NewDomainToDelegate = "fin"+$vm.CLUSTERNUM
                    if ($DelegationArray) {
                        $DelegationArray = $DelegationArray+","+$NewDomainToDelegate
                    } else {
                        $DelegationArray = $NewDomainToDelegate
                    }

                    Log-Message -Type "INFO" -Message "Updated delegations to create to include: $DelegationArray"
                }
            }

            if ($vm.SERVERNUM -eq "02" -and $vm.CREATEVM -eq "YES") {

                if (-not $FinesseSecArr) {
                    $FinesseSecArr = @()
                }
                $FinesseSecVM = New-Object System.Object
                $FinesseSecVM | Add-Member -type NoteProperty -name "PRIMARY" -value $FinessePubName
                $FinesseSecVM | Add-Member -type NoteProperty -name "SECONDARY" -value $vm.NEW_VM_NAME
                $FinesseSecVM | Add-Member -type NoteProperty -name "USERNAME" -value $AppAdminUserName
                $FinesseSecVM | Add-Member -type NoteProperty -name "PASSWORD" -value $AppAdminClearPW
                
                $FinesseSecArr += $FinesseSecVM

                Log-Message -Type "INFO" -Message "Finesse Secondary is being deployed. Primary = $FinessePubName, Secondary = $($vm.NEW_VM_NAME)"
            }

        }

        if ($vm.VM_TYPE -match "CUIC" -and ($vm.SERVERNUM -eq "01" -or $vm.SERVERNUM -eq "03" -or $vm.SERVERNUM -eq "05" -or $vm.SERVERNUM -eq "07") -and $vm.CREATEVM -eq "YES") {

            if ($vm.SERVERNUM -eq "01") {
                $cuicsubclusterletter = ""
            } if ($vm.SERVERNUM -eq "03") {
                $cuicsubclusterletter = "b"
            } if ($vm.SERVERNUM -eq "05") {
                $cuicsubclusterletter = "c"
            } if ($vm.SERVERNUM -eq "07") {
                $cuicsubclusterletter = "d"
            }

            $NewDomainToDelegate = "uic"+$vm.CLUSTERNUM+$cuicsubclusterletter
            if ($DelegationArray) {
                $DelegationArray = $DelegationArray+","+$NewDomainToDelegate
            } else {
                $DelegationArray = $NewDomainToDelegate
            }

            Log-Message -Type "INFO" -Message "Updated delegations to create to include: $DelegationArray"

        }
        
        if ($vm.VM_TYPE -match "CUCM_PUB" -and $vm.SERVERNUM -eq "01") {
            
            if ($vm.CREATEVM -eq "YES") {

                $NewDomainToDelegate = "em"+$vm.CLUSTERNUM
                if ($DelegationArray) {
                    $DelegationArray = $DelegationArray+","+$NewDomainToDelegate
                } else {
                    $DelegationArray = $NewDomainToDelegate
                }

                Log-Message -Type "INFO" -Message "Updated delegations to create to include: $DelegationArray"

            }
        }		

		if ($vm.OS_TYPE -match "Windows" -and $vm.CREATEVM -eq "YES") {
			
			if (-not $windowsbeingdeployed) {
				Log-Message "INFO" "A Windows server is being deployed.  Loading and testing for wildcard.pfx"
				$FileHash.add("SSLCerts","$HOME_PATH\wildcard.pfx")
				if (Test-Path $FileHash.SSLCerts) {
					Log-Message -Type "INFO" -Message "Successfully loaded wildcard.pfx"
                    Log-Message -Type "INFO" -Message "Extracting CA Certs to bundle.crt"
                    Start-Process -FilePath "$HOME_PATH\openssl\bin\openssl.exe" -ArgumentList "pkcs12 -in $HOME_PATH\wildcard.pfx -nodes -nokeys -cacerts -out $HOME_PATH\bundle.crt -passin pass:""$($BIhash.ADFSCERTIFICATEPASSWORD)""";
                    Log-Message -Type "INFO" -Message "Extracting Server and Chain Certs to host.pem"
                    Start-Process -FilePath "$HOME_PATH\openssl\bin\openssl.exe" -ArgumentList "pkcs12 -in $HOME_PATH\wildcard.pfx -nokeys -out $HOME_PATH\host.pem -passin pass:""$($BIhash.ADFSCERTIFICATEPASSWORD)""";
                    Log-Message -Type "INFO" -Message "Extracting Encrypted Private Key to host-key.pem"
                    Start-Process -FilePath "$HOME_PATH\openssl\bin\openssl.exe" -ArgumentList "pkcs12 -in $HOME_PATH\wildcard.pfx -nocerts -out $HOME_PATH\host-key.pem -passin pass:""$($BIhash.ADFSCERTIFICATEPASSWORD)"" -passout pass:""$($BIhash.ADFSCERTIFICATEPASSWORD)""";
                    Log-Message -Type "INFO" -Message "Extracting RSA Private Key to host.key"
                    Start-Process -FilePath "$HOME_PATH\openssl\bin\openssl.exe" -ArgumentList "rsa -in $HOME_PATH\host-key.pem -out $HOME_PATH\host.key -passin pass:""$($BIhash.ADFSCERTIFICATEPASSWORD)""";
                    Sleep -Seconds 5
                    if (Test-Path $HOME_PATH\bundle.crt) {
                        Log-Message -Type "INFO" -Message "Successfully extracted CA Certs to bundle.crt"
                        $FileHash.add("CACerts","$HOME_PATH\bundle.crt")
                        $windowsbeingdeployed = $true    
                    } else {

                        Log-Message -Type "ERROR" -Message "$HOME_PATH\bundle.crt does not exist. Exiting."
					    ExitScript 

                    }
					
                    if (Test-Path $HOME_PATH\host.pem) {
                        Log-Message -Type "INFO" -Message "Successfully extracted Server and Chain Certs to host.pem"
                        $FileHash.add("ServerCerts","$HOME_PATH\host.pem")
                        $windowsbeingdeployed = $true    
                    } else {

                        Log-Message -Type "ERROR" -Message "$HOME_PATH\host.pem does not exist. Exiting."
					    ExitScript 

                    }

                    if (Test-Path $HOME_PATH\host.key) {
                        Log-Message -Type "INFO" -Message "Successfully extracted RSA Private Key to host.key"
                        $FileHash.add("PrivateCerts","$HOME_PATH\host.key")
                        $windowsbeingdeployed = $true    
                    } else {

                        Log-Message -Type "ERROR" -Message "$HOME_PATH\host.key does not exist. Exiting."
					    ExitScript 

                    }

				} else {
					Log-Message -Type "ERROR" -Message "$($FileHash.SSLCerts) does not exist. Exiting."
					ExitScript 
				}
			}
		}

        if ($vm.VM_TYPE -match "CVP_OAMP_") {
        
            if ($vm.CREATEVM -eq "YES") {
                Log-Message "INFO" "A CVP Ops is being deployed"
                $cvpopsbeingdeployed = $true
            } 

            $cvpopsservername = $vm.NEW_VM_NAME
            Log-Message "INFO" "Stored CVP Ops server name as: $cvpopsservername"

        }
        
        if ($vm.VM_TYPE -match "VVB_" -and $vm.CREATEVM -eq "YES") {
            $VVBFQDN = $vm.NEW_VM_NAME+"."+$BIhash.DOMAIN_NAME
            if ($VVBArray) {
                $VVBArray = $VVBArray+","+$VVBFQDN
            } else {
                $VVBArray = $VVBFQDN
            }

            Log-Message "INFO" "A VVB is being deployed.  The FQDN is $VVBFQDN"

            if (-not $vvbbeingdeployed) {
                Log-Message "INFO" "Checking to see if CVP Ops is also being deployed"

                if ($cvpopsbeingdeployed) {
                    Log-Message "INFO" "CVP Ops is being deployed. Will not test whether ops console is currently online"
                } else {
                    Log-Message "INFO" "CVP Ops is not being deployed, will test whether its available prior to deploying VMs"
                    $testcvpopsstatus = $true
                }
            }

        }
        
        
    
        $Global_Vm_array += $objVM
    }
     
}

Log-Message -Type "INFO" -Message "Done reading CSV file to vm array"

$str = $FinesseSecArr | Out-String
Log-Message "SPECIAL" $str

if (-not $pdcdeployed) {

    if ($nonpdcvmdeployed) {
        if (-Not $BIhash.DOMAINADMINPASSWORD) {
            Log-Message "ERROR" "You must set the Domain Admin Password when not deploying a PDC in the same execution. Exiting"
            ExitScript
        }
    }
}

# Make vCenter Connection

if ($vcenterips) {

    $Global_vCenter_Session_Array = @()

    $vcenterips.Split(",") | ForEach {
        
        Log-Message -Type "INFO" -Message "Making vCenter connection to $_"
        $objVCenterSession = New-Object System.Object
        $Session = Connect-VIServer -Server $_ -Protocol https -User $BIHash.VCENTERUSERNAME -Password $BIhash.VCENTERPASSWORD
        
        if ($Session) {
            $IsConnectionEstablished = $true
            Log-Message -Type "INFO" -Message "Successfully connected to vCenter $_"
            $objVCenterSession | Add-Member -type NoteProperty -name NAME -value $_
            $objVCenterSession | Add-Member -type NoteProperty -name SESSION -value $Session
            $Global_vCenter_Session_Array += $objVCenterSession

            Log-Message -Type "INFO" -Message "Checking for VM folder structure on $_"

            if ($_ -eq $BIhash.SIDEAVCENTERIP) {
                
                $rootFolder = Get-Folder -Name $BIhash.VM_FOLDER -Location $BIhash.SIDEAVMWAREDATACENTER -Type "VM" -Server $_ -ErrorAction SilentlyContinue
                if ($rootFolder) {
                    Log-Message -Type "INFO" -Message "Found $($BIhash.VM_FOLDER) folder within vCenter: $_, DataCenter: $($BIhash.SIDEAVMWAREDATACENTER)"
                    
                    Log-Message -Type "INFO" -Message "Looking for Windows folder within $($BIhash.VM_FOLDER) for vCenter: $_, DataCenter: $($BIhash.SIDEAVMWAREDATACENTER)"

                    $ServerVMFolder = Get-Folder -Name "Windows" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                    if ($ServerVMFolder) {
                        Log-Message -Type "INFO" -Message "Folder was found"
                    } else {

                        Log-Message -Type "INFO" -Message "Folder was not found. Creating it"
                        $NewVMFolder = New-Folder -Location $rootFolder -Name "Windows" -Server $_
                        $ServerVMFolder = Get-Folder -Name "Windows" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                        if ($ServerVMFolder) {
                            Log-Message -Type "INFO" -Message "Folder was successfully created"
                        } else {
                            Log-Message -Type "ERROR" -Message "Unable to create folder. Exiting"
                        }

                    }

                    Log-Message -Type "INFO" -Message "Looking for Linux folder within $($BIhash.VM_FOLDER) for vCenter: $_, DataCenter: $($BIhash.SIDEAVMWAREDATACENTER)"

                    $ServerVMFolder = Get-Folder -Name "Linux" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                    if ($ServerVMFolder) {
                        Log-Message -Type "INFO" -Message "Folder was found"
                    } else {

                        Log-Message -Type "INFO" -Message "Folder was not found. Creating it"
                        $NewVMFolder = New-Folder -Location $rootFolder -Name "Linux" -Server $_
                        $ServerVMFolder = Get-Folder -Name "Linux" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                        if ($ServerVMFolder) {
                            Log-Message -Type "INFO" -Message "Folder was successfully created"
                        } else {
                            Log-Message -Type "ERROR" -Message "Unable to create folder. Exiting"
                        }

                    }
                } else {

                    Log-Message -Type "ERROR" -Message "Failed to find $($BIhash.VM_FOLDER) in vCenter: $_, DataCenter: $($BIhash.SIDEAVMWAREDATACENTER)"
                    ExitScript
                }
                
            }

            if (($_ -eq $BIhash.SIDEBVCENTERIP) -and -not ($_ -eq $BIhash.SIDEAVCENTERIP)) {

                $rootFolder = Get-Folder -Name $BIhash.VM_FOLDER -Location $BIhash.SIDEBVMWAREDATACENTER -Type "VM" -Server $_ -ErrorAction SilentlyContinue
                if ($rootFolder) {
                    Log-Message -Type "INFO" -Message "Found $($BIhash.VM_FOLDER) folder within vCenter: $_, DataCenter: $($BIhash.SIDEBVMWAREDATACENTER)"

                    Log-Message -Type "INFO" -Message "Looking for Windows folder within $($BIhash.VM_FOLDER) for vCenter: $_, DataCenter: $($BIhash.SIDEBVMWAREDATACENTER)"

                    $ServerVMFolder = Get-Folder -Name "Windows" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                    if ($ServerVMFolder) {
                        Log-Message -Type "INFO" -Message "Folder was found"
                    } else {

                        Log-Message -Type "INFO" -Message "Folder was not found. Creating it"
                        $NewVMFolder = New-Folder -Location $rootFolder -Name "Windows" -Server $_
                        $ServerVMFolder = Get-Folder -Name "Windows" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                        if ($ServerVMFolder) {
                            Log-Message -Type "INFO" -Message "Folder was successfully created"
                        } else {
                            Log-Message -Type "ERROR" -Message "Unable to create folder. Exiting"
                        }

                    }

                    Log-Message -Type "INFO" -Message "Looking for Linux folder within $($BIhash.VM_FOLDER) for vCenter: $_, DataCenter: $($BIhash.SIDEBVMWAREDATACENTER)"

                    $ServerVMFolder = Get-Folder -Name "Linux" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                    if ($ServerVMFolder) {
                        Log-Message -Type "INFO" -Message "Folder was found"
                    } else {

                        Log-Message -Type "INFO" -Message "Folder was not found. Creating it"
                        $NewVMFolder = New-Folder -Location $rootFolder -Name "Linux" -Server $_
                        $ServerVMFolder = Get-Folder -Name "Linux" -Location $rootFolder -Type VM -NoRecursion -Server $_ -ErrorAction SilentlyContinue

                        if ($ServerVMFolder) {
                            Log-Message -Type "INFO" -Message "Folder was successfully created"
                        } else {
                            Log-Message -Type "ERROR" -Message "Unable to create folder. Exiting"
                        }

                    }
                } else {

                    Log-Message -Type "ERROR" -Message "Failed to find $($BIhash.VM_FOLDER) in vCenter: $_, DataCenter: $($BIhash.SIDEBVMWAREDATACENTER)"
                    ExitScript

                }

            }

        } else {
            Log-Message -Type "ERROR" -Message "Failed to connect to vCenter $_"
            ExitScript
        }

    }
} else {
    Log-Message -Type "ERROR" -Message "No vCenter IP found. Exiting"
    ExitScript
}

#Store vCenter Sessions with each individual VM
Log-Message "INFO" "Storing vCenter Sessions to their associated VMs"
foreach ($vm in $Global_Vm_array) {	
    
    foreach ($vCenter_Session in $Global_vCenter_Session_Array) {	
         
        if ($vCenter_Session.NAME -eq $vm.VCENTER_IP) {
        
            Log-Message "DEBUG" "Storing vCenter Session for $($vCenter_Session.NAME) to $($vm.NEW_VM_NAME)"
            $vm.VCENTER_SESSION = $vCenter_Session.SESSION
              
        }
    }
}



# Test Connectivity to NetScalers
if (-not $disablenetscaler) {
    try {
        $nssession1 = Connect-NSAppliance -NSName $BIHash.NETSCALERHOST1 -NSUserName $BIHash.NETSCALERUSERNAME -NSPassword $BIHash.NETSCALERPASSWORD
        Log-Message "INFO" "Test Connection to $($BIHash.NETSCALERHOST1) (NetScaler Host 1) was successful"
        Disconnect-NSAppliance $nssession1
    } catch {
        Log-Message "ERROR" $_.Exception.Message
        Log-Message "ERROR" "Could not connect to $($BIHash.NETSCALERHOST1) (NetScaler Host 1). Exiting"
        ExitScript
    }
    
    try {
        $nssession2 = Connect-NSAppliance -NSName $BIHash.NETSCALERHOST2 -NSUserName $BIHash.NETSCALERUSERNAME -NSPassword $BIHash.NETSCALERPASSWORD
        Log-Message "INFO" "Test Connection to $($BIHash.NETSCALERHOST2) (NetScaler Host 2) was successful"
        Disconnect-NSAppliance $nssession2
    } catch {
        Log-Message "ERROR" $_.Exception.Message
        Log-Message "ERROR" "Could not connect to $($BIHash.NETSCALERHOST2) (NetScaler Host 2). Exiting"
        ExitScript
    }
}

#Perform checks for service availability prior to deploying VMs if needed

$domainadminpasswordsecure = ConvertTo-SecureString -String $BIhash.DOMAINADMINPASSWORD -AsPlainText -Force
$DomainAdminUser = $BIhash.DOMAINADMINUSERNAME
$DomainAdminCredential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $DomainAdminUser, $domainadminpasswordsecure

foreach ($vm in $Global_Vm_array) {

    if ($vm.VM_TYPE -match "ActiveDirectory" -and $vm.SERVERNUM -eq "01") {

        if (-not $pdcdeployed) {

            Log-Message "INFO" "Testing Connection to Primary Domain Controller"

            try {

                $script = 'Write-Host "Connection Success"'
                $invokevmscript = Invoke-VMScript -ScriptText $script -VM $vm.NEW_VM_NAME -GuestCredential $DomainAdminCredential -Server $vm.VCENTER_IP -ErrorAction Stop
                Log-Message "INFO" "Test Connection to Primary Domain Controller has succeeded"
        
            } catch {

                Log-Message "ERROR" "Could not connect to Primary Domain Controller.  Exiting"
                ExitScript
            }

        }

    }

    if (($vm.VM_TYPE -match "CVP_OAMP_") -and ($testcvpopsstatus)) {

        Log-Message "INFO" "Testing Connection to CVP Ops"

        try {
            
            $script = 'Write-Host "Connection Success"'
            $invokevmscript = Invoke-VMScript -ScriptText $script -VM $vm.NEW_VM_NAME -GuestCredential $DomainAdminCredential -Server $vm.VCENTER_IP -ErrorAction Stop
            Log-Message "INFO" "Test Connection to CVP Ops has succeeded"
        } catch {

            Log-Message "ERROR" "Could not connect to CVP Ops.  Exiting"
            ExitScript
        }
    }
}

# Init VM deployment arrays
$RunningTasks = @{}
#Map for caching the VMHost validation.
$VMHostValidationCache = @{}
#Map for caching the DataStore validation.
$DatastoreValidationCache = @{}
#Map for caching the Template validation.
$TemplateValidationCache = @{}


# Validate VM Data
$IsExcelDataValidationSuccessful = $false
$ExcelDataValidationErrMsg = ""

Log-Message -Type "INFO" -Message "Calling Validate_User_Input_Data to validate the VM input"

## In the future we could improve this function to validate all of the data is really good.  We could also clean up the logging
Validate_User_Input_Data_From_XL([REF]$IsExcelDataValidationSuccessful) ([REF]$ExcelDataValidationErrMsg)

if($IsExcelDataValidationSuccessful -eq $false) {
    
    Log-Message -Type "ERROR" -Message $ExcelDataValidationErrMsg
    Log-Message -Type "ERROR" -Message "Please correct the errors related to missing or invalid data provided in the input"
    ExitScript
}

Log-Message -Type "INFO" -Message "VM input validation was successful"

# Validate Publisher Data
$IsPublisherDataValidationSuccessful = $false
$PublisherDataValidationErrMsg = ""

Log-Message -Type "INFO" -Message "Calling ValidatePublisherDataAvailability to validate the Publisher data"

## In the future we could improve this function to validate all of the data is really good.  We could also clean up the logging
ValidatePublisherDataAvailability $Global_Vm_array ([REF]$IsPublisherDataValidationSuccessful) ([REF]$PublisherDataValidationErrMsg)

if($IsPublisherDataValidationSuccessful -eq $false) {
    Log-Message -Type "ERROR" -Message $PublisherDataValidationErrMsg
    Log-Message -Type "ERROR" -Message "Please correct the errors related to missing or invalid Publisher data provided"
    ExitScript
}

Log-Message -Type "INFO" -Message "Publisher data validation was successful"


# Validate vCenter Resource Availability

Log-Message -Type "INFO" -Message "Checking the availability of vCenter Resources..."

$IsResourceValidationSuccessful = $false
$ResourceValidationErrMsg = ""	

Validate_vCenter_Resource_Availability ([REF]$IsResourceValidationSuccessful) ([REF]$ResourceValidationErrMsg)

if($IsResourceValidationSuccessful -eq $true ) {
    Log-Message -Type "INFO" -Message $ResourceValidationErrMsg	
    					
    $ISDataFreeSpaceValidationSuccessful = $true
    $DataStoreFreeSpaceValidationErrMsg = ""
    					
    #calling Validate_DataStore_Space to validate the free space in the datastore.
    Validate_DataStore_Space ([REF]$ISDataFreeSpaceValidationSuccessful) ([REF]$DataStoreFreeSpaceValidationErrMsg)								
    					
    if($ISDataFreeSpaceValidationSuccessful -eq $true) {
    	$IsDeployVMSuccessful = $true
    	$IsDeployVMErrMsg = ""
    						
    	Log-Message -Type "INFO" -Message "All set! calling DeployVirtualMachines to deploy the selected VMs"
    	DeployVirtualMachines ([REF]$IsDeployVMSuccessful) ([REF]$IsDeployVMErrMsg)
    						
    	# calling Check_IF_VM_DEPLOYED to check whether VMs were deployed successfully
    	Check_IF_VM_DEPLOYED                 
    						
    	$IsCreatePlatformConfigXMLSuccessful = $false
    	$CreatePlatformConfigXMLErrMsg = ""
    	
        #calling CreatePlatformConfigXML for creating the PlatformConfig.XML for publisher and subscriber 
    	CreatePlatformConfigXML	$TimeStamp $Global_Vm_array ([REF]$IsCreatePlatformConfigXMLSuccessful) ([REF]$CreatePlatformConfigXMLErrMsg)
    	
        if($IsCreatePlatformConfigXMLSuccessful -eq $true) {                           
    	
    		Log-Message -Type "INFO" -Message "The PlatformConfig.xml generated by the tool are located in $HOME_PATH\PlatformConfigRepository\$TimeStamp"
    		PowerOnVM
                                
    	} else {
    	    Log-Message -Type "ERROR" -Message $CreatePlatformConfigXMLErrMsg
            ExitScript
    		
    	}
    }
    else {
    						
    	Log-Message -Type "ERROR" -Message $DataStoreFreeSpaceValidationErrMsg
    	ExitScript				
    }

} else {
    if ($ResourceValidationErrMsg -notmatch "succeeded") {
    	Log-Message -Type "ERROR" -Message $ResourceValidationErrMsg
	    Log-Message -Type "ERROR" -Message "Please correct the errors related to invalid source/destination host, source/destination datastore, template, VM Name provided and re-run the script"
    }
}

ExitScript
