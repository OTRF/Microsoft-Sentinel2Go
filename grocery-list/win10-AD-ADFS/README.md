# Windows 10 + Windows Server (Active Directory) + Windows Server (Active Directory Federation Services)

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fwin10-AD-ADFS%2Fazuredeploy.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2Fwin10-AD-ADFS%2Fazuredeploy.json)

## Grocery Items

* Azure Sentinel
    * Would you like to Bring-Your-Own Azure Sentinel?.
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
* Windows [Microsoft Monitoring Agent](https://docs.microsoft.com/en-us/services-hub/health/mma-setup) installed
    * It connects to the Microsoft Log Analytics workspace define in the template.
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
    * `Microsoft-Windows-TaskScheduler/Operational`
    * `AD FS/Admin`
* [OPTIONAL] Sysmon
    * [Sysmon Config](https://github.com/OTRF/Blacksmith/blob/master/resources/configs/sysmon/sysmon.xml)
* [OPTIONAL] Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `caldera`
    * `metasploit`
    * `shad0w`

## Enable Additional Telemetry [OPTIONAL]

Assuming an adversary would try to read the ADFS DKM key from Active Directory (AD), I would recommend to create an Audit rule on the ADFS DKM container:

* RDP to Domain Controller
* Open PowerShell as Administrator
* Import Active Directory module

```PowerShell
Import-Module ActiveDirectory
```

* Import `Set-AuditRule` from the GitHub project [Se-AuditRule](https://github.com/OTRF/Set-AuditRule)

```PowerShell
IEX (New-Object Net.WebClient).DownloadString('https://raw.githubusercontent.com/OTRF/Set-AuditRule/master/Set-AuditRule.ps1')`
```

* Set an audit rule to monitor for any user reading the property attribute `thumbnailPhoto` from the DKM container

```PowerShell
Set-AuditRule -AdObjectPath 'AD:\CN=CryptoPolicy,CN=ADFS,CN=Microsoft,CN=Program Data,DC=azsentinel,DC=local' -WellKnownSidType WorldSid -Rights GenericRead -InheritanceFlags None -AuditFlags Success -AttributeGUID '8d3bca50-1d7e-11d0-a081-00aa006c33ed'
````

After that, you could read the DKM key as a byte array and convert it to a usable string from AD by running the following command:

```PowerShell
$key=(Get-ADObject -filter 'ObjectClass -eq "Contact" -and name -ne "CryptoPolicy"' -SearchBase "CN=ADFS,CN=Microsoft,CN=Program Data,DC=azsentinel,DC=local" -Properties thumbnailPhoto).thumbnailPhoto

[System.BitConverter]::ToString($key)
```

**Results: Windows Security Event 4662**

```xml
- <Event xmlns="http://schemas.microsoft.com/win/2004/08/events/event"> 
- <System> 
<Provider Name="Microsoft-Windows-Security-Auditing" Guid="{54849625-5478-4994-a5ba-3e3b0328c30d}" /> 
<EventID>4662</EventID> 
<Version>0</Version> 
<Level>0</Level> 
<Task>14080</Task> 
<Opcode>0</Opcode> 
<Keywords>0x8020000000000000</Keywords> 
<TimeCreated SystemTime="2020-12-20T07:53:41.092054600Z" /> 
<EventRecordID>330446</EventRecordID> 
<Correlation /> 
<Execution ProcessID="708" ThreadID="836" /> 
<Channel>Security</Channel> 
<Computer>DC01.azsentinel.local</Computer> 
<Security /> 
</System> 
- <EventData> 
<Data Name="SubjectUserSid">S-1-5-21-1640822366-3528877384-3060188657-1103</Data> 
<Data Name="SubjectUserName">adfsuser</Data> 
<Data Name="SubjectDomainName">AZSENTINEL</Data> 
<Data Name="SubjectLogonId">0x4235ba</Data> 
<Data Name="ObjectServer">DS</Data> 
<Data Name="ObjectType">%{5cb41ed0-0e4c-11d0-a286-00aa003049e2}</Data> 
<Data Name="ObjectName">%{8cd0a7fa-b3c9-4572-85e5-9359c2783031}</Data> 
<Data Name="OperationType">Object Access</Data> 
<Data Name="HandleId">0x0</Data> 
<Data Name="AccessList">%%7684</Data> 
<Data Name="AccessMask">0x10</Data> 
<Data Name="Properties">%%7684 {77b5b886-944a-11d1-aebd-0000f80367c1} {8d3bca50-1d7e-11d0-a081-00aa006c33ed} {5cb41ed0-0e4c-11d0-a286-00aa003049e2}</Data> 
<Data Name="AdditionalInfo">-</Data> 
<Data Name="AdditionalInfo2" /> 
</EventData> 
</Event>
```