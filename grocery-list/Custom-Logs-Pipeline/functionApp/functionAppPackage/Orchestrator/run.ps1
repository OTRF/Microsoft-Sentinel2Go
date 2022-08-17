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
    DcrImmutableId = $dataShippingRequest.dcrImmutableId
    TableName = $tableName
}

Write-Host ($executorInput | Out-String)

# Invoke activity function
Invoke-DurableActivity -FunctionName "DataShipper" -Input $executorInput