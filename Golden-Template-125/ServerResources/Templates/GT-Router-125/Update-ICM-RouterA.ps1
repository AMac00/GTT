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

Push-Location
$maxtimeinqueuereg = "HKLM:\SOFTWARE\Cisco Systems, Inc.\ICM\"+ $newInstanceName +"\RouterA\Router\CurrentVersion\Configuration\Queuing"
Set-Location $maxtimeinqueuereg
Set-ItemProperty . MaxTimeInQueue "604800"
Pop-Location

Write-Host Update maxrouterqueuetime is updated successfully