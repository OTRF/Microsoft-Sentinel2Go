# Microsoft Sentinel + Linux (Ubuntu, CentOS, Red Hat)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FLinux%2Fazuredeploy.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FLinux%2Fazuredeploy.json)

## Grocery Items

* Microsoft Sentinel
    * Would you like to Bring-Your-Own Microsoft Sentinel?.
    * If so, set the `workspaceId` and `workspaceKey` parameters of your own workspace.
* Linux VMs
    * `Ubuntu`
    * `Centos` [OPTIONAL]
    * `Red hat` [OPTIONAL]
* Windows [Microsoft Monitoring Agent](https://docs.microsoft.com/en-us/services-hub/health/mma-setup) installed
    * It connects to the Microsoft Log Analytics workspace define in the template.
* Syslog Data Connection enabled
* Linux Syslog Facilities
    * `auth`
    * `authpriv`
    * `cron`
    * `daemon`
    * `ftp`
    * `kern`
    * `user`
* [OPTIONAL] Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `caldera`
    * `metasploit`
    * `shad0w`
