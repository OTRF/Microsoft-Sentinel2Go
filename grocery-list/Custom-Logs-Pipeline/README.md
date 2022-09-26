# Custom Logs Pipeline

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FCustom-Logs-Pipeline%2Fazuredeploy.json)

## Send Data

### Define Orchestrator Uri

```PowerShell
$orchestrator = 'https://<function-name>.azurewebsites.net/api/orchestrators/Orchestrator'
```

### Prepare Request

```PowerShell
$SimulationRequest = @{
    title = 'Proof of Concept'
    destination = 'AzureLogAnalytics'
    datasets = @(
        @{
            number = 1
            eventLogUrl = 'https://github.com/OTRF/Security-Datasets/raw/SecurityDatasets2.0/datasets/atomic/windows/190518-RegKeyModification-WDigestDowngrade/WORKSTATION6_Windows_Security.zip'
            eventSourceName = 'Microsoft-Windows-Security-Auditing'
        }
    )
}
```

### Prepare Body

```PowerShell
$params = @{
    Uri = $orchestrator
    Method = "Post"
    Body = $shippingRequest | Convertto-json -Depth 10
    ContentType = 'application/json'
    Verbose = $true
}
```

### Send Request

```PowerShell
Invoke-RestMethod @params
```