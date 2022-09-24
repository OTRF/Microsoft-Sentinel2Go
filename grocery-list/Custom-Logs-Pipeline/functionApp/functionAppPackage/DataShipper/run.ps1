param($shipping)

Write-Host "[*] PowerShell Durable Activity Triggered.."

function Get-RemoteFile ($uri) {
    # Initialize WebClient
    $wc = New-Object System.Net.WebClient
    # Get file name
    $request = [System.Net.WebRequest]::Create($uri)
    $response = $request.GetResponse()
    $fileName = [System.IO.Path]::GetFileName($response.ResponseUri)
    $response.Close()
    $outputFile = "$PWD\$fileName"
    # Check to see if file already exists
    if (!(Test-Path $outputFile)) {
        Write-Host "[*] Downloading script from $uri .."
        $wc.DownloadFile($uri, $outputFile)
    }
    # If for some reason, a file does not exists, STOP
    if (!(Test-Path $outputFile)) {
        throw "[*] $outputFile does not exist. File was not downloaded properly or it was deleted by system."
    }

    # Decompress if it is zip file
    if ($outputFile.ToLower().EndsWith(".zip"))
    {
        # Unzip file
        write-Host "[*] Decompressing $outputFile .."
        $UnpackName = (Get-Item $outputFile).Basename
        $eventsFolder = "$PWD\$UnpackName"
        expand-archive -path $outputFile -DestinationPath $eventsFolder
        if (!(Test-Path $eventsFolder)) { Write-Error "$outputFile was not decompressed successfully" -ErrorAction Stop }
        Remove-Item $outputFile
        $outputFile = (Get-ChildItem -Path $eventsFolder | Sort-Object | Select-Object -First 1).FullName
    }
    # Return file with full path
    $outputFile
}

Write-Host "[*] Setting variables.."
$EventLogUrl = $shipping.EventLogUrl
$TableName = $shipping.TableName
$windowsEventDCRId = [System.Environment]::GetEnvironmentVariable('WINDOWS_EVENT_DCR_ID')
$securityEventDCRId = [System.Environment]::GetEnvironmentVariable('SECURITY_EVENT_DCR_ID')

Write-Host "[*] Downloading event log file.."
# Extract Action name
$fileLocation = Get-RemoteFile $EventLogUrl
Write-Host "[*] File downloaded: $fileLocation"

# Get Access Token
$muiEndpoint = [System.Environment]::GetEnvironmentVariable('IDENTITY_ENDPOINT')
$muiSecret = [System.Environment]::GetEnvironmentVariable('IDENTITY_HEADER')
$muiPrincipalId = [System.Environment]::GetEnvironmentVariable('MUI_PRINCIPAL_ID')
$ResourceUrl = 'https://monitor.azure.com/'
$tokenAuthURI = $muiEndpoint + "?resource=$ResourceUrl&api-version=2019-08-01&principal_id=$muiPrincipalId"
write-host "[+] Token Auth URI: $tokenAuthURI"
$tokenResponse = Invoke-RestMethod -Method Get -Headers @{"X-IDENTITY-HEADER" = "$muiSecret" } -Uri $tokenAuthURI
$accessToken = $tokenResponse.access_token
write-host "[+] Access Token: $accessToken"

# Setting up main function
Function Send-DataToDCE($payload, $size, $stream, $dcrImmutableId){
    write-host "############ Sending Data ############"
    write-host "JSON array size: $($size/1mb) MBs"
    
    $DceURI= [System.Environment]::GetEnvironmentVariable('DCE_URI')

    # Initialize Headers and URI for POST request to the Data Collection Endpoint (DCE)
    $headers = @{"Authorization" = "Bearer $accessToken"; "Content-Type" = "application/json"}
    $uri = "$DceURI/dataCollectionRules/$DcrImmutableId/streams/$stream`?api-version=2021-11-01-preview"

    # Sending data to Data Collection Endpoint (DCE) -> Data Collection Rule (DCR) -> Azure Monitor table
    Invoke-RestMethod -Uri $uri -Method "Post" -Body (@($payload | ConvertFrom-Json | ConvertTo-Json)) -Headers $headers | Out-Null
}

# Maximum size of API call: 1MB for both compressed and uncompressed data
$APILimitBytes = 1mb

# Official Azure Monitor Build-Int Table Schemas
$securityEventProperties=@("AccessMask","Account","AccountDomain","AccountExpires","AccountName","AccountSessionIdentifier","AccountType","Activity","AdditionalInfo","AdditionalInfo2","AllowedToDelegateTo","Attributes","AuditPolicyChanges","AuditsDiscarded","AuthenticationLevel","AuthenticationPackageName","AuthenticationProvider","AuthenticationServer","AuthenticationService","AuthenticationType","AzureDeploymentID","CACertificateHash","CalledStationID","CallerProcessId","CallerProcessName","CallingStationID","CAPublicKeyHash","CategoryId","CertificateDatabaseHash","Channel","ClassId","ClassName","ClientAddress","ClientIPAddress","ClientName","CommandLine","CompatibleIds","Computer","DCDNSName","DeviceDescription","DeviceId","DisplayName","Disposition","DomainBehaviorVersion","DomainName","DomainPolicyChanged","DomainSid","EAPType","ElevatedToken","ErrorCode","EventData","EventID","EventSourceName","ExtendedQuarantineState","FailureReason","FileHash","FilePath","FilePathNoUser","Filter","ForceLogoff","Fqbn","FullyQualifiedSubjectMachineName","FullyQualifiedSubjectUserName","GroupMembership","HandleId","HardwareIds","HomeDirectory","HomePath","InterfaceUuid","IpAddress","IpPort","KeyLength","Level","LmPackageName","LocationInformation","LockoutDuration","LockoutObservationWindow","LockoutThreshold","LoggingResult","LogonGuid","LogonHours","LogonID","LogonProcessName","LogonType","LogonTypeName","MachineAccountQuota","MachineInventory","MachineLogon","ManagementGroupName","MandatoryLabel","MaxPasswordAge","MemberName","MemberSid","MinPasswordAge","MinPasswordLength","MixedDomainMode","NASIdentifier","NASIPv4Address","NASIPv6Address","NASPort","NASPortType","NetworkPolicyName","NewDate","NewMaxUsers","NewProcessId","NewProcessName","NewRemark","NewShareFlags","NewTime","NewUacValue","NewValue","NewValueType","ObjectName","ObjectServer","ObjectType","ObjectValueName","OemInformation","OldMaxUsers","OldRemark","OldShareFlags","OldUacValue","OldValue","OldValueType","OperationType","PackageName","ParentProcessName","PasswordHistoryLength","PasswordLastSet","PasswordProperties","PreviousDate","PreviousTime","PrimaryGroupId","PrivateKeyUsageCount","PrivilegeList","Process","ProcessId","ProcessName","ProfilePath","Properties","ProtocolSequence","ProxyPolicyName","QuarantineHelpURL","QuarantineSessionID","QuarantineSessionIdentifier","QuarantineState","QuarantineSystemHealthResult","RelativeTargetName","RemoteIpAddress","RemotePort","Requester","RequestId","RestrictedAdminMode","RowsDeleted","SamAccountName","ScriptPath","SecurityDescriptor","ServiceAccount","ServiceFileName","ServiceName","ServiceStartType","ServiceType","SessionName","ShareLocalPath","ShareName","SidHistory","SourceComputerId","SourceSystem","Status","StorageAccount","SubcategoryGuid","SubcategoryId","Subject","SubjectAccount","SubjectDomainName","SubjectKeyIdentifier","SubjectLogonId","SubjectMachineName","SubjectMachineSID","SubjectUserName","SubjectUserSid","SubStatus","TableId","TargetAccount","TargetDomainName","TargetInfo","TargetLinkedLogonId","TargetLogonGuid","TargetLogonId","TargetOutboundDomainName","TargetOutboundUserName","TargetServerName","TargetSid","TargetUser","TargetUserName","TargetUserSid","TemplateContent","TemplateDSObjectFQDN","TemplateInternalName","TemplateOID","TemplateSchemaVersion","TemplateVersion","TimeGenerated","TokenElevationType","TransmittedServices","Type","UserAccountControl","UserParameters","UserPrincipalName","UserWorkstations","VendorIds","VirtualAccount","Workstation","WorkstationName")
$windowsEventProperties=@("Channel","Computer","EventData","EventID","EventLevel","EventLevelName","EventOriginId","ManagementGroupName","Provider","RawEventData","Task","TimeGenerated","Type")
#$syslogProperties=@("Computer","EventTime","Facility","HostIP","HostName","ProcessID","ProcessName","SeverityLevel","SourceSystem","SyslogMessage","TimeGenerated","Type")

# Define initial variables
$total_file_size = (get-item -Path $fileLocation).Length
$json_records = @()
$json_array_current_size = 0
$event_count = 0
$total_size = 0

# Read events from file
$jsonObjects = Get-Content $fileLocation -Raw | Convertfrom-json
$numberOfRecords = $jsonObjects.Count

write-Host "*******************************************"
Write-Host "[+] Processing $fileLocation"
Write-Host "[+] Dataset Size: $($total_file_size/1mb) MBs"
Write-Host "[+] Number of events to process: $numberOfRecords"

# Read each JSON object from file
foreach($eventLog in $jsonObjects){
    # Increase event number
    $event_count += 1
    # Process Timestamp
    if ($shiping.TimestampField){
        $TimeGenerated= $eventLog | Select-Object -ExpandProperty $shiping.TimestampField
    }
    else {
        $TimeGenerated = Get-Date ([datetime]::UtcNow) -Format O
    }

    # Processing Log entry as a compressed JSON object
    $pscustomobject = $eventLog
    $pscustomobject | Add-Member -MemberType NoteProperty -Name 'TimeGenerated' -Value $TimeGenerated -Force

    # Current properties of PSCustomObject
    $currentEventProperties = Get-Member -InputObject $pscustomobject -MemberType NoteProperty

    if ($TableName -eq 'SecurityEvent') {
        # If Hostname is present, rename it to Computer
        if ( $pscustomobject.psobject.properties.match('Hostname').Count ) {
            $pscustomobject | Add-Member -MemberType NoteProperty -Name 'Computer' -Value $pscustomobject.Hostname -Force
        }
        # Validate schema
        $allowedProperties = Compare-Object -ReferenceObject $securityEventProperties -DifferenceObject $currentEventProperties.name -PassThru -ExcludeDifferent -IncludeEqual
        # General Variables
        $StreamName = 'Custom-SecurityEvent'
        $dcrImmutableId = $securityEventDCRId
    }
    elseif ($TableName -eq 'WindowsEvent') {
      # If Hostname is present, rename it to Computer
      if ( $pscustomobject.psobject.properties.match('Hostname').Count ) {
          $pscustomobject | Add-Member -MemberType NoteProperty -Name 'Computer' -Value $pscustomobject.Hostname -Force
      }

      # If EventData is not preseting, create it and add event as a json string
      if ( -not $pscustomobject.psobject.properties.match('EventData').Count ) {
          $pscustomobject | Add-Member -MemberType NoteProperty -Name 'EventData' -Value $($eventLog | ConvertTo-Json -Compress) -Force
      }
      # Add Type WindowsEvent
      #$pscustomobject | Add-Member -MemberType NoteProperty -Name 'Type' -Value 'WindowsEvent' -Force
      # Validate schema
      $allowedProperties = Compare-Object -ReferenceObject $windowsEventProperties -DifferenceObject $currentEventProperties.name -PassThru -ExcludeDifferent -IncludeEqual
      # General variables
      $StreamName = 'Custom-WindowsEvent'
      $dcrImmutableId = $windowsEventDCRId
    }

    # Select only fields from the allowedProperties variable
    $message = $pscustomobject | Select-Object -Property @($allowedProperties) | ConvertTo-Json -Compress
    
    # Getting proposed and current JSON array size
    $json_array_current_size = ([System.Text.Encoding]::UTF8.GetBytes(@($json_records | Convertfrom-json | ConvertTo-Json))).Length
    $json_array_proposed_size = ([System.Text.Encoding]::UTF8.GetBytes(@(($json_records + $message) | Convertfrom-json | ConvertTo-Json))).Length

    if ($json_array_proposed_size -le $APILimitBytes){
        $json_records += $message
        $json_array_current_size = $json_array_proposed_size
    }
    else {
        write-host "Sending current JSON array before processing more log entries.."
        Send-DataToDCE -payload $json_records -size $json_array_current_size -stream $StreamName -dcrImmutableId $dcrImmutableId
        # Keeping track of how much data we are sending over
        $total_size += $json_array_current_size

        # There are more events to process..
        write-host "######## Resetting JSON Array ########"
        $json_records = @($message)
        $json_array_current_size = ([System.Text.Encoding]::UTF8.GetBytes(@($json_records | Convertfrom-json | ConvertTo-Json))).Length
    }
    
    if($event_count -eq $numberOfRecords){
        write-host "##### Last log entry in $dataset #######"
        Send-DataToDCE -payload $json_records -size $json_array_current_size -stream $StreamName -dcrImmutableId $dcrImmutableId
        # Keeping track of how much data we are sending over
        $total_size += $json_array_current_size
    }
}
Write-Host "[+] Finished processing dataset"
Write-Host "[+] Number of events processed: $event_count"
Write-Host "[+] Total data sent: $($total_size/1mb) MBs"
write-Host "*******************************************"

$results = [PSCustomObject]@{
  EventsSent = "$event_count"
  DataSent = "$($total_size/1mb) MBs"
}
$results