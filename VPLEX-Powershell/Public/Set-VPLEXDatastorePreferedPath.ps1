Function Set-VPLEXDatastorePreferedPath {

  <#
  .SYNOPSIS
  Set datastore's prefered path.
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Please provide one or more ESXi Host')]
    $VMHost = (Get-VMHost),
    [Parameter(Mandatory = $false,HelpMessage = 'Please provide one or more Datastore')]
    $Datastore = (Get-Datastore),
    [Parameter(Mandatory = $true,HelpMessage = 'Please provide one VPLEX Seed')]
    [ValidateScript(
    {
      If ($_ -match '^[A-Fa-f0-9]{8}$') {
        $True
      } Else {
        Throw "$_ must contains 8 hexadecimals characters"
      }
    }
    )]
    [String]$Seed,
    [Parameter(Mandatory = $false,HelpMessage = 'Please provide an ID of a VPLEX Director')]
    [ValidateSet('A','B')]
    [String[]]$Director = ('A','B'),
    [Parameter(Mandatory = $false,HelpMessage = 'Please provide an ID of a IO Module Port')]
    [ValidateSet(0,1,2,3)]
    [Int[]]$Port = @(0,1,2,3)
  )
  Begin {
    $VPLEXPorts = Get-VPLEXPortWWNCalculator -Seed $Seed -Director $Director | Where-Object {($_.IOModule -Match 0) -and ($Port -contains $_.Port)} #Get VPLEX's Ports from the seed provided
  }

  Process {
  ForEach ($VMH in $VMHost) {

    Write-Verbose "Retrieving informations on $VMH"
      If ($VMH = Get-VMHost $VMH -ErrorAction "SilentlyContinue") {

        ForEach ($DS in $Datastore) {

          Write-Verbose "Retrieving informations on $DS"
          If ($DS = Get-Datastore $DS -ErrorAction "SilentlyContinue") {

            Write-Verbose "Examinating Datastore $($DS.Name) on host $($VMH.Name)"
            If (($DS | Get-VMHost $VMH.Name -ErrorAction "SilentlyContinue") -and ($DS.ExtensionData.Info.Vmfs.Extent.DiskName -like "naa.6000144*")) {

            Try {
              $LUN = Get-ScsiLUN -VMHost $VMH -CanonicalName $DS.ExtensionData.Info.Vmfs.Extent.DiskName | where { $_.CanonicalName -match "^naa.6000144" }
              Write-Verbose "Retrieving LUN / Datastore infos. VMHost: $($VMH.Name) Datastore: $($DS.Name) CanonicalName: $($LUN.CanonicalName)"
            }
            Catch {
              Write-Host "Error while trying to get the list of LUN / Datastores"
              Write-Host $_.Exception.Message
              exit
            }

            $Path = Get-ScsiLunPath -ScsiLun $LUN| where-Object { ($VPLEXPorts.WWN -contains $_.SanId) -and ($_.State -notlike "Dead")} #Get active's paths that match the demand

            If ($Path) {

                $PreferedPath = Get-Random -InputObject $Path #Random selection of the prefered path

                Write-Verbose "Trying to set the prefered path for datastore $($DS.Name) on VMHost $($VMH.Name). Path selected: $($PreferedPath.SanId)"

                Try {
                  If ($pscmdlet.ShouldProcess($VMH.Name, "Modify prefered path")) {
                      Write-Verbose "Host: $($VMH.Name) LUN: $($LUN.CanonicalName) Chemin prefere: $($PreferedPath.SanID)"
                      $PreferedPath #| Set-ScsiLunPath -Preferred #Set the prefered path
                  }
                }
                Catch {
                  Write-Host "Error while trying to change the prefered path"
                  Write-Host "Host: $($VMH.Name) LUN: $($LUN.CanonicalName)"
                  Write-Host $_.Exception.Message
                }
              }
            }
          } else {Write-Verbose "Datastore $DS does not exist or is not attached to host $($VMH.Name)"}
        }
      } else {Write-Verbose "Host $VMH does not exist or is not reachable"}
    }
  }
}
