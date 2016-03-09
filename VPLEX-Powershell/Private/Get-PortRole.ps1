Function Get-PortRole {
  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,HelpMessage = 'Please provide an ID of an IO Module - 0 to 3')]
    [ValidateSet(0,1,2,3)]
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
