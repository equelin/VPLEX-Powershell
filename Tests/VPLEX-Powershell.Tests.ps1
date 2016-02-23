$here = Split-Path -Parent $MyInvocation.MyCommand.Path

$manifestPath = "$here\..\VPLEX-Powershell\VPLEX-Powershell.psd1"

Import-Module "$here\..\VPLEX-Powershell" -force

Describe -Tags 'VersionChecks' "VPLEX-Powershell manifest" {
    $script:manifest = $null
    It "has a valid manifest" {
        {
            $script:manifest = Test-ModuleManifest -Path $manifestPath -ErrorAction Stop -WarningAction SilentlyContinue
        } | Should Not Throw
    }

    It "has a valid name in the manifest" {
        $script:manifest.Name | Should Be VPLEX-Powershell
    }

    It "has a valid guid in the manifest" {
        $script:manifest.Guid | Should Be 'e4d0035d-b6a8-47be-9564-7e0344695954'
    }

    It "has a valid version in the manifest" {
        $script:manifest.Version -as [Version] | Should Not BeNullOrEmpty
    }
}

Describe 'Private function Get-VPLEXPortFromSeed' {
  InModuleScope VPLEX-Powershell {
    It 'Calls Get-VPLEXPortFromSeed with a valid seed' {
      $data = Get-VPLEXPortFromSeed -Seed '47a01bdf'
      $data.count | Should Be 32
    }

    It 'Calls Get-VPLEXPortFromSeed with a valid Seed and a valid Director A' {
      $data = Get-VPLEXPortFromSeed -Seed '47a01bdf' -Director 'A'
      $data.count | Should Be 16
    }

    It 'Calls Get-VPLEXPortFromSeed with a valid Seed and a valid Director B' {
      $data = Get-VPLEXPortFromSeed -Seed '47a01bdf' -Director 'B'
      $data.count | Should Be 16
    }

    It 'Calls Get-VPLEXPortFromSeed with a valid Seed and a wrong Director C' {
      {Get-VPLEXPortFromSeed -Seed '47a01bdf' -Director 'C'} | Should Throw
    }
  }
}
