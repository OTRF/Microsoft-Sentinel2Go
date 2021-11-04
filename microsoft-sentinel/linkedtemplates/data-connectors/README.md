# Microsoft Sentinel Data Connectors

<a href="https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fmicrosoft-sentinel%2Flinkedtemplates%2Fdata-connectors%2FallConnectors.json" target="_blank">
    <img src="https://aka.ms/deploytoazurebutton"/>
</a>
<br/>
<a href="https://portal.azure.us/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fmicrosoft-sentinel%2Flinkedtemplates%2Fdata-connectors%2FallConnectors.json" target="_blank">
    <img src="https://aka.ms/deploytoazuregovbutton"/>
</a>
<br/>
<br/>

The current kind of Data Connectors deployed via ARM templates in this project are of type [Microsoft.OperationsManagement/solutions](https://docs.microsoft.com/en-us/azure/templates/microsoft.operationsmanagement/2015-11-01-preview/solutions) and [Microsoft.OperationalInsights/workspaces/dataSources](https://docs.microsoft.com/en-us/azure/templates/microsoft.operationalinsights/2015-11-01-preview/workspaces/datasources)


| Display Name | Data Table | Type | Kind |
|----|----|----|----|
| [Amazon Web Services](https://docs.microsoft.com/en-us/azure/sentinel/connect-aws) | AWSCloudTrail | Data Connector | AmazonWebServicesCloudTrail |
| [Azure Activity](https://docs.microsoft.com/en-us/azure/sentinel/connect-azure-activity) | AzureActivity | Data Source | AzureActivityLog |
| [Azure Security Center](https://docs.microsoft.com/en-us/azure/sentinel/connect-azure-security-center) | SecurityAlert | Data Connector | AzureSecurityCenter |
| [DNS (Preview)](https://docs.microsoft.com/en-us/azure/sentinel/connect-dns) | DnsEvents, DnsInventory | Solution | DnsAnalytics |
| [Security Events](https://docs.microsoft.com/en-us/azure/sentinel/connect-windows-security-events) | SecurityEvent | Data Source | SecurityInsightsSecurityEventCollectionConfiguration |
| [Windows Firewall](https://docs.microsoft.com/en-us/azure/sentinel/connect-windows-firewall) | WindowsFirewall | Solution | WindowsFirewall |
| [Office 365](https://docs.microsoft.com/en-us/azure/sentinel/connect-office-365) | OfficeActivity | Data Connector | Office365 |
| [Azure AD](https://docs.microsoft.com/en-us/azure/sentinel/connect-azure-active-directory) | SigninLogs, AuditLogs | Data Connector | AzureActiveDirectory |

# References

* https://docs.microsoft.com/en-us/azure/sentinel/connect-data-sources
