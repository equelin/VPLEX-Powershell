Function Get-PortObject {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,HelpMessage = 'Please provide a VPLEX Seed')]
    [string]$Seed,
    [Parameter(Mandatory = $true,HelpMessage = 'Please provide an ID of a VPLEX Director - A or B')]
    [ValidateSet('A','B')]
    [String]$Director

  )

  Switch ($Director) {
    'A' {$SanId = '50001442' + (Get-DirectorHexID -Seed $Seed -Director 0) + $seed.Substring(3)}
    'B' {$SanId = '50001442' + (Get-DirectorHexID -Seed $Seed -Director 1) + $seed.Substring(3)}
  }

  $colPorts = @()

  For ($IOModuleID=0; $IOModuleID -le 3; $IOModuleID++) {
    For ($PortID=0; $PortID -le 3; $PortID++) {

      $PortName = $Director + $IOModuleID + '-FC0' + $PortID
      $PortWWN = (($SanId + $IOModuleID + $PortID) -replace '(..)','$1:').trim(':')
      $PortRole = Get-PortRole -IOModuleID $IOModuleID

      $objPort = New-Object System.Object
      $objPort | Add-Member -type NoteProperty -name Name -value $PortName
      $objPort | Add-Member -type NoteProperty -name WWN -value $PortWWN.ToUpper()
      $objPort | Add-Member -type NoteProperty -name Role -value $PortRole
      $objPort | Add-Member -type NoteProperty -name Director -value $Director
      $objPort | Add-Member -type NoteProperty -name IOModule -value $IOModuleID
      $objPort | Add-Member -type NoteProperty -name Port -value $PortID
      $objPort.PSObject.TypeNames.Insert(0,'VPLEX.Ports')
      $colPorts += $objPort
    }
  }

  return $colPorts
}
