# Custom Logs Pipeline

[![Deploy to Azure](https://aka.ms/deploytoazurebutton)](https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2FOTRF%2FMicrosoft-Sentinel2Go%2Fmaster%2Fgrocery-list%2FCustom-Logs-Pipeline%2Fazuredeploy.json)

## Send Data

### Define Orchestrator Uri

```PowerShell
$orchestrator = 'https://<function-name>.azurewebsites.net/api/orchestrators/Orchestrator'
```

### Prepare Request
```PowerShell
$shippingRequest = [Ordered]@{
    dataSamples = @(
        [Ordered]@{
            eventLogUrl = 'https://raw.githubusercontent.com/OTRF/Security-Datasets/SecurityDatasets2.0/datasets/atomic/windows/190301-ADModification-ADReplication/DC01_Windows_Security.zip'
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