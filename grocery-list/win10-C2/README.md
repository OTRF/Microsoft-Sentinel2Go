# Azure Sentinel To-Go + Win10 + Command and Control (C2)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fwin10-C2%2Fazuredeploy.json)

## Grocery Items

* Azure Sentinel
* Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `caldera`
    * `metasploit`
    * `shad0w`
* Windows 10 Workstations
* Log Analytics agent installed
* SecurityEvents data connector enabled
* Windows event providers enabled
    * `System`
    * `Microsoft-Windows-Sysmon/Operational`
    * `Microsoft-Windows-TerminalServices-RemoteConnectionManager/Operational`
    * `Microsoft-Windows-Bits-Client/Operational`
    * `Microsoft-Windows-TerminalServices-LocalSessionManager/Operational`
    * `Directory Service`
    * `Microsoft-Windows-DNS-Client/Operational`
    * `Microsoft-Windows-Windows Firewall With Advanced Security/Firewall`
    * `Windows PowerShell`
    * `Microsoft-Windows-PowerShell/Operational`
    * `Microsoft-Windows-WMI-Activity/Operational`
* [OPTIONAL] Sysmon
    * [Sysmon Config](https://github.com/hunters-forge/Blacksmith/blob/master/resources/configs/sysmon/sysmon.xml)