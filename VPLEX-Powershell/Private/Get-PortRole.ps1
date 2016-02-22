Function Get-PortRole {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true,HelpMessage = 'Merci de fournir l ID de l IO module')]
        [Int]$IOModuleID
    )

    Switch ($IOModuleID) {
      0 {$Role = "front-end"}
      1 {$Role = "back-end"}
      2 {$Role = "wan-com"}
      3 {$Role = "local-com"}
    }

    return $Role
}
