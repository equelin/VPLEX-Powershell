# VPLEX-Powershell

This is a PowerShell module for working with EMC VPLEX. Most of the functions are useful in a VMware infrastructure.

Pull requests would be welcome!

# Prerequisite

You will need to first install VMware PowerCLI before importing this module. It can be downloaded on the WMware's website http://www.vmware.com.

# Instructions
### Install the module
```powershell
# One time setup
    # Download the repository
    # Unblock the zip
    # Extract the VPLEX-Powershell folder to a module path (e.g. $env:USERPROFILE\Documents\WindowsPowerShell\Modules\)

    #Simple alternative, if you have PowerShell 5, or the PowerShellGet module:
        Install-Module VPLEX-Powershell

# Import the module
    Import-Module VPLEX-Powershell    #Alternatively, Import-Module \\Path\To\VPLEX-Powershell

# Get commands in the module
    Get-Command -Module VPLEX-Powershell

# Get help
    Get-Help Get-VPLEXPortWWNCalculator -Full
    Get-Help VPLEX-Powershell
```

# Examples
### Setting prefered paths for VPLEX's datastores

```PowerShell
# Set the prefered path for datastore 'datastore1' on esx 'esx1'. The VPLEX is defining by is seed. The prefered path will be on port 0 or 1 of the Director A
    Connect-VIServer -Server vcenter.example.com
    Set-VPLEXDatastorePreferedPath -VMHost 'esx1.example.com' -Datastore 'datastore1' -Seed 47a01bdf -Director 'A' -Port 0,1
```

### Calculate VPLEX's ports WWN

```PowerShell
# Get VPLEX ports WWN based on the seed
    Get-VPLEXPortWWNCalculator -Seed '47a01bdf'

    Name    WWN                     Role      Director IOModule Port
    ----    ---                     ----      -------- -------- ----
    A0-FC00 50:00:14:42:C0:1B:DF:00 front-end A        0        0
    A0-FC01 50:00:14:42:C0:1B:DF:01 front-end A        0        1
    A0-FC02 50:00:14:42:C0:1B:DF:02 front-end A        0        2
    A0-FC03 50:00:14:42:C0:1B:DF:03 front-end A        0        3
    A1-FC00 50:00:14:42:C0:1B:DF:10 back-end  A        1        0
    A1-FC01 50:00:14:42:C0:1B:DF:11 back-end  A        1        1
    A1-FC02 50:00:14:42:C0:1B:DF:12 back-end  A        1        2
    A1-FC03 50:00:14:42:C0:1B:DF:13 back-end  A        1        3
    A2-FC00 50:00:14:42:C0:1B:DF:20 wan-com   A        2        0
    A2-FC01 50:00:14:42:C0:1B:DF:21 wan-com   A        2        1
    A2-FC02 50:00:14:42:C0:1B:DF:22 wan-com   A        2        2
    A2-FC03 50:00:14:42:C0:1B:DF:23 wan-com   A        2        3
    A3-FC00 50:00:14:42:C0:1B:DF:30 local-com A        3        0
    A3-FC01 50:00:14:42:C0:1B:DF:31 local-com A        3        1
    A3-FC02 50:00:14:42:C0:1B:DF:32 local-com A        3        2
    A3-FC03 50:00:14:42:C0:1B:DF:33 local-com A        3        3
    B0-FC00 50:00:14:42:D0:1B:DF:00 front-end B        0        0
    B0-FC01 50:00:14:42:D0:1B:DF:01 front-end B        0        1
    B0-FC02 50:00:14:42:D0:1B:DF:02 front-end B        0        2
    B0-FC03 50:00:14:42:D0:1B:DF:03 front-end B        0        3
    B1-FC00 50:00:14:42:D0:1B:DF:10 back-end  B        1        0
    B1-FC01 50:00:14:42:D0:1B:DF:11 back-end  B        1        1
    B1-FC02 50:00:14:42:D0:1B:DF:12 back-end  B        1        2
    B1-FC03 50:00:14:42:D0:1B:DF:13 back-end  B        1        3
    B2-FC00 50:00:14:42:D0:1B:DF:20 wan-com   B        2        0
    B2-FC01 50:00:14:42:D0:1B:DF:21 wan-com   B        2        1
    B2-FC02 50:00:14:42:D0:1B:DF:22 wan-com   B        2        2
    B2-FC03 50:00:14:42:D0:1B:DF:23 wan-com   B        2        3
    B3-FC00 50:00:14:42:D0:1B:DF:30 local-com B        3        0
    B3-FC01 50:00:14:42:D0:1B:DF:31 local-com B        3        1
    B3-FC02 50:00:14:42:D0:1B:DF:32 local-com B        3        2
    B3-FC03 50:00:14:42:D0:1B:DF:33 local-com B        3        3
```

### Retrieving statistics on VPLEX's datastores prefered paths

```PowerShell
# Retrieving statistics on all VPLEX's datastores
    Connect-VIServer -Server vcenter.example.com
    Get-VPLEXDatastorePreferedPathStats

    SanID                        Paths  Percentage
    -----                        -----  -----------
    50:00:14:42:C0:1B:BC:00      16     7,27
    50:00:14:42:C0:1B:BC:01      18     8,18
    50:00:14:42:C0:1B:DF:00      48     21,82
    50:00:14:42:C0:1B:DF:01      29     13,18
    50:00:14:42:D0:1B:BC:00      20     9,09
    50:00:14:42:D0:1B:BC:01      12     5,45
    50:00:14:42:D0:1B:DF:00      41     18,64
    50:00:14:42:D0:1B:DF:01      36     16,36
```

# Available functions

- Set-VPLEXDatastorePreferedPath
- Get-VPLEXPortWWNCalculator
- Get-VPLEXDatastorePreferedPathStats

# Author

**Erwan Quélin**
- <https://github.com/equelin>
- <https://twitter.com/erwanquelin>

# License

Licensed under the MIT License (MIT)

Copyright (c) 2016 Erwan Quélin

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
