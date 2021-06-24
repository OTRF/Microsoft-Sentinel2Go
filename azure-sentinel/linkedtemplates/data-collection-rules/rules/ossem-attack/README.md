# OSSEM Detection Model and ATT&CK

## Reference

### https://github.com/OTRF/OSSEM-DM/tree/main/use-cases/mitre_attack

## Download Event Mappings

```PowerShell
# Set Current Directory (PS Session Only)
[Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath

$uri = "https://raw.githubusercontent.com/OTRF/OSSEM-DM/main/use-cases/mitre_attack/techniques_to_events_mapping.json"

# Initializing Web Client
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = new-object System.Net.WebClient
$wc.DownloadFile($uri, "techniques_to_events_mapping.json")
```

## Read File as an Array

```PowerShell
$mappings = Get-Content .\techniques_to_events_mapping.json | ConvertFrom-Json
$mappings[0] 
```

```
technique_id            : T1553.006
x_mitre_is_subtechnique : True
technique               : Code Signing Policy Modification     
tactic                  : {defense-evasion}
platform                : {Windows, macOS}
data_source             : windows registry
data_component          : windows registry key modification
name                    : Process modified Windows registry key
source                  : process
relationship            : modified
target                  : windows registry key
event_id                : 13
event_name              : RegistryEvent (Value Set).
event_platform          : Windows
audit_category          : RegistryEvent
audit_sub_category      : NaN
log_channel             : Microsoft-Windows-Sysmon/Operational
log_provider            : Microsoft-Windows-Sysmon
```

## Create XML Query Files

### Extract Events

```PowerShell
$allMappings = @{}
foreach ($item in $mappings) {
    if ($item.log_channel -eq 'Security'){
        if (!($allMappings.contains($item.data_source))){
            $allMappings.$($item.data_source) = @{}
        }
        if (!($allMappings[$item.data_source].contains($item.data_component))){
            $allMappings[$item.data_source][$item.data_component] = @()
        }
        if (!($allMappings[$item.data_source][$item.data_component] | Where-Object {$_.EventID -eq "$($item.event_id)"})) {
            $eventObject = @{
                EventID = "$($item.event_id)"
                EventName = "$($item.event_name)"
            }
            $allMappings[$item.data_source][$item.data_component] += $eventObject
        }
    }
}
```

### Create XML Objects

```PowerShell
foreach ($ds in $allMappings.Keys){
    $fileName = -join (($ds -replace " ","-").ToLower(), '.xml')
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
    $xmlWriter.Formatting = "indented"
    $xmlWriter.Indentation = 2
    $xmlWriter.IndentChar = ' '
    $xmlWriter.WriteStartDocument()
    $xmlWriter.WriteStartElement("QueryList")
    $xmlWriter.WriteComment("ATT&CK Data Source - $ds")

    $Counter = 0
    foreach ($dc in $allMappings[$ds].Keys) {
        # Create query element
        $xmlWriter.WriteStartElement("Query")
            $xmlWriter.WriteAttributeString("Id", "$Counter")
            $xmlWriter.WriteAttributeString("Path", "Security")
            $xmlWriter.WriteComment("ATT&CK Data Component - $dc")
            # Create query strings
            $query = ""
            foreach ($event in $allMappings[$ds][$dc]){
                $xmlWriter.WriteComment("$($Event.EventID) - $($Event.EventName)")
                $query = -join ($query, " EventID=$($Event.EventID) ")
                if (!($allMappings[$ds][$dc][-1]['EventID'] -eq $($Event.EventID))){
                    $query = -join ($query, "or")
                }
            }
            $query = $query.Trim()
            $query = -join ("*[System[(", $query, ")]]")
            # Create Select (query) Element
            $xmlWriter.WriteStartElement("Select")
                $xmlWriter.WriteAttributeString("Path", "Security")
                $xmlWriter.WriteString("$query")
            $xmlWriter.WriteEndElement() | out-null
        $xmlWriter.WriteEndElement() | out-null
        $counter += 1
    }
    # Write Close Tag for QueryList Element
    $xmlWriter.WriteEndDocument() | out-null
    # Finish The Document
    $xmlWriter.Flush() | out-null
    $StringWriter.Flush() | out-null
    #Create File
    $StringWriter.ToString() | out-file $fileName
    $xmlWriter.Close()
}
```

## Test XML Query 

### Read user-account.xml File

```PowerShell
[xml]$Account = get-content .\user-account.xml
$Account.InnerXml
```

```xml
<?xml version="1.0" encoding="utf-16"?>
<QueryList>
  <!--ATT&CK Data Source - user account-->
  <Query Id="0" Path="Security">
    <!--ATT&CK Data Component - user account modification-->
    <!--4725 - A user account was disabled.-->
    <!--4722 - A user account was enabled.-->
    <!--4717 - System security access was granted to an account.-->
    <!--4740 - A user account was locked out.-->
    <!--4738 - A user account was changed.-->
    <!--4781 - The name of an account was changed.-->
    <!--4718 - System security access was removed from an account.-->
    <!--4767 - A user account was unlocked.-->
    <Select Path="Security">*[System[(EventID=4725 or EventID=4722 or EventID=4717 or EventID=4740 or EventID=4738 or EventID=4781 or EventID=4718 or EventID=4767)]]</Select>
  </Query>
  <Query Id="1" Path="Security">
    <!--ATT&CK Data Component - user account authentication-->
    <!--4625 - An account failed to log on.-->
    <!--4648 - A logon was attempted using explicit credentials.-->
    <Select Path="Security">*[System[(EventID=4625 or EventID=4648)]]</Select>
  </Query>
  <Query Id="2" Path="Security">
    <!--ATT&CK Data Component - user account deletion-->
    <!--4726 - A user account was deleted.-->
    <Select Path="Security">*[System[(EventID=4726)]]</Select>
  </Query>
  <Query Id="3" Path="Security">
    <!--ATT&CK Data Component - user account creation-->
    <!--4720 - A user account was created.-->
    <Select Path="Security">*[System[(EventID=4720)]]</Select>
  </Query>
</QueryList>
```

### Run XML Query

```PowerShell
Get-WinEvent -FilterXml $Account
```

## Export XPath Queries for `Windows Security Events` Data Connector

### Quick Test

```PowerShell
[xml]$Account = get-content .\user-account.xml
$Account.QueryList.Query | ForEach-Object {-join ($_.Select.Path, '!', $_.Select.'#text') }
```

```
Security!*[System[(EventID=4725 or EventID=4722 or EventID=4717 or EventID=4740 or EventID=4738 or EventID=4781 or EventID=4718 or EventID=4767)]]
Security!*[System[(EventID=4625 or EventID=4648)]]
Security!*[System[(EventID=4726)]]
Security!*[System[(EventID=4720)]]
```

### Export Data Sources JSON File

```PowerShell
$allFiles = Get-ChildItem -Path *.xml

$AllDataSources = @()
$DataSource = [ordered]@{}
# Name of Data Source
$DataSource['Name'] = "eventLogsDataSource"
# Transfer Period
$DataSource['scheduledTransferPeriod'] = "PT1M"
# Streams
$DataSource['streams'] = @(
    "Microsoft-SecurityEvent"
)
# Process XPath Queries
$DataSource['xPathQueries'] = @()
foreach ($file in $allFiles){
    [xml]$XmlQuery = Get-Content -path $file
    $queries = $xmlQuery.QueryList.Query
    ForEach ($query in $queries){
        $QueryString = "$(-join ($query.Select.Path, '!', $query.Select.'#text'))"
        if ("$QueryString" -notin $DataSource['xPathQueries']){
            $DataSource['xPathQueries'] += $QueryString
        } 
    }
}
$AllDataSources += $DataSource

@{
    windowsEventLogs = $AllDataSources
} | Convertto-Json -Depth 4 | Set-Content "ossem-attack.json" -Encoding UTF8
```