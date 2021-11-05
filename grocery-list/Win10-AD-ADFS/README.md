# Windows 10 + Windows Server (Active Directory) + Windows Server (Active Directory Federation Services)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-ADFS%2Fazuredeploy.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-AD-ADFS%2Fazuredeploy.json)

## Grocery Items

* Microsoft Sentinel
    * Would you like to Bring-Your-Own Microsoft Sentinel?.
    * If so, set the `workspaceId` and `workspaceKey` parameters of your own workspace.
* One Windows Active Directory domain (One Domain Controller)
    * Active Directory Certificate Services (AD CS) Certification Authority (CA) role service enabled
    * Enterprise Root Certificate Authority created
    * ADFS Site Certificate created
    * ADFS Signing Certificate created
    * ADFS Decryption Certificate created
    * SMB share C:\Setup created to distribute ADFS certificates (.CER & .PFX files)
        * Full Access: Domain Admins & Domain Computers
        * Read Access: Authenticated Users
    * ADFS service account created
    * Azure Active Directory (AAD) Connect installed
* One Windows Active Directory Federation Services (ADFS) server
    * Active Directory Federation Services Role Service enabled
    * ADFS .pfx certificate retrieved from DC C:\Setup share
    * ADFS farm installed
    * Idp-Initiated Sign On page enabled
    * ADFS WebContent customized (Title, Web Theme, SignIn description)
    * ADFS Logging (SuccessAudits & FailureAudits) enabled
    * ADFS Auditing
        * Level: Verbose
        * Auditpol command: auditpol.exe /set /subcategory:"Application Generated" /failure:enable /success:enable
    * Azure Active Directory (AAD) Connect installed
* Windows 10 Workstations (Max. 10)
* Windows [Azure Monitoring Agent](https://docs.microsoft.com/en-us/azure/azure-monitor/agents/azure-monitor-agent-overview?tabs=PowerShellWindows) installed
    * It connects to the Microsoft Sentinel Log Analytics workspace defined in the template.
* [Windows Security Events via AMA](https://docs.microsoft.com/en-us/azure/sentinel/data-connectors-reference#windows-security-events-via-ama) data connector enabled
* Windows event channels enabled
    * `System`
    * `Microsoft-Windows-Sysmon/Operational`
    * `Directory Service`
    * `Windows PowerShell`
    * `Microsoft-Windows-PowerShell/Operational`
    * `AD FS/Admin`
* [OPTIONAL] Sysmon
    * [Sysmon Config](https://github.com/OTRF/Blacksmith/blob/master/resources/configs/sysmon/sysmon.xml)
* [OPTIONAL] Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `caldera`
    * `metasploit`
    * `shad0w`
