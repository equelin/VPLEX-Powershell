Function Get-VPLEXDatastorePreferedPathStats {

  <#
  .SYNOPSIS
  Generate statistics on VPLEX's datastores prefered paths.
  .DESCRIPTION
  Generate statistics on VPLEX's datastores prefered paths.
  .NOTES
  Written by Erwan Quelin under MIT licence
  .LINK
  https://github.com/equelin/VPLEX-Powershell
  .PARAMETER VMHost
  Specify one or more VMHost.
  .EXAMPLE
  Get-VPLEXDatastorePreferedPathStats
  Generate statisitcs on all hosts and all datastores
  .EXAMPLE
  Get-VPLEXDatastorePreferedPathStats -VMHost 'esx1.example.com'
  Generate statisitcs on all datastore og host 'esx1.example.com'
  #>

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $false,HelpMessage = 'Please provide one or more ESXi Host')]
    $VMHost = (Get-VMHost)
  )

  #Variable's initialization
  $i = 0
  $result = @{}

  #Working on each host
  ForEach ($VMH in $VMHost) {

    If ($VMH = Get-VMHost $VMH -ErrorAction "SilentlyContinue") { #Verifying if host exist

      Write-Verbose "Working on host $($VMH.Name)"

      $Datastores = $VMH | Get-Datastore | where { $_.ExtensionData.Info.Vmfs.Extent.DiskName -match "^naa.6000144" } #Retrieving VPLEX's datastores

      #Working on each datastores connected to the host
      ForEach ($DS in $Datastores) {

        Write-Verbose "Working on datastore $($DS.Name)"

        $LUN = Get-ScsiLUN -VMHost $VMH -CanonicalName $DS.ExtensionData.Info.Vmfs.Extent.DiskName # Retrieving lun

        $Path = Get-ScsiLunPath -ScsiLun $LUN| where-Object { $_.Preferred -eq $true } #Retrieving prefered lun path

        $i++ #Increment path total count

        $result[$path.SanID] = $result[$path.SanID] + 1 #Increment path count for the specific SanID

      }
    } else {Write-Verbose "Host $VMH does not exist or is not reachable"}
  }

  Write-Verbose "Formating result"
  ForEach ($key in ($result.keys | Sort-Object)) {

    $object = New-Object -TypeName PSObject
    Add-Member -InputObject $object -MemberType NoteProperty -Name SanID -Value $key
    Add-Member -InputObject $object -MemberType NoteProperty -Name Paths -Value $result[$key]
    Add-Member -InputObject $object -MemberType NoteProperty -Name Percentage -Value ([math]::round((($result[$key] * 100) / $i),2))

    Write-Output $object
  }

  Write-Verbose "Total paths: $i"

}
