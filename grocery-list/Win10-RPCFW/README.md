# Windows 10 + Domain Controller + Windows Event Collector (WEC) + RPC Firewall Project 

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-RPCFW%2Fazuredeploy.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-RPCFW%2Fazuredeploy.json)

## Grocery Items

* Microsoft Sentinel
    * Would you like to Bring-Your-Own Microsoft Sentinel?.
    * If so, set the `workspaceId` and `workspaceKey` parameters of your own workspace.
    * [Windows Security Events via AMA](https://docs.microsoft.com/en-us/azure/sentinel/data-connectors-reference#windows-security-events-via-ama) data connector enabled.
    * [Data collection rule (DCR)](https://docs.microsoft.com/en-us/azure/templates/microsoft.insights/datacollectionrules?tabs=json) to collect Windows Security events.
    * [Windows RPC Firewall parser](https://raw.githubusercontent.com/OTRF/Microsoft-Sentinel2Go/master/microsoft-sentinel/linkedtemplates/parsers/winRPCFWLogs.json).
* One Windows Active Directory domain (One Domain Controller)
    * [Data Collection Rule (DCR) association](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent#data-collection-rule-associations)
    * Windows [Azure Monitoring Agent](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview?tabs=PowerShellWindows) installed. It connects to the Microsoft Sentinel Log Analytics workspace defined in the template.
    * [RPC Firewall](https://github.com/zeronetworks/rpcfirewall) installed.
    * [RPC Firewall config](https://github.com/OTRF/Blacksmith/blob/master/resources/configs/rpcfirewall/RpcFw.conf) used.
* One Windows Event Collector (WEC)
    * Windows [Azure Monitoring Agent](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview?tabs=PowerShellWindows) installed. It connects to the Microsoft Sentinel Log Analytics workspace defined in the template.
    * [Data Collection Rule (DCR) association](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent#data-collection-rule-associations)
    * [WEC configured](https://github.com/OTRF/Blacksmith/blob/master/resources/scripts/powershell/auditing/Configure-WEC.ps1).
    * [Application Windows event subscriptions](https://github.com/OTRF/Blacksmith/tree/master/resources/configs/wef/subscriptions) deployed.
* Windows 10 Workstations (Max. 10)
    * [Data Collection Rule (DCR) association](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/data-collection-rule-azure-monitor-agent#data-collection-rule-associations)
    * Windows [Azure Monitoring Agent](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview?tabs=PowerShellWindows) installed. It connects to the Microsoft Sentinel Log Analytics workspace defined in the template.
    * [Windows Event Forwarding (WEF) client configured](https://github.com/OTRF/Blacksmith/blob/master/resources/scripts/powershell/auditing/Configure-WEF-Client.ps1).
    * [RPC Firewall](https://github.com/zeronetworks/rpcfirewall) installed.
    * [RPC Firewall config](https://github.com/OTRF/Blacksmith/blob/master/resources/configs/rpcfirewall/RpcFw.conf) used.
* [OPTIONAL] Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `metasploit`
* Remote Access Restrictions (`AllowPublicIP` default option)
    * Access via Azure Bastion (Recommended. Additional costs applied)
    * Restrict Access to one Public IP Address (For example, Home Public IP Address)