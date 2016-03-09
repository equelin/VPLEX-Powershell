Function Get-VPLEXPortWWNCalculator {

  <#
  .SYNOPSIS
  Generate informations about VPLEX ports based from the seed provided.
  .DESCRIPTION
  Retrieve informations about VPLEX ports based from the seed provided. The seed of a VPLEX can be find in vplexcli with the command "ls -t /engines/*::wwn-seed".
  .NOTES
  Written by Erwan Quelin under MIT licence
  .LINK
  https://github.com/equelin/VPLEX-Powershell
  .PARAMETER Seed
  Specifies the seed of the VPLEX.The seed of a VPLEX can be find in vplexcli with the command "ls -t /engines/*::wwn-seed".
  .PARAMETER Director
  Specifies the ID of Director (A or B).
  .EXAMPLE
  Get-VPLEXPortWWNCalculator -Seed '47a01bdf'
  Generate a list of all the ports of a VPLEX
  .EXAMPLE
  Get-VPLEXPortWWNCalculator -Seed '47a01bdf','47a01bcc'
  Generate a list of all the ports of 2 different VPLEX
  .EXAMPLE
  Get-VPLEXPortWWNCalculator -Seed '47a01bdf' -DirectorID 'A'
  Generate the list of ports of Director A
  #>

  [CmdletBinding()]
  Param(
    [Parameter(Mandatory = $true,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Please provide one or more VPLEX Seed')]
    [ValidateScript(
      {
        If ($_ -match '^[A-Fa-f0-9]{8}$') {
          $True
        } Else {
          Throw "$_ must contains 8 hexadecimals characters"
        }
      }
    )]
    [String[]]$Seed,
    [Parameter(Mandatory = $false,HelpMessage = 'Please provide an ID of a VPLEX Director')]
    [ValidateSet('A','B')]
    [String[]]$Director = ('A','B')
  )

  Process {
    $Result = @()
    Foreach ($a in $Seed) {
      Foreach ($b in $Director) {
        $Result += Get-PortObject -Seed $a -Director $b
      }
    }
    $Result
  }
}
