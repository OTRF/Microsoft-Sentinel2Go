function New-ManagedIdentity {
    <#
    .SYNOPSIS
    A PowerShell wrapper around the Azure CLI "az identity" command to create a user assigned managed identity.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: Azure CLI
    Optional Dependencies: None
    
    .DESCRIPTION
    New-ManagedIdentity is a simple PowerShell wrapper around the Azure CLI "az identity" command to create a user assigned managed identity.

    .PARAMETER Name
    The name of the new user assigned managed identity.

    .PARAMETER ResourceGroup
    The name of the resource group to verify if managed identity exists in.

    .LINK
    https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/how-manage-user-assigned-managed-identities?pivots=identity-mi-methods-azp
    https://docs.microsoft.com/en-us/azure/app-service/overview-managed-identity?tabs=dotnet
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String] $Name,

        [parameter(Mandatory = $True)]
        [String] $ResourceGroup
    )

    # Validate signed in user
    $signedInUser = az ad signed-in-user show --query '[displayName, mail]' | convertfrom-json
    if (!($signedInUser)){
        az login
    }
    else {
        Write-Host "[+] Using the following user context:"
        Write-Host "[+] UserName: $($SignedInUser[0])"
        Write-Host "[+] E-mail: $($SignedInUser[1])"
    }

    # Verify if identity already exists
    $Name= $Name.Trim() -replace "['`"]", ""
    $results = $(az identity list --query "[?name=='$Name']" --resource-group $ResourceGroup| ConvertFrom-Json)[0]
    if ($results){
        Write-Host "[!] User assigned identity $Name already exists!"
    }
    else {
        Write-Host "[+] Creating User Assigned Managed Identity: $Name"
        $results = az identity create -g $ResourceGroup -n $Name | ConvertFrom-Json
        if ($results) {
            Write-Host "[+] User assigned managed identity was created successfully!"
            <#
            clientId        : CLIENTID
            clientSecretUrl : https://control-eastus.identity.azure.net/subscriptions/SUBSCRIPTIONID/resourcegroups/apps/providers/
                            Microsoft.ManagedIdentity/userAssignedIdentities/IDENTITYNAME/credentials?tid=TENANTID&oid=PRINCIPALID&aid=CLIENTID
            id              : /subscriptions/SUBSCRIPTIONID/resourcegroups/apps/providers/Microsoft.ManagedIdentity/userAssignedIde
                            ntities/IDENTITYNAME
            location        : eastus
            name            : IDENTITYNAME
            principalId     : PRINCIPALID
            resourceGroup   : apps
            tags            : 
            tenantId        : TENANTID
            type            : Microsoft.ManagedIdentity/userAssignedIdentities
            #>
            $results
        }
        else {
            Write-Host "[!] User assigned identity was not created."
        }
    }
}