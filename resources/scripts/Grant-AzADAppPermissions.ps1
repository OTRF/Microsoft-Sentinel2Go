function Grant-AzADAppPermissions {
    <#
    .SYNOPSIS
    A PowerShell wrapper around Az PowerShell and the Microsoft Graph API to grant permissions to a service principal.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: Az PowerShell
    Optional Dependencies: None
    
    .DESCRIPTION
    Grant-AzADAppPermissions is a simple PowerShell wrapper around the Microsoft Graph API to grant permissions to a service principal. 

    .PARAMETER SvcPrincipalName
    Display name of the service principal. It is usually the same name as the Azure AD application.

    .PARAMETER SvcPrincipalId
    Service principal Id to use to add permissions directly. This helps to use service principals such as user assigned manage identities.

    .PARAMETER RolesSPNDisplayName
    Display name of service principal where we would get permissions/roles from. Default value 'Microsoft Graph'. Example: 'Azure Key Vault'

    .PARAMETER PermissionsList
    List of permissions to grant to the service principal.

    .PARAMETER PermissionsType
    Type of permissions. Delegated or Application.

    .PARAMETER PermissionsFile
    JSON file with permissions to grant to the service principal.

    .LINK
    https://docs.microsoft.com/en-us/graph/api/oauth2permissiongrant-post?view=graph-rest-1.0&tabs=http
    https://docs.microsoft.com/en-us/graph/api/serviceprincipal-post-approleassignments?view=graph-rest-1.0&tabs=http
    https://github.com/Azure/Cloud-Katana/blob/main/resources/scripts/Grant-GraphPermissions.ps1
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $false)]
        [String] $SvcPrincipalName,

        [parameter(Mandatory = $false)]
        [string] $SvcPrincipalId,

        [parameter(Mandatory = $false)]
        [string] $RolesSPNDisplayName = "Microsoft Graph",

        [parameter(Mandatory = $False)]
        [string[]] $PermissionsList,

        [parameter(Mandatory = $False)]
        [string[]] $PermissionsType,

        [parameter(Mandatory = $False)]
        [string] $PermissionsFile,

        [Parameter(Mandatory=$false)]
        [ValidateSet("User","ManagedIdentity")]
        [string] $ConnectAs = "User"
    )

    # Processing current security context
    Write-Host "[+] Running under the context of a $ConnectAs account"
    $context = Get-AzContext
    if (!$context) {
        if ($ConnectAs -eq 'User') {
            Connect-AzAccount
        }
        else {
            Connect-AzAccount -Identity
        }
    }

    # Get MS Graph access token
    Write-Host "[+] Getting MS Graph raw acess token.."
    $accessToken = (Get-AzAccessToken -ResourceUrl "https://graph.microsoft.com/").Token
    Write-Host $accessToken
    
    # Set up HTTP headers
    $Headers = @{}
    $Headers["Authorization"] = "Bearer $accessToken"
    $Headers["Content-Type"] = "application/json"
    
    # Getting service principal id if service principal name is provided
    if ($SvcPrincipalName){
        Write-Host "[+] Getting service principal id using the following display name: $SvcPrincipalName"
        $params = @{
            "Method"  = "Get"
            "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$SvcPrincipalName'"
            "Headers" = $Headers
        }
        $SvcPrincipalId = (((Invoke-RestMethod @params).value)[0]).id
        if (!$SvcPrincipalId) {
            Write-Error "Error looking for Azure AD application service principal"
            return
        }
    }

    Write-Host "[+] Service principal ID: $SvcPrincipalId"
    
    # Get service principal to get permissions / roles from
    $params = @{
        "Method"  = "Get"
        "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$rolesSPNDisplayName'"
        "Headers" = $Headers
    }
    $roleSvcAppId = (((Invoke-RestMethod @params).value)[0]).id
    if (!$roleSvcAppId) {
        Write-Error "Error looking for Service Principal to get roles from"
        return
    }
    Write-Host "[+] Found $rolesSPNDisplayName service principal to get roles from with ID: $roleSvcAppId"

    # Process MS Graph permissions
    Write-Host "[+] Retrieving permissions from file.."
    if ($PermissionsFile){
        $permissionsTable = Get-Content $PermissionsFile | ConvertFrom-Json
        $appResourceTypes = $permissionsTable | get-member -MemberType NoteProperty | Select-Object -ExpandProperty Name
    }
    else {
        $permissionsTable = @{
            "$PermissionsType" = $PermissionsList
        }
        $appResourceTypes = @($PermissionsType)
    }

    foreach ($type in $appResourceTypes) {
        # Process permissions type
        $rolePropertyType = Switch ($type) {
            'delegated' { 'oauth2PermissionScopes'}
            'application' { 'appRoles' }
        }

        # Get permissions
        Write-Host "[+] Getting $type Permissions from $RolesSPNDisplayName"
        $params = @{
            "Method"  = "Get"
            "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals/$roleSvcAppId"
            "Headers" = $Headers
        }
        $graphPermissions = (Invoke-Restmethod @params).$rolePropertyType

        # Get Role Assignments
        Write-Host "[+]Processing Role Assignments:"
        $roleAssignments = @()
        $RequiredPermissions = $permissionsTable.$type
        Foreach ($rp in $RequiredPermissions) {
            Write-Host "  [>>] $rp"
            $roleAssignment = $graphPermissions | Where-Object { $_.Value -eq $rp}
            $roleAssignments += $roleAssignment
        }

        # Granting permissions
        Write-Host "[+] Assigning $rolePropertyType to service principal: $SvcPrincipalId"
        if ($type -eq 'application') {
            # Process required permissions
            $resourceAccessObjects = @()
            Write-Host "[+] Creating Resource Access Object"
            foreach ($roleAssignment in $roleAssignments) {
                $ResourceAccessItem = [PSCustomObject]@{
                    principalId = $SvcPrincipalId
                    resourceId = $roleSvcAppId
                    appRoleId = $roleAssignment.Id
                }
                $resourceAccessObjects += $ResourceAccessItem
            }

            foreach ($role in $resourceAccessObjects) {
                Write-Host "[+] Granting appRole to $SvcPrincipalId"
                $params = @{ 
                    "Method"  = "Post" 
                    "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals/$SvcPrincipalId/appRoleAssignments"
                    "Body"    = $role | ConvertTo-Json -Compress -Depth 10
                    "Headers" = $Headers 
                }
                Invoke-Restmethod @params
            }
        }
        else {
            $body = @{
                clientId = $SvcPrincipalId
                consentType = "AllPrincipals"
                principalId = $null
                resourceId = $roleSvcAppId
                scope = "$RequiredPermissions"
            }
    
            $params = @{
                "Method"  = "Post"
                "Uri"     = 'https://graph.microsoft.com/v1.0/oauth2PermissionGrants'
                "Body"    = $body | ConvertTo-Json -compress
                "Headers" = $Headers
            }
            Write-Host "[+] Granting OAuth permissions: $RequiredPermissions"
            Invoke-RestMethod @params
        }
    }
}