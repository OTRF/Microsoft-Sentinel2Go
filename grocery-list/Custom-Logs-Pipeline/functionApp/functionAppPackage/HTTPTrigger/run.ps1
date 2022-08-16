using namespace System.Net

# Input bindings are passed in via param block.
param($Request, $TriggerMetadata)

# Write to the Azure Functions log stream.
Write-Host "PowerShell HTTP trigger function processed a request."

$FunctionName = $Request.Params.FunctionName
$OrchestratorInputs = $Request.Body

if ($OrchestratorInputs -is [HashTable]) {
    Write-Host "Converting HashTable to JSON object"
    $OrchestratorInputs = $OrchestratorInputs | ConvertTo-Json -Depth 10
}

$InstanceId = Start-NewOrchestration -FunctionName $FunctionName -InputObject $OrchestratorInputs
Write-Host "Started orchestration with ID = '$InstanceId'"

$Response = New-OrchestrationCheckStatusResponse -Request $Request -InstanceId $InstanceId
Push-OutputBinding -Name Response -Value $Response