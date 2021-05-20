# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPLv3
# Reference:
# https://github.com/Azure/Azure-Sentinel/blob/master/Tools/Sentinel-All-In-One/ARMTemplates/Scripts/EnableRules.ps1

param(
    [Parameter(Mandatory=$true)][string]$ResourceGroup,
    [Parameter(Mandatory=$true)][string]$Workspace,
    [Parameter(Mandatory=$true)][string[]]$DataConnectors,
    [Parameter(Mandatory=$false)][string[]]$Alerts
)

$context = Get-AzContext

if(!$context){
    Connect-AzAccount
    $context = Get-AzContext
}

$SubscriptionId = $context.Subscription.Id

Write-host "[+] Connected to Azure with subscription: $($context.Subscription)"

$baseUri = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}/providers/Microsoft.OperationalInsights/workspaces/${Workspace}"
$templatesUri = "$baseUri/providers/Microsoft.SecurityInsights/alertRuleTemplates?api-version=2019-01-01-preview"
$alertUri = "$baseUri/providers/Microsoft.SecurityInsights/alertRules"
$listAlertsUri = "$alertUri`?api-version=2020-01-01"

try {
    $alertRulesTemplates = ((Invoke-AzRestMethod -Path $templatesUri -Method GET).Content | ConvertFrom-Json).value
    [array]$alertsList = ((Invoke-AzRestMethod -Path $listAlertsUri -Method GET).Content | ConvertFrom-Json).value | Foreach-Object {$_.properties} | Select-Object -ExpandProperty displayName
}
catch {
    Write-Verbose $_
    Write-Error "Unable to get alert rules with error code: $($_.Exception.Message)" -ErrorAction Stop
}

# Check for specific rules
if ($Alerts) {
    $alertRulesTemplates = $alertRulesTemplates | Where-Object {"$($_.properties.displayName)".replace(" ","_") -in $Alerts}
    if ($alertRulesTemplates.length -eq 0) { Write-Error "Alert templates for rules $Alerts do not exist" -ErrorAction Stop }
}

$return = @()

foreach ($item in $alertRulesTemplates) {
    if ($item.kind -eq "Scheduled"){
        $alertName = $item.properties.displayName
        # If alert already exists, skip!
        if ($alertName -notin $alertsList) {
            # Get data connectors required for alert
            [array]$requiredDataConnectors = $item.properties.requiredDataConnectors | Select-Object -ExpandProperty connectorId
            # Skip rules that do not have data connectors
            if($requiredDataConnectors.length -ge 1) {
                # If required data connectors (all of them) are inside of the input dataConnectors array, then proceeed to enable it
                if($requiredDataConnectors.length -eq ([array]$($requiredDataConnectors | Where-Object {$_ -in $dataConnectors})).length) {
                    $guid = New-Guid
                    $alertUriGuid = $alertUri + '/' + $guid + '?api-version=2020-01-01'

                    $properties = @{
                        displayName = $alertName
                        enabled = $true
                        suppressionDuration = "PT5H"
                        suppressionEnabled = $false
                        alertRuleTemplateName = $item.name
                        description = $item.properties.description
                        query = $item.properties.query
                        queryFrequency = $item.properties.queryFrequency
                        queryPeriod = $item.properties.queryPeriod
                        severity = $item.properties.severity
                        tactics = $item.properties.tactics
                        triggerOperator = $item.properties.triggerOperator
                        triggerThreshold = $item.properties.triggerThreshold
                    }

                    $alertBody = @{}
                    $alertBody | Add-Member -NotePropertyName kind -NotePropertyValue $item.kind -Force
                    $alertBody | Add-Member -NotePropertyName properties -NotePropertyValue $properties

                    $stopLoop = $false
                    [int]$retryCount = 0
                    do {
                        try{
                            $response = Invoke-AzRestMethod -Path $alertUriGuid -Method PUT -Payload ($alertBody | ConvertTo-Json -Depth 3)
                            $responseObject = $response | ConvertTo-Json | ConvertFrom-Json
                            $responseCode = $response.StatusCode
                            if ($responseCode -eq 201 -or $responseCode -eq 200) {
                                $responseDescription = Switch ($responseCode) {
                                    200 { "Alert Rule: OK, Operation successfully completed" }
                                    201 { 'Alert Rule: Created' }
                                }
                                write-host " [+] $alertName $responseDescription"
                                write-verbose $responseObject
                                $return += $alertName
                                $stopLoop = $true
                            }
                            else { throw ($responseObject) }
                        }
                        catch {
                            if ($retryCount -gt 5){
                                Write-Verbose $_
                                Write-Error "Unable to create alert rule with error message: $($_.Exception.Message)" -ErrorAction Stop
                                $stopLoop = $true
                            }
                            else {
                                Write-host "[*] Cound not create alert rule, retrying in 15 seconds.."
                                Start-Sleep -seconds 15
                                $retryCount = $retryCount + 1
                            }
                        }
                    }
                    while ($stopLoop -eq $false)
                }
            }
        }
        else { Write-Warning "Alert $alertName already exists!" }
    }
}
return $return