#####################################################################################################
#
#
#
#
#####################################################################################################
Function PrintReportToConsole
{	
$VMType = "VMType"
$VMName = "VMName"
$Status = "Status"
$Description = "Description"

$VMDataNotAvailable = $true

	Write-Host "`r`n"
	Write-Host ********************** Status Report of VM deployment from Golden Template ****************************** -foregroundcolor cyan 
	Write-Host "`r"
	Write-Host "    " $VMType.padright(25," ") "    " $VMName.padright(30," ") $Status.padright(15," ") $Description.padright(95," ") -foregroundcolor cyan 
	Write-Host "`r"
	
	foreach ($VirtualMac in $Global_Vm_array)
	{
       
		if($VirtualMac.CREATEVM -like "YES" -or $VirtualMac.OPERATION -contains "ExportServer")
		{	
         
			$VMDataNotAvailable = $false			
			
			if($VirtualMac.TASK_STATUS -eq "Success")
			{	
				Write-Host $VirtualMac.VM_TYPE.padright(30," ") $VirtualMac.NEW_VM_NAME.padright(35," ")  $VirtualMac.TASK_STATUS.padright(15," ") $VirtualMac.ERROR_MESSAGE.padright(100," ") -foregroundcolor Green
				Write-Host "`r"
			}
			elseif(($VirtualMac.TASK_STATUS -eq "Error") -or ($VirtualMac.TASK_STATUS -eq "Failed"))
			{
				Write-Host $VirtualMac.VM_TYPE.padright(30," ") $VirtualMac.NEW_VM_NAME.padright(35," ")  $VirtualMac.TASK_STATUS.padright(15," ")     $VirtualMac.ERROR_MESSAGE.padright(100," ") -foregroundcolor Red
				Write-Host "`r"
			}
			else
			{
				Write-Host $VirtualMac.VM_TYPE.padright(30," ") $VirtualMac.NEW_VM_NAME.padright(35," ")  $VirtualMac.TASK_STATUS.padright(15," ")     $VirtualMac.ERROR_MESSAGE.padright(100," ")
				Write-Host "`r"
			}
		}
	}
	
	if($VMDataNotAvailable -eq $true)
	{
		Write-Host "`r"
		Write-Host "                    " User did not select any VMs for creation -foregroundcolor red
		Write-Host "`r"
	}
	
	Write-Host ********************************************************************************************************* -foregroundcolor cyan 
}
#####################################################################################################
#
#
#
#
#####################################################################################################

Function Create_Report_File($TimeStamp, $LogFile)
{
     
     
      $content = $content + "<HTML> <TITLE>STATUS REPORT </TITLE> <BODY BGCOLOR = SILVER> <H1>Status Report of Golden Template Tool</H1> <TABLE BORDER = 1>"				
      $content = $content + "<TR><TH> VM NAME </TH><TH> OPERATION </TH><TH> HOST IP </TH><TH> DATASTORE NAME </TH><TH> STATUS </TH><TH> DESCRIPTION </TH></TR>"
			
     
     foreach ($vm in $Global_Vm_array)
     {
		if($vm.CREATEVM -like "YES" -and $vm.OPERATION -eq "ImportServer"  )     
		{	
            $content = $content + "<TR><TD>" + $vm.NEW_VM_NAME + "</TD><TD>" + "CREATE VM from an OVF " + "</TD><TD>" + $vm.DEST_HOST_IP + "</TD><TD>" + $vm.DEST_DATASTORE_NAME + "</TD><TD>" + $vm.TASK_STATUS +"</TD><TD>" + $vm.ERROR_MESSAGE +"</TD></TR>" 
		}
        if($vm.CREATEVM -like "YES" -and $vm.OPERATION -ne "ExportServer" -and $vm.OPERATION -ne "ImportServer" )     
		{	
            $content = $content + "<TR><TD>" + $vm.NEW_VM_NAME + "</TD><TD>" + "CREATE VM from A Template" + "</TD><TD>" + $vm.DEST_HOST_IP + "</TD><TD>" + $vm.DEST_DATASTORE_NAME + "</TD><TD>" + $vm.TASK_STATUS +"</TD><TD>" + $vm.ERROR_MESSAGE +"</TD></TR>" 
		}
      
        if ($vm.OPERATION -contains "ExportServer" -and $vm.CREATEVM -like "No")
        {
            $content = $content + "<TR><TD>" + $vm.SOURCE_VMNAME + "</TD><TD>" + "Export VM to OVF" + "</TD><TD>" + "----" + "</TD><TD>" + "----"+ "</TD><TD>" + $vm.TASK_STATUS +"</TD><TD>" + $vm.ERROR_MESSAGE +"</TD></TR>"    
        }
        
        if ($vm.OPERATION -contains "ImportServer" -and $vm.CREATEVM -like "No")
        {
            $content = $content + "<TR><TD>" + $vm.GOLDEN_TEMPLATE_NAME + "</TD><TD>" + "Template from an OVF" + "</TD><TD>" + $vm.SOURCE_HOST_IP + "</TD><TD>" + $vm.SOURCE_DATASTORE_NAME + "</TD><TD>" + $vm.TASK_STATUS +"</TD><TD>" + $vm.ERROR_MESSAGE +"</TD></TR>"  
        }
        
        
     }
     
     $content = $content + "</TABLE><br/>"
	 $content = $content + "<a href=`"" + $LogFile + "`">Log File</a><br/>"
	 $content = $content + "</BODY>"
     Write_File $TimeStamp $content
}
#####################################################################################################
#
#
#
#
#####################################################################################################
Function Write_File ($TimeStamp, $content)
{    
	$FileName = "Report_" + $TimeStamp	+ ".html"
    $ReportFilePath = "$HOME_PATH\Report\" + $FileName
    Add-Content  $ReportFilePath  $content
}