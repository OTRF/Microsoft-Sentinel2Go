# Windows 10 + Windows Server (Domain Controller - Active Directory) + Windows Event Collector (WEC)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-WEC%2Fazuredeploy.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-WEC%2Fazuredeploy.json)

## Grocery Items

* Microsoft Sentinel
    * Would you like to Bring-Your-Own Microsoft Sentinel?.
    * If so, set the `workspaceId` and `workspaceKey` parameters of your own workspace.
    * [Windows Forwarded Events](https://docs.microsoft.com/en-us/azure/sentinel/data-connectors-reference#windows-forwarded-events-preview) data connector enabled
    * [Data collection rules (DCR)](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?tabs=json)
* One Windows Active Directory domain (One Domain Controller)
* One Windows Event Collector (WEC)
    * [WEC configured](https://github.com/OTRF/Blacksmith/blob/master/resources/scripts/powershell/auditing/Configure-WEC.ps1)
    * [Windows event subscriptions](https://github.com/OTRF/Blacksmith/tree/master/resources/configs/wef/subscriptions)
    * Windows [Azure Monitoring Agent](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview?tabs=PowerShellWindows) installed
        * It connects to the Microsoft Sentinel Log Analytics workspace defined in the template.
    * [Data Collection Rule (DCR) association](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent#data-collection-rule-associations)
* Windows 10 Workstations (Max. 10)
    * [Windows Event Forwarding (WEF) client configured](https://github.com/OTRF/Blacksmith/blob/master/resources/scripts/powershell/auditing/Configure-WEF-Client.ps1)
* [OPTIONAL] Sysmon
    * [Sysmon Config](https://github.com/OTRF/Blacksmith/blob/master/resources/configs/sysmon/sysmon.xml)
* [OPTIONAL] Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `caldera`
    * `metasploit`
    * `shad0w`
