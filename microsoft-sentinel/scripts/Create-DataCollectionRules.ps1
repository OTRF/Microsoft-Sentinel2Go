# Author: Roberto Rodriguez (@Cyb3rWard0g)
# License: GPLv3
# Reference:
# https://review.docs.microsoft.com/en-us/azure/sentinel/connect-windows-security-events?branch=pr-en-us-161325&tabs=AMA
# https://docs.microsoft.com/en-us/rest/api/monitor/data-collection-rules/create#knowndatacollectionruleresourcekind

param(
    [Parameter(Mandatory=$true)][string]$WorkspaceId,
    [Parameter(Mandatory=$true)][string]$WorkspaceResourceId,
    [Parameter(Mandatory=$true)][string]$ResourceGroup,
    [Parameter(Mandatory=$false)][ValidateSet('Windows','Linux')][string]$Kind = 'Windows',
    [Parameter(Mandatory=$true)][string]$DataCollectionRuleName,
    [Parameter(Mandatory=$false)][string]$DestinationLogAnalyticsName = 'WindowsEvents',
    [Parameter(Mandatory=$false)][string[]]$DataFlowsStreams = @('Microsoft-SecurityEvent'),
    [Parameter(Mandatory=$false)][object]$DataSourcesObject,
    [Parameter(Mandatory=$false)][string]$DataSourcesFile,
    [Parameter(Mandatory=$true)][string]$Location
)

$context = Get-AzContext

if(!$context){
    Connect-AzAccount
    $context = Get-AzContext
}

$SubscriptionId = $context.Subscription.Id

Write-host "[+] Connected to Azure with subscription: $($context.Subscription)"
Write-host "[+] Processing XPath Queries.."
if ($DataSourcesFile){
    if (($DataSourcesFile -as [System.URI]).AbsoluteURI) {
        Write-host "[+] Downloading Data Sources File.."
        # Set Current Directory (PS Session Only)
        [Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
        # Initializing Web Client
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
        $OutputFile = Split-Path $XPathQueriesUrl -leaf
        # Download Queries
        $wc = new-object System.Net.WebClient
        $wc.DownloadFile($XPathQueriesUrl, $OutputFile)
        $DataSourcesFile = $OutputFile
    }
    $DataSourcesObject = Get-content -Path .\$DataSourcesFile | ConvertFrom-Json
}

Write-host "[+] Data Collection Rule: $DataCollectionRuleName"
$ApiUri = "/subscriptions/${SubscriptionId}/resourceGroups/${ResourceGroup}/providers/Microsoft.Insights/dataCollectionRules/${DataCollectionRuleName}?api-version=2019-11-01-preview"
$RuleBody = @{
    location = $location
    kind = "$kind"
    tags = @{
        createdBy = "Sentinel"
    }
    properties = @{
        datasources = $DataSourcesObject
        destinations = @{
            logAnalytics = @(
                @{
                    name = "$DestinationLogAnalyticsName"
                    workspaceId = $WorkspaceId
                    workspaceResourceId = $WorkspaceResourceId
                }
            )
        }
        dataFlows = @(
            @{
                streams = $DataFlowsStreams
                destinations = @(
                    "$DestinationLogAnalyticsName"
                )
            }
        )
    }
} | ConvertTo-Json -Depth 10

Write-host "[+] Creating Data Collection Rule: $DataCollectionRuleName"
$stopLoop = $false
[int]$retryCount = 0
do {
    try{
        Write-Verbose $RuleBody
        $response = Invoke-AzRestMethod -Path $ApiUri -Method PUT -Payload $RuleBody
        $responseObject = $response | ConvertTo-Json | ConvertFrom-Json
        Write-Verbose $responseObject
        $responseCode = $response.StatusCode
        if ($responseCode -eq 201 -or $responseCode -eq 200) {
            $responseDescription = Switch ($responseCode) {
                200 { 'Rule: OK, Operation successfully completed' }
                201 { 'Rule: Created' }
            }
            write-host " [+] $DataCollectionRuleName $responseDescription"
            $output = $responseObject.Content | ConvertFrom-Json | Select-Object -ExpandProperty id
            Write-Output $output
            $DeploymentScriptOutputs = @{}
            $DeploymentScriptOutputs['text'] = $output
            $stopLoop = $true
        }
        else { throw ($responseObject) }
    }
    catch {
        if ($retryCount -gt 5){
            Write-Verbose $_
            Write-Error "Unable to create data collection rule with error message: $($_.Exception.Message)" -ErrorAction Stop
            $stopLoop = $true
        }
        else {
            Write-host "[*] Cound not create data collection rule, retrying in 15 seconds.."
            Start-Sleep -seconds 15
            $retryCount = $retryCount + 1
        }
    }
}
while ($stopLoop -eq $false)