# Azure Sentinel To-Go + Windows 10 Environment

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fwin10%2Fazuredeploy.json)

## Grocery Items

* Azure Sentinel
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
