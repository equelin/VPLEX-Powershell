function Get-DirectorHexID {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,HelpMessage = 'Please provide a VPLEX Seed')]
        [String]$Seed,
        [Parameter(Mandatory = $true,HelpMessage = 'Please provide an ID of a VPLEX Director')]
        [ValidateSet(0,1)]
        [Int]$Director
    )

    $a = [Convert]::ToInt32($seed[1], 16)
    $b = [Convert]::ToInt32($seed[2], 16)
    $c = (($a -band (0x1))*8) + ($b -band (0x1)) + (($b -band (0xc))/2)

    If ($Director -eq 1) { $c++ }

    $d = [Convert]::ToString($c, 16)

    return $d
}
