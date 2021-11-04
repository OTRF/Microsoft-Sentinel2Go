# OSSEM Detection Model and ATT&CK

## Reference

### https://github.com/OTRF/OSSEM-DM/tree/main/use-cases/mitre_attack

## Download Event Mappings

Set Current Directory (PS Session Only)

```PowerShell
[Environment]::CurrentDirectory=(Get-Location -PSProvider FileSystem).ProviderPath
```

Set variable to point to OSSEM DM relationships mapped to ATT&CK file

```PowerShell
$uri = "https://raw.githubusercontent.com/OTRF/OSSEM-DM/main/use-cases/mitre_attack/techniques_to_events_mapping.json"
```

Initializing Web Client

```PowerShell
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$wc = new-object System.Net.WebClient
$wc.DownloadFile($uri, "techniques_to_events_mapping.json")
```

## Read JSON file

```PowerShell
$mappings = Get-Content .\techniques_to_events_mapping.json | ConvertFrom-Json
```

You can do a quick test by selecting the first object in the array.

```PowerShell
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

### Extract Security Events

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
            if ($item.filter_in.ToString() -ne 'NaN'){
                $eventObject += @{Filters = $item.filter_in}
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
            $leftover = @()
            foreach ($event in $allMappings[$ds][$dc]){
                $xmlWriter.WriteComment("$($Event.EventID) - $($Event.EventName)")
                if ($Event.Filters){
                    $leftover += $Event
                }
                else {
                    $query = -join ($query, " EventID=$($Event.EventID) ")
                    if (!($allMappings[$ds][$dc][-1]['EventID'] -eq $($Event.EventID))){
                        $query = -join ($query, "or")
                    }
                }
            }
            if ($allMappings[$ds][$dc].Count -ne $leftover.Count){
                $query = $query.Trim()
                $query = -join ("*[System[(", $query, ")]]")
                if ($leftover.Count -ne 0){
                    $query = -join ($query, ' or ')
                }
            }
            # Process leftover
            if ($leftover){
                foreach ($l in $leftover){
                    $query = -join ($query, "(*[System[EventID=$($l.EventID)]] and (")
                    foreach ($f in $l.Filters) {
                        $key = $f | get-member -MemberType NoteProperty | select -expandproperty Name
                        $query = -join ($query, "(*[EventData[Data[@Name='$($key)']='$($f.$key)'")
                        if (!($l.Filters[-1] -eq $($f))){
                            $query = -join ($query, "]] or ")
                        }
                        else {
                            $query = -join ($query, "]])))")
                        }
                    }
                    if (!($leftover[-1] -eq $($l))){
                        $query = -join ($query, " or ")
                    }
                }
            }
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

### windows-registry.xml File

```PowerShell
[xml]$registry = Get-Content .\windows-registry.xml
$registry.innerXml
```

```xml
<?xml version="1.0" encoding="utf-16"?>
<QueryList>
  <!--ATT&CK Data Source - windows registry-->
  <Query Id="0" Path="Security">
    <!--ATT&CK Data Component - windows registry key deletion-->
    <!--4660 - An object was deleted.-->
    <Select Path="Security">*[System[(EventID=4660)]]</Select>
  </Query>
  <Query Id="1" Path="Security">
    <!--ATT&CK Data Component - windows registry key modification-->
    <!--4670 - Permissions on an object were changed.-->
    <!--4657 - A registry value was modified.-->
    <Select Path="Security">*[System[(EventID=4670 or EventID=4657)]]</Select>
  </Query>
  <Query Id="2" Path="Security">
    <!--ATT&CK Data Component - windows registry key access-->
    <!--4656 - A handle to an object was requested.-->
    <!--4663 - An attempt was made to access an object.-->
    <Select Path="Security">(*[System[EventID=4656]] and ((*[EventData[Data[@Name='ObjectType']='Key']]))) or (*[System[EventID=4663]] and ((*[EventData[Data[@Name='ObjectType']='Key']])))</Select>
  </Query>
</QueryList>
```

### Run XML Query

```PowerShell
Get-WinEvent -FilterXml $registry
```

## Export XPath Queries for `Windows Security Events` Data Connector

### Quick Test

```PowerShell
[xml]$registry = Get-Content .\windows-registry.xml
$registry.QueryList.Query | ForEach-Object {-join ($_.Select.Path, '!', $_.Select.'#text') }
```

```
Security!*[System[(EventID=4660)]]
Security!*[System[(EventID=4670 or EventID=4657)]]
Security!(*[System[EventID=4656]] and ((*[EventData[Data[@Name='ObjectType']='Key']]))) or (*[System[EventID=4663]] and ((*[EventData[Data[@Name='ObjectType']='Key']])))
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
} | Convertto-Json -Depth 4 | ForEach-Object { [System.Text.RegularExpressions.Regex]::Unescape($_) } | Set-Content "ossem-attack.json"
```

## Microsoft Sentinel - Windows Security Events Connector - XPath Queries

```json
{
    "windowsEventLogs":  [
                             {
                                 "Name":  "eventLogsDataSource",
                                 "scheduledTransferPeriod":  "PT1M",
                                 "streams":  [
                                                 "Microsoft-SecurityEvent"
                                             ],
                                 "xPathQueries":  [
                                                      "Security!*[System[(EventID=5136 or EventID=5139)]]",
                                                      "Security!*[System[(EventID=5137)]]",
                                                      "Security!*[System[(EventID=5141)]]",
                                                      "Security!*[System[(EventID=4662 or EventID=4661)]]",
                                                      "Security!*[System[(EventID=4768 or EventID=4769)]]",
                                                      "Security!*[System[(EventID=4688)]]",
                                                      "Security!*[System[(EventID=4660)]]",
                                                      "Security!(*[System[EventID=4656]] and ((*[EventData[Data[@Name='ObjectType']='File']]))) or (*[System[EventID=4663]] and ((*[EventData[Data[@Name='ObjectType']='File']]))) or (*[System[EventID=4661]] and ((*[EventData[Data[@Name='ObjectType']='SAM']])))",
                                                      "Security!*[System[(EventID=4670)]]",
                                                      "Security!*[System[(EventID=4624 or EventID=4778 or EventID=4964)]]",
                                                      "Security!*[System[(EventID=5140 or EventID=5145)]]",
                                                      "Security!*[System[(EventID=5154 or EventID=5159 or EventID=5155 or EventID=5158 or EventID=5156 or EventID=5157 or EventID=5031)]]",
                                                      "Security!(*[System[EventID=4656]] and ((*[EventData[Data[@Name='ObjectType']='Process']]))) or (*[System[EventID=4663]] and ((*[EventData[Data[@Name='ObjectType']='Process']])))",
                                                      "Security!*[System[(EventID=4689)]]",
                                                      "Security!*[System[(EventID=4698)]]",
                                                      "Security!*[System[(EventID=4701 or EventID=4700 or EventID=4702)]]",
                                                      "Security!*[System[(EventID=4697)]]",
                                                      "Security!*[System[(EventID=4725 or EventID=4722 or EventID=4717 or EventID=4740 or EventID=4738 or EventID=4781 or EventID=4767 or EventID=4718)]]",
                                                      "Security!*[System[(EventID=4624 or EventID=4625 or EventID=4648)]]",
                                                      "Security!*[System[(EventID=4726)]]",
                                                      "Security!*[System[(EventID=4720)]]",
                                                      "Security!*[System[(EventID=4670 or EventID=4657)]]",
                                                      "Security!(*[System[EventID=4656]] and ((*[EventData[Data[@Name='ObjectType']='Key']]))) or (*[System[EventID=4663]] and ((*[EventData[Data[@Name='ObjectType']='Key']])))"
                                                  ]
                             }
                         ]
}
```
