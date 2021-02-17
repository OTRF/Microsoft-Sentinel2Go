# Windows 10 + Windows Server (Active Directory) + Windows Server 2016 (MS Exchange)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-MXS%2Fazuredeploy.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-MXS%2Fazuredeploy.json)

## Grocery Items

* Azure Sentinel
    * Would you like to Bring-Your-Own Azure Sentinel?.
    * If so, set the `workspaceId` and `workspaceKey` parameters of your own workspace.
* One Windows Active Directory domain (One Domain Controller)
* One Windows Microsoft Exchange Server 2016 (One Server)
    * Admin mailbox audit logging enabled
    * Admin audit logging enabled (Every cmdlet and every parameter in the organization and Log Level set to `Verbose`)
* Microsoft Exchange 2016 Versions:
    * `MXS2016-x64-CU19-KB4588884` -> `ExchangeServer2016-x64-CU19.ISO`
    * `MXS2016-x64-CU18-KB4571788` -> `ExchangeServer2016-x64-cu18.iso`
    * `MXS2016-x64-CU17-KB4556414` -> `ExchangeServer2016-x64-cu17.iso`
    * `MXS2016-x64-CU16-KB4537678` -> `ExchangeServer2016-x64-CU16.ISO`
    * `MXS2016-x64-CU15-KB4522150` -> `ExchangeServer2016-x64-CU15.ISO`
    * `MXS2016-x64-CU14-KB4514140` -> `ExchangeServer2016-x64-cu14.iso`
    * `MXS2016-x64-CU13-KB4488406` -> `ExchangeServer2016-x64-cu13.iso`
* Windows 10 Workstations (Max. 10)
* Windows [Microsoft Monitoring Agent](https://docs.microsoft.com/en-us/services-hub/health/mma-setup) installed
    * It connects to the Azure Sentinel Log Analytics workspace defined in the template.
* SecurityEvents data connector enabled
* Windows event channels enabled
    * `System`
    * `Microsoft-Windows-Sysmon/Operational`
    * `Directory Service`
    * `Windows PowerShell`
    * `Microsoft-Windows-PowerShell/Operational`
    * `MSExchange Management`
* [OPTIONAL] Sysmon
    * [Sysmon Config](https://github.com/OTRF/Blacksmith/blob/master/resources/configs/sysmon/sysmon.xml)
* [OPTIONAL] Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `caldera`
    * `metasploit`