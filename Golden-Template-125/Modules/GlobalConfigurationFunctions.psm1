# Enable default switches, like Verbose & Debug for script call
[CmdletBinding()]
# Declaring script parameters
Param()

#Requires -Version 3
Set-StrictMode -Version Latest


function Get-GlobalCSVHeaders {
# Created: 20160912
    <#
    .SYNOPSIS
        Gets CSV Headers
    .DESCRIPTION
        Gets CSV Headers

    .EXAMPLE
        Get-GlobalCSVHeaders
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    [CmdletBinding()]
    param ()

    Write-Verbose "$($MyInvocation.MyCommand): Enter"

    $response = "VM_TYPE","CREATEVM","SERVERNUM","CLUSTERNUM","SERVERCODE","FOURTH_OCTET","NEW_VM_NAME","IP_ADDRESS_NIC1","VISIBLE_NAT_IP","IP_ADDRESS_NIC2","GOLDEN_TEMPLATE_NAME","AUTO_POWERON","DEST_HOST_IP","DEST_DATASTORE_NAME","CPU_COUNT","MEMORY","DISK_1_SIZE","DISK_2_SIZE","DISK_3_SIZE","DISK_4_SIZE","DISK_5_SIZE","DISK_6_SIZE","VM_DISKTYPE","JOIN_DOMAIN","OS_TYPE","VCENTER_IP","DATA_CENTER","PRODUCT_VERSION", "NIC_NUM", "SUB_NET_MASK_NIC1", "DEFAULT_GATEWAY_NIC1", "DNS_IP_NIC1", "DNS_NAT_IP_NIC1", "DNS_ALTERNATE_NIC1", "DNS_ALT_NAT_IP_NIC1", "SUB_NET_MASK_NIC2", "DEFAULT_GATEWAY_NIC2", "VM_NETWORK", "PRIV_NETWORK", "REMOTE_PRIVATE_SUBNET"

    Write-Verbose "$($MyInvocation.MyCommand): Exit"

    return $response
}

Function CIDR ($SubnetMask) {
    
    switch -wildcard ($SubnetMask) 
    { 
        "255.255.255.255" {"32"} 
        "255.255.255.254" {"31"} 
        "255.255.255.252" {"30"} 
        "255.255.255.248" {"29"} 
        "255.255.255.240" {"28"} 
        "255.255.255.224" {"27"} 
        "255.255.255.192" {"26"}
        "255.255.255.128" {"25"} 
        "255.255.255.0" {"24"} 
        default {""}
    }

}


function Get-GlobalCiscoCreds {
# Created: 20160912
    <#
    .SYNOPSIS
        Gets Users and Passwords
    .DESCRIPTION
        Gets Users and Passwords
    .PARAMETER VMType
        The VM Type to return creds for
    .PARAMETER CredEnvironment
        The Environment that the creds apply to
    .PARAMETER CredType
        The Credential Type to return creds for

    .EXAMPLE
        Get-GlobalCiscoCreds -VMType $VMType -CredEnvironment $CredEnvironment -CredType $CredType
    .NOTES
        Copyright (c) ttec. All rights reserved.
    #>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)] [String]$VMType,
        [Parameter(Mandatory=$true)] [String]$CredEnvironment,
        [Parameter(Mandatory=$true)] [ValidateSet("AdminUser","AdminPass","AppUser","AppPass","AppClearPass","AdminClearPass")] [string]$CredType
    )

    Write-Verbose "$($MyInvocation.MyCommand): Enter"

    switch -wildcard ($VMType)
	{
		"Cisco_IDS*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmidsadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="B5BBCCF7C71537339CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCSids123
				$AppAdminUserName ="idsadmin"
				$AppAdminPW ="B5BBCCF7C7153733DD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSids123!
                $AppAdminClearPW ="HCSids123!"
                $AdminAndClusterClearPW = "HCSids123"
            }

		} "LiveData*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmlivadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="BD02ACE7E22306919CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCSliv123
				$AppAdminUserName ="livadmin"
				$AppAdminPW ="BD02ACE7E2230691DD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSliv123!
                $AppAdminClearPW ="HCSliv123!"
                $AdminAndClusterClearPW = "HCSliv123"
            }

		} "VVB*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vvbadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="3175AA1E3EBBC8029CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCSvvb123
				$AppAdminUserName ="vvbadmin"
				$AppAdminPW ="3175AA1E3EBBC802DD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSvvb123!
                $AppAdminClearPW ="HCSvvb123!"
                $AdminAndClusterClearPW = "HCSvvb123"
            }

		} "FINESSE*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmfinadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="69FB71C9660802929CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCSfin123
				$AppAdminUserName ="finadmin"
				$AppAdminPW ="69FB71C966080292DD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSfin123!
                $AppAdminClearPW ="HCSfin123!"
                $AdminAndClusterClearPW = "HCSfin123"
            }

		} "CUIC*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmcuicadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="9E3C8878EEC3F1198A7617458D062783831812812AB2825C831812812AB2825C" #HCScuic123
				$AppAdminUserName ="cuicadmin"
				$AppAdminPW ="9E3C8878EEC3F119271C80E4DE008432831812812AB2825C831812812AB2825C" #HCScuic123!
                $AppAdminClearPW ="HCScuic123!"
                $AdminAndClusterClearPW = "HCScuic123"
            }

		} "CUCM*" {
                        
            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmccmadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="FBE1B70679E7D7B08A7617458D062783831812812AB2825C831812812AB2825C" #HCScucm123
				$AppAdminUserName ="ccmadmin"
				$AppAdminPW ="FBE1B70679E7D7B0271C80E4DE008432831812812AB2825C831812812AB2825C" #HCScucm123!
                $AppAdminClearPW ="HCScucm123!"
                $AdminAndClusterClearPW = "HCScucm123"
            }

		} "UNITY*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmcucadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="81478F06D078E4D19CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCScuc123
				$AppAdminUserName ="cucadmin"
				$AppAdminPW ="81478F06D078E4D1DD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCScuc123!
                $AppAdminClearPW ="HCScuc123!"
                $AdminAndClusterClearPW = "HCScuc123"
            }

		} "MEDIASENSE*" {
            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="medadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"

            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="9BD0BBD49DAC1D1B9CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCSmed123
				$AppAdminUserName ="medadmin"
				$AppAdminPW ="9BD0BBD49DAC1D1BDD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSmed123!
                $AppAdminClearPW ="HCSmed123!"
                $AdminAndClusterClearPW = "HCSmed123"
            }

		} "SOCIAL*" {
                
            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmcsmadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="7CF7935791291F2D9CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCSsoc123
				$AppAdminUserName ="socadmin"
				$AppAdminPW ="7CF7935791291F2DDD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSsoc123!
                $AppAdminClearPW ="HCSsoc123!"
                $AdminAndClusterClearPW = "HCSsoc123"
            }

		} "PRESENCE*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmccmadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="FBE1B70679E7D7B08A7617458D062783831812812AB2825C831812812AB2825C" #HCScucm123
				$AppAdminUserName ="ccmadmin"
				$AppAdminPW ="FBE1B70679E7D7B0271C80E4DE008432831812812AB2825C831812812AB2825C" #HCScucm123!
                $AppAdminClearPW ="HCScucm123!"
                $AdminAndClusterClearPW = "HCScucm123"
            }

		} "EXPRESS*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmucxadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AppAdminClearPW ="5t1xn5t0NEs"
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="7CD0C2E8AA6006C69CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCScucm123
				$AppAdminUserName ="ucxadmin"
				$AppAdminPW ="7CD0C2E8AA6006C6DD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSucx123!
                $AppAdminClearPW ="HCSucx123!"
                $AdminAndClusterClearPW = "HCScucm123"
            }

		} "Cloud_Connect*" {

            if ($CredEnvironment -eq "Verizon") {
                $AdminUserName ="administrator"
				$AdminAndClusterPW ="88C35403053A835AE8CDD13D04F5459B831812812AB2825C831812812AB2825C" #ver1zon@123
				$AppAdminUserName ="vzmclcadmin"
				$AppAdminPW ="CB5A8DCB93FD7688CF17AAB6A76E3360831812812AB2825C831812812AB2825C" #5t1xn5t0NEs
                $AdminAndClusterClearPW = "ver1zon@123"
            } else {
				$AdminUserName ="administrator"
				$AdminAndClusterPW ="EFEDEBCA80C3C3E89CF3C9E05C19356A831812812AB2825C831812812AB2825C" #HCSclc123
				$AppAdminUserName ="clcadmin"
				$AppAdminPW ="EFEDEBCA80C3C3E8DD527C65FCB8C664831812812AB2825C831812812AB2825C" #HCSclc123!
                $AppAdminClearPW ="HCSclc123!"
                $AdminAndClusterClearPW = "HCSclc123"
            }

		} Default {
            $AdminUserName = ""
			$AdminAndClusterPW = "" 
			$AppAdminUserName = ""
			$AppAdminPW = "" 
            $AppAdminClearPW = ""
            $AdminAndClusterClearPW = ""
        }
				
	}

    if ($CredType -eq "AdminUser") {
        $response =$AdminUserName
    } elseif ($CredType -eq "AdminPass") {
        $response = $AdminAndClusterPW
    } elseif ($CredType -eq "AppUser") {
        $response = $AppAdminUserName
    } elseif ($CredType -eq "AppPass") {
        $response = $AppAdminPW
    } elseif ($CredType -eq "AppClearPass") {
        $response = $AppAdminClearPW
    } elseif ($CredType -eq "AdminClearPass") {
        $response = $AdminAndClusterClearPW
    } else {
        $response = "NA"
    }
    
    Write-Verbose "$($MyInvocation.MyCommand): Exit"

    return $response

}