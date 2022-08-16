param($Context)

$dataShippingRequest = $Context.Input | ConvertFrom-Json -ASHashTable

# Getting Information

$builtInTables = @("SecurityEvent","WindowsEvent","Syslog")
$tableName = $dataShippingRequest.tableName

if ($tableName -NotIn $builtInTables) {
    $tableName = "CustomTable"
}

# Preparing execution
$executorInput = @{
    EventLogUrl = $dataShippingRequest.eventLogUrl
    DceUri = $dataShippingRequest.dceUri
    TableName = $tableName
    StreamName = $dataShippingRequest.streamName
} | ConvertTo-Json -Depth 10

Write-Host ($executorInput | Out-String)

# Invoke activity function
$output = Invoke-DurableActivity -FunctionName "DataShipper" -Input $executorInput | ConvertTo-Json -Depth 10

# Export output
$output