[CmdletBinding()]
Param()

<#
.SYNOPSIS
This script might be useful if you have 2 differents array (like XtremIO and VNX) and you want to dedicate a VPLEX Director for each array.
All VMHosts and Datastores should have a tag on it.
You should set the same tag on all hosts within the same datacenter and you should tag the datastores based on the array type.
The seed of a VPLEX can be find in vplexcli with the command "ls -t /engines/*::wwn-seed".
#>

###VARIABLES

#vCenter's FQDN / IP
$vCenterName="vcenter.example.com"

#VMHosts Tags
$TagDC1 = 'DC1'
$TagDC2 = 'DC2'

#Datastore Tags
$TagArray1 = 'XtremIO'
$TagArray2 = 'VNX'

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
  $vcenter = Connect-VIServer $vCenterName -ErrorAction "Stop"
}
Catch{
  Write-Debug "Error while connecting to the vCenter: $($_.Exception.Message)"
  exit
}

#Set prefered path for datastores on host in DC1
Get-VMHost -Tag $TagDC1 | Set-VPLEXDatastorePreferedPath -Datastore (Get-Datastore -Tag $TagArray1) -Seed $SeedDC1 -Director 'A' -Confirm:$false
Get-VMHost -Tag $TagDC1 | Set-VPLEXDatastorePreferedPath -Datastore (Get-Datastore -Tag $TagArray2) -Seed $SeedDC1 -Director 'B' -Confirm:$false

#Set prefered path for datastores on host in DC2
Get-VMHost -Tag $TagDC2 | Set-VPLEXDatastorePreferedPath -Datastore (Get-Datastore -Tag $TagArray1) -Seed $SeedDC2 -Director 'A' -Confirm:$false
Get-VMHost -Tag $TagDC2 | Set-VPLEXDatastorePreferedPath -Datastore (Get-Datastore -Tag $TagArray2) -Seed $SeedDC2 -Director 'B' -Confirm:$false

#Get execution end time
$endDTM = (Get-Date)

Write-Verbose "Total script execution time: $(($endDTM-$startDTM).totalseconds) secondes"
