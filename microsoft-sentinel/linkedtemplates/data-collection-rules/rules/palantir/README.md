# Palantir WEF Subscriptions

## Reference:

### https://github.com/palantir/windows-event-forwarding

## Export Queries

### Clone Repository

```PowerShell
git clone https://github.com/palantir/windows-event-forwarding
cd windows-event-forwarding/wef-subscription
```

### Export Queries from WEF Subscriptions

```PowerShell
$all = Get-ChildItem *.xml
ForEach ( $file in $all){
    $fileName = Split-Path $file -Leaf
    [xml]$subscription = get-content $file
    [xml]$xmlContent = $subscription.Subscription.Query.'#cdata-section'
    $StringWriter = New-Object System.IO.StringWriter
    $XmlWriter = New-Object System.XMl.XmlTextWriter $StringWriter
    $xmlWriter.Formatting = "indented"
    $xmlWriter.Indentation = 2
    $xmlWriter.IndentChar = ' '
    $xmlContent.WriteContentTo($XmlWriter)
    $XmlWriter.Flush()
    $StringWriter.Flush()
    
    $StringWriter.ToString() | out-file "Queries\$fileName"
}
```

## Test XML Query 

### Read Account-Lockout.xml Example

```PowerShell

[xml]$Account = get-content .\Account-Lockout.xml
$Account.InnerXml
```

```xml
<QueryList>
  <!-- Inspired by Microsoft Documentation and/or IADGOV -->
  <Query Id="0" Path="Security">
    <!-- For Domain Accounts event is created on DC-->
    <!-- For Local Accounts event is created locally-->
    <!-- 4740: Account Lockouts -->
    <Select Path="Security">*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (Level=4 or Level=0) and EventID=4740]]</Select>
  </Query>
</QueryList>
```

### Run XML Query

```PowerShell
Get-WinEvent -FilterXml $Account
```

## Export XPath Query for Windows Security Events Connector

```PowerShell
$Account.QueryList.Query | ForEach-Object {-join ($_.Select.Path, '!', $_.Select.'#text') }
```

```
Security!*[System[Provider[@Name='Microsoft-Windows-Security-Auditing'] and (Level=4 or Level=0) and EventID=4740]]
```
