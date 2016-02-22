Function Get-PortObject {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,HelpMessage = 'Merci de fournir l ID du Director')]
        [String]$DirectorID,
        [Parameter(Mandatory = $true,HelpMessage = 'Merci de fournir le seed du VPLEX')]
        [string]$Seed
    )

    Switch ($DirectorID) {
      'A' {$SanId = '50001442' + (Get-DirectorHexID -Seed $Seed -Director 0) + $seed.Substring(3)}
      'B' {$SanId = '50001442' + (Get-DirectorHexID -Seed $Seed -Director 1) + $seed.Substring(3)}
    }

    $colPorts = @()

    For ($IOModuleID=0; $IOModuleID -le 3; $IOModuleID++) {
      For ($PortID=0; $PortID -le 3; $PortID++) {

        $PortName = $DirectorID + $IOModuleID + '-FC0' + $PortID
        $PortWWN = (($SanId + $IOModuleID + $PortID) -replace '(..)','$1:').trim(':')
        $PortRole = Get-PortRole -IOModuleID $IOModuleID

        $objPort = New-Object System.Object
        $objPort | Add-Member -type NoteProperty -name Name -value $PortName
        $objPort | Add-Member -type NoteProperty -name WWN -value $PortWWN.ToUpper()
        $objPort | Add-Member -type NoteProperty -name Role -value $PortRole
        $objPort.PSObject.TypeNames.Insert(0,'VPLEX.Ports')
        $colPorts += $objPort
      }
    }

    return $colPorts
}
