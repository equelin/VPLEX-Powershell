function Get-VPLEXPortFromSeed {
  [CmdletBinding()]
  Param(
      [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Merci de fournir le seed du VPLEX')]
      [string]$Seed,
      [Parameter(Mandatory = $false,HelpMessage = 'Merci de fournir le seed du VPLEX')]
      [String]$DirectorID
  )

  Process {
    $Result = @()

    If ($DirectorID) {
      $Result += Get-PortObject -DirectorID $DirectorID -Seed $Seed
    } else {
      $Result += Get-PortObject -DirectorID 'A' -Seed $Seed
      $Result += Get-PortObject -DirectorID 'B' -Seed $Seed
    }

    $Result
  }
}
