param($Context)

$ErrorActionPreference = "Stop"

$dataShippingRequest = $Context.Input | ConvertFrom-Json -ASHashTable

# Set output variable to aggregate all outputs
$output = [ordered]@{}

# Current event providers that would send data to a built-in table
$eventToTable = @{
    'Microsoft-Windows-Sysmon' = "WindowsEvent"
    'Service Control Manager' = 'WindowsEvent'
    'Microsoft-Windows-Directory-Services-SAM' = 'WindowsEvent'
    'Microsoft-Windows-WMI-Activity' = 'WindowsEvent'
    'Microsoft-Windows-Security-Auditing' = 'SecurityEvent'
}

# Generating simulation id
$newGuid = (new-guid).guid

# Defining durable activity name
$destinationTable = @('AzureLogAnalytics')
$destinationSet = $dataShippingRequest.destination
if ($destinationSet -notin $destinationTable) {
    Write-Error "[!] $destinationSet not allowed. Only 'AzureLogAnalytics' allowed."
}
else {
    $durableActivityName = $destinationSet
}

$ParallelTasks = 
    foreach ($dataSample in $dataShippingRequest.datasets) {
        # Set table name
        if ($eventToTable.ContainsKey($dataSample.eventSourceName)){
            $tableName = $eventToTable[$dataSample.eventSourceName]
        }
        else {
            $tableName = "CustomTable"
        }

        # Preparing execution
        $executorInput = @{
            EventLogUrl = $dataSample.eventLogUrl
            TableName = $tableName
            SimulationId = $newGuid
        } | ConvertTo-Json

        Write-Host ($executorInput | Out-String)
        
        # Invoke activity function
        Invoke-DurableActivity -FunctionName $durableActivityName -Input $executorInput -NoWait
    }

# Wait for outputs
$output = Wait-ActivityFunction -Task $ParallelTasks | ConvertTo-Json
$output