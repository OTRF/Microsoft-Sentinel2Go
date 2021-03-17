# Azure Sentinel + Win10 + Palo Alto Networks VM-Series Firewall

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-PAN-FW%2Fazuredeploy.json)
[![Deploy to Azure Gov](https://aka.ms/deploytoazuregovbutton)](https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FAzure-Sentinel2Go%2Fmaster%2Fgrocery-list%2FWin10-PAN-FW%2Fazuredeploy.json)

## Grocery Items

* Azure Sentinel
    * Would you like to Bring-Your-Own Azure Sentinel?.
    * If so, set the `workspaceId` and `workspaceKey` parameters of your own workspace.
* One Windows 10 Workstation
* One Ubuntu Server
    * CEF Collector Server (RSyslog)
    * Linux [Microsoft Monitoring Agent](https://docs.microsoft.com/en-us/services-hub/health/mma-setup) installed.
* Palo Alto Networks VM-Series firewall
    * Bundle 2 Subscription: It includes the VM-Series capacity license with the complete suite of licenses that includes Threat Prevention, GlobalProtect, WildFire, PAN-DB URL Filtering, and a premium support entitleme
* CEF Data Connector Enabled
* Palo Alto Networks Data Connector
* [OPTIONAL] Sysmon
    * [Sysmon Config](https://github.com/OTRF/Blacksmith/blob/master/resources/configs/sysmon/sysmon.xml)
* [OPTIONAL] Command and Control (c2) options:
    * `empire`
    * `covenant`
    * `caldera`
    * `metasploit`
    * `shad0w`

## VM-Series Licensing

For both AWS and Microsoft Azure, the licensing options are bring your own license (BYOL) and pay as you go/consumption-based (PAYG) subscriptions.

* **BYOL**: Any one of the VM-Series models, along with the associated Subscriptions and Support, are purchased via normal Palo Alto Networks channels and then deployed through your AWS or Azure management console.
* **PAYG (Pay-as-you-go)**: Purchase the VM-Series and select Subscriptions and Premium Support as an hourly subscription bundle from the AWS Marketplace.
    * **Bundle 1 contents**: VM-300 firewall license, Threat Prevention Subscription (inclusive of IPS, AV, Malware prevention) and Premium Support.
    * **Bundle 2 contents**: VM-300 firewall license, Threat Prevention (inclusive of IPS, AV, Malware prevention), WildFire™ threat intelligence service, URL Filtering, GlobalProtect Subscriptions and Premium Support.

## Accept Azure VM Marketplace Terms (MUST DO)

* The Palo Alto Networks (PAN) VM-Series Firewall is deployed from Azure Marketplace. You need to accept the legal terms to use the VM.
* You must have authorization to perform action `Microsoft-MarketPlaceOrdering/offerTypes/publishers/offers/plans/agreements/write` over scope `subscription`.
* **Make sure you run the commands below before deploying this template**
* You can do it locally via [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/?view=azure-cli-latest) or via the [Azure Clould Shell](https://shell.azure.com/). 

Look for the PAN VM-Series Firewall you are deploying:

```
az vm image list --all --publisher paloaltonetworks --offer vmseries1 --sku bundle2 --query '[0].urn'
```

Accept terms:

```
az vm image terms accept --urn paloaltonetworks:vmseries1:bundle2:7.1.1
```
