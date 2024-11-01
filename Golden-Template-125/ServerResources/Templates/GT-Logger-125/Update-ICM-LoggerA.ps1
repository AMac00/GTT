$ServerInstance = $env:COMPUTERNAME
$DomainName = (Get-WmiObject Win32_ComputerSystem).Domain

$newInstanceName = $DomainName.Substring(0, $DomainName.IndexOf("."))
$pattern = '[^0-9]'
$newInstanceName = $newInstanceName -replace $pattern, '' 

$lastCharOfComputerName = $ServerInstance.Substring($ServerInstance.Length - 1)

if ($lastCharOfComputerName -eq "s") {
	$newInstanceName = "sb" + $newInstanceName
} else {
	$newInstanceName = "pd" + $newInstanceName
}

$Database = $newInstanceName + "_sideA"
$DomainName = "'$DomainName'"
Write-Host "Domain name is $DomainName"
Write-Host "Server name is $ServerInstance"
Write-Host "ICM Instance name is $newInstanceName"
Write-Host "Database name is $Database"


$ConnectionTimeout = 30
$Query1 = "select * from ICR_Globals"
$Query2 = "Update ICR_Globals set CCDomainName = {0}" -f $DomainName

$Query3 = "Update ICR_Instance set EnterpriseName = '{0}'" -f $newInstanceName

$QueryTimeout = 120

Function Execute_Query ($Query)
{
	$conn = New-Object System.Data.SQLClient.SQLConnection

	$ConnectionString = "Server={0};Database={1};Trusted_Connection=True;Connect Timeout={2}" -f $ServerInstance,$Database,$ConnectionTimeout

	$conn.ConnectionString  = $ConnectionString
	$conn.Open()

	$cmd = new-object system.Data.SqlClient.SqlCommand($Query,$conn)
	
	$cmd.CommandTimeout = $QueryTimeout

	$ds= New-Object system.Data.DataSet

	$da = New-Object System.Data.SqlClient.SqlDataAdapter($cmd) 
	[void]$da.fill($ds)

	$conn.Close()
	
	$ds.Tables
}

Write-Host
Write-Host ***************Displaying ICR_Globals***************
Execute_Query ($Query1)

Execute_Query ($Query2)

Execute_Query ($Query3)

Write-Host
Write-Host ***************Displaying ICR_Globals after update***************
Execute_Query ($Query1)

Write-Host Update domain is updated successfully