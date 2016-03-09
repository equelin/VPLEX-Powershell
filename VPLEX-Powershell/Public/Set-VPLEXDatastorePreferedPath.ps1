Function Set-VPLEXDatastorePreferedPath {

  <#
  .SYNOPSIS
  Set datastore's prefered path.
  .DESCRIPTION
  Set datastore's prefered path. You can select the path with multiple argument like the VPLEX engine -based on the seed-, Director and/or Port.
  The function will select all the available paths matching your criteria and randomly select one.
  The seed of a VPLEX can be find in vplexcli with the command "ls -t /engines/*::wwn-seed".
  .NOTES
  Written by Erwan Quelin under MIT licence
  .LINK
  https://github.com/equelin/VPLEX-Powershell
  .PARAMETER VMHost
  Optionnal - One or more host. If the any host provided, all available host are selected.
  .PARAMETER Seed
  Mandatory - Specifies the seed of the VPLEX.The seed of a VPLEX can be find in vplexcli with the command "ls -t /engines/*::wwn-seed".
  .PARAMETER Director
  Specifies the ID of Director (A , B).
  .PARAMETER Port
  Specifies the ID of the Front-End IO Module port (0,1,2,3)
  .EXAMPLE
  Set-VPLEXDatastorePreferedPath -Seed '47a01bdf'
  Set the prefered path for all datastores on all hosts. The target is a random Front-End port on the VPLEX defined by the seed
  .EXAMPLE
  Set-VPLEXDatastorePreferedPath -VMHost 'esx1.example.com' -Datastore 'datastore1' -Seed 47a01bdf -Director 'A' -Port 0,1
  Set the prefered path for datastore 'datastore1' on esx 'esx1'. The VPLEX is defining by is seed. The prefered path will be on port 0 or 1 of the Director A
  #>

  [CmdletBinding(SupportsShouldProcess = $True,ConfirmImpact = 'High')]
  Param(
    [Parameter(Mandatory = $false,ValueFromPipeline=$True,ValueFromPipelinebyPropertyName=$True,HelpMessage = 'Please provide one or more ESXi Host')]
    $VMHost = (Get-VMHost),
    [Parameter(Mandatory = $false,HelpMessage = 'Please provide one or more Datastore')]
    $Datastore = (Get-Datastore | where { $_.ExtensionData.Info.Vmfs.Extent.DiskName -match "^naa.6000144" }),
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

        $lunTab = @{}

        #Populate hastable with LUN
        Try {
            $VMH | Get-ScsiLun | %{$lunTab.Add($_.CanonicalName,$_)}
            Write-Verbose "Retrieving LUN / Datastore infos on VMHost: $($VMH.Name)"
        }
            Catch {
            Write-Host "Error while trying to get the list of LUN / Datastores"
            Write-Host $_.Exception.Message
            exit
        }

        ForEach ($DS in $Datastore) {

          Write-Verbose "Retrieving informations on $DS"
          If ($DS = Get-Datastore $DS -ErrorAction "SilentlyContinue") {

            Write-Verbose "Examinating Datastore $($DS.Name) on host $($VMH.Name)"
            If (($DS | Get-VMHost $VMH.Name -ErrorAction "SilentlyContinue") -and ($DS.ExtensionData.Info.Vmfs.Extent.DiskName -like "naa.6000144*")) {

            $Path = Get-ScsiLunPath -ScsiLun $lunTab[$DS.ExtensionData.Info.Vmfs.Extent.DiskName]| where-Object { ($VPLEXPorts.WWN -contains $_.SanId) -and ($_.State -notlike "Dead")} #Get active's paths that match the demand

            If ($Path) {

                $PreferedPath = Get-Random -InputObject $Path #Random selection of the prefered path

                Write-Verbose "Trying to set the prefered path for datastore $($DS.Name) on VMHost $($VMH.Name). Path selected: $($PreferedPath.SanId)"

                Try {
                  If ($pscmdlet.ShouldProcess($PreferedPath.SanID, "Modify prefered path of datastore $DS on host $VMH")) {
                      Write-Verbose "Host: $($VMH.Name) LUN: $($LUN.CanonicalName) Chemin prefere: $($PreferedPath.SanID)"
                      $PreferedPath | Set-ScsiLunPath -Preferred #Set the prefered path
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
