# VPLEX-Powershell

You will find some examples of how to use the functions provided by this module.

# Examples
### Set-VPLEXDatastorePreferedPathbyHostTag

This script set the prefered path for all the VPLEX datastores on hosts defined by a tag.
The tags represent the different datacenters, you should set the same tag on all hosts within the same datacenter.

A suitable tag configuration might looks like this:

```powershell
Host    Tag                    
----    ---                     
esx1    DC1
esx2    DC1
esx3    DC1
esx4    DC2
esx5    DC2
esx6    DC2
```

### Set-VPLEXDatastorePreferedPathbyHostAndArrayTag

This script might be useful if you have 2 differents array (like XtremIO and VNX) and you want to dedicate a VPLEX Director for each array.
All VMHosts and Datastores should have a tag on it.
You should set the same tag on all hosts within the same datacenter and you should tag the datastores based on the array type.

A suitable tag configuration might looks like this:

```powershell
Host    Tag                    
----    ---                     
esx1    DC1
esx2    DC1
esx3    DC1
esx4    DC2
esx5    DC2
esx6    DC2

Datastore          Tag                    
---------          ---                     
Datastore1         XtremIO
Datastore2         XtremIO
Datastore3         VNX
Datastore4         VNX
```
