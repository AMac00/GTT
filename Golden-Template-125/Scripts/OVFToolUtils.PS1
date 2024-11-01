
###########################################################################################
#
#
#
#
##########################################################################################
Function Verify_OvfTool_Installed([REF]$Success, [REF]$OVFTool)
{
    
          
   foreach ($Toolpath in $OVFToolPath)  
    {  
        if(test-path $Toolpath)  
        {  
           $OVFTool.Value = $Toolpath 
           $Success.Value = $true
           

        }  

    }  
     if (!$OVFTool)  
    {
       $Success.Value = $false 
       LOG $INFO ($ERROR_ID_63)

    }
}

###########################################################################################
#
#
#
#
##########################################################################################

Function ExportOVF ($VCenter, $DataCenter,$VMName,$OVFFolderName,$OVFTool) #required datacenter name and VM name
{


        LOG $INFO "OVF Tool found in the path" $OVFTool 
        LOG $INFO "VMName =  $($VMName)"
        LOG $INFO "DataCenter = $($DataCenter)"
        LOG $INFO "VCenter = $($VCenter)"
        LOG $INFO "Vuser = $($Vuser)"
        $Vuser2=$Vuser
        if ($Vuser.Contains("\"))
	      {
          
          $Vuser2=$Vuser.replace("\","%5c")
	      
          }  
        
        LOG $INFO "Vuser2 = $($Vuser2)"
        # Create the Directory first, otherwise the ovftool will create TWO directories with the same name
        # But if the directory exists first, it will just put the ovf file there
        [IO.Directory]::CreateDirectory("$HOME_PATH\OVF\$OVFFolderName")

        #$cmd1 = "vi://administrator:HCScisco!123@10.77.62.9/HCS90/vm/kkk" example command
        #$cmd2 = " $HOME_PATH\OVF\$OVFFolderName\$OVFFolderName.ovf"
      
        
        LOG $INFO ("Running this command: $($OVFTool) --noSSLVerify vi://$($Vuser2):*********@$($VCenterIP)/$($DataCenter)/vm/$($VMName) $($HOME_PATH)\OVF\$OVFFolderName\$($OVFFolderName).ovf")
        & $OVFTool --noSSLVerify vi://$($Vuser2):$($Vpwd)@$($VCenterIP)/$($DataCenter)/vm/$($VMName) "$($HOME_PATH)\OVF\$OVFFolderName\$($OVFFolderName).ovf"
        LOG $INFO "Done exporting OVF..."

 }

###########################################################################################
#
#
#
#
##########################################################################################
 
Function ImportOVF ($DataCenter,$HostIP, $OVFFolderName, $VMNetwork, $DataStore, $VMName, $OVFTool)#datacenter hostip ovffolder vm network datastore vmname
 {
    $Vuser2=$Vuser

        if ($Vuser.Contains("\"))
	    {
             $Vuser2=$Vuser.replace("\","%5c")
	    }  
         $cmd1 = "vi://"+$Vuser2+":"+$Vpwd+"@"+$VCenterIP+"/"+$DataCenter+"/host/?dns="+$HostIP
         $cmd2 = "$($HOME_PATH)\OVF\$($OVFFolderName)\$($OVFFolderName).ovf"
         
         LOG $INFO ("Running this command: $($OVFTool) --noSSLVerify -nw=$($VMNetwork) -n=$($VMName) -ds=$($DataStore)  $($cmd2) " + "vi://"+$Vuser2+":*********@"+$VCenterIP+"/"+$DataCenter+"/host/?dns="+$HostIP)
         
         
         & $OVFTool --noSSLVerify "-nw=$($VMNetwork)" "-n=$($VMName)"  "-ds=$($DataStore)" "-dm=thick" $cmd2 $cmd1
 }
 
