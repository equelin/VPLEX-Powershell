[CmdletBinding()]
Param()

###VARIABLES

#vCenter's FQDN / IP
$vCenterName="vcenter.example.com"

#VMHosts Tags
$TagDC1 = 'BMT'
$TagDC2 = 'BH'

#VPLEX Seed
$SeedDC1 = '47a01bdf'
$SeedDC2 = '47a01bbc'

########## DO NOT EDIT BEYOND THIS LINE ##########

###SCRIPT

#Get execution start time
$startDTM = (Get-Date)

#Import PowerCLI Snapin
Try{
  Add-PsSnapin VMware.VimAutomation.Core -ErrorAction "SilentlyContinue"
}
Catch{
  Write-Debug "Error while loading PowerCLI: $($_.Exception.Message)"
  exit
}

#Import VPLEX-Powershell module
Try{
  Import-Module "VPLEX-Powershell" -ErrorAction "Stop"
}
Catch{
  Write-Debug "Error while importing module VPLEX-Powershell: $($_.Exception.Message)"
  exit
}

#Connection to the vCenter
Try{
  Set-PowerCLIConfiguration -DefaultVIServerMode multiple -Confirm:$false -Scope Session
  $vcenter = Connect-VIServer $vCenterName -ErrorAction "Stop"
}
Catch{
  Write-Debug "Error while connecting to the vCenter: $($_.Exception.Message)"
  exit
}

#Set prefered path for datastores on host in DC1
Get-VMHost -Tag $TagDC1 | Set-VPLEXDatastorePreferedPath -Seed $SeedDC1 -WhatIf -Verbose -Confirm:$false

#Set prefered path for datastores on host in DC2
Get-VMHost -Tag $TagDC2 | Set-VPLEXDatastorePreferedPath -Seed $SeedDC2 -WhatIf -Verbose -Confirm:$false

#Get execution end time
$endDTM = (Get-Date)

Write-Verbose "Total script execution time: $(($endDTM-$startDTM).totalseconds) secondes"
