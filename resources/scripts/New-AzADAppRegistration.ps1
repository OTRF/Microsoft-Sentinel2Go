function New-AzADAppRegistration {
    <#
    .SYNOPSIS
    A PowerShell wrapper around Az PowerShell and the Microsoft Graph API to create/register a new Azure AD application and its respective service principal.
    
    Author: Roberto Rodriguez (@Cyb3rWard0g)
    License: MIT
    Required Dependencies: Az PowerShell
    Optional Dependencies: None
    
    .DESCRIPTION
    New-AzADAppRegistration is a simple PowerShell wrapper around the Azure CLI to create/register a new Azure AD application and its respective service principal.

    .PARAMETER Name
    The name of the new Azure AD Application and service principal.

    .PARAMETER NativeApp
    Switch to register an application which can be installed on a user's device or computer.

    .PARAMETER SignInAudience
    Specifies the Microsoft accounts that are supported for the current application. The possible values are: AzureADMyOrg, AzureADMultipleOrgs, AzureADandPersonalMicrosoftAccount (default), and PersonalMicrosoftAccount

    .PARAMETER HomePageUrl
    Home page or landing page of the application.

    .PARAMETER IdentifierUris
    Space-separated unique URIs that Azure AD can use for this app.

    .PARAMETER ReplyUrls
    Space-separated URIs to which Azure AD will redirect in response to an OAuth 2.0 request. The value does not need to be a physical endpoint, but must be a valid URI.

    .PARAMETER AddSecret
    Switch to create add credentials to the application.

    .PARAMETER UseV2AccessTokens
    Switch to set application to use V2 access tokens.

    .PARAMETER RequireAssignedRole
    Switch to require assigned role to use the application. This restricts who can access your application. Only users that have the role assigned.

    .PARAMETER AssignAppRoleToUser
    Use thisparameter to assign an app role to a service principal. Example: wardog@domain.onmicrosoft.com.

    .PARAMETER ConnectAs
    What security context you are running the script as. It could be User or ManagedIdentity.

    .LINK
    https://docs.microsoft.com/en-us/cli/azure/ad/app?view=azure-cli-latest#az_ad_app_create
    https://github.com/Azure/SimuLand/blob/main/2_deploy/_helper_docs/registerAADAppAndSP.md
    #>

    [cmdletbinding()]
    Param(
        [parameter(Mandatory = $True)]
        [String] $Name,

        [Parameter(Mandatory=$false)]
        [switch] $NativeApp,

        [Parameter(Mandatory=$false)]
        [ValidateSet("AzureADMyOrg","AzureADMultipleOrgs","AzureADandPersonalMicrosoftAccount","PersonalMicrosoftAccount")]
        [string] $SignInAudience = "AzureADMyOrg",

        [Parameter(Mandatory=$false)]
        [string] $HomePageUrl,

        [Parameter(Mandatory=$false)]
        [string] $IdentifierUris,

        [Parameter(Mandatory=$false)]
        [string] $ReplyUrls,

        [Parameter(Mandatory=$false)]
        [switch] $AddSecret,

        [Parameter(Mandatory=$false)]
        [switch] $UseV2AccessTokens,

        [Parameter(Mandatory=$false)]
        [switch] $RequireAssignedRole,

        [Parameter(Mandatory=$false)]
        [string] $AssignAppRoleToUser,

        [Parameter(Mandatory=$false)]
        [ValidateSet("User","ManagedIdentity")]
        [string] $ConnectAs = "User"
    )

    # Variables
    $ScriptOutputs = @{}

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

    # Verify if application exists
    $params = @{
        "Method"  = "Get"
        "Uri"     = "https://graph.microsoft.com/v1.0/applications?`$filter=displayName eq '$Name'"
        "Headers" = $Headers
    }
    $registeredApp = ((Invoke-RestMethod @params).value)[0]

    if ($registeredApp){
        Write-Host "[!] Azure AD application $Name already exists!"
    }
    else {
        # Registering new application
        Write-Host "[+] Registering new Azure AD application: $Name"
        $body = @{ 
            displayName = "$Name"
            signInAudience = "$SignInAudience"
            api = @{
                oauth2PermissionScopes = @(
                    @{
                        id = [guid]::NewGuid()
                        adminConsentDescription = "Allow the application to access $Name on behalf of the signed-in user."
                        adminConsentDisplayName = "Access $Name"
                        userConsentDescription = "Allow the application to access $Name on your behalf."
                        userConsentDisplayName = "Access $Name"
                        value = "user_impersonation"
                        type = "Admin"
                        isEnabled = $True
                    }
                )
            }
        }
        if ($NativeApp) {
            $body["publicClient"] = @{
                redirectUris = @("http://localhost")
            }
            $body['isFallbackPublicClient'] = $true
        }
        if ($HomePageUrl){
            $body['web'] = @{
                homePageUrl = $HomePageUrl
            }
        }
        $params = @{
            "Method"  = "Post"
            "Uri"     = "https://graph.microsoft.com/v1.0/applications"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress -Depth 20
        }
        $registeredApp = Invoke-RestMethod @params
        Start-Sleep -s 15
    }
    Write-Host $registeredApp
    $ScriptOutputs['appName'] = $Name
    $ScriptOutputs['appId'] = $registeredApp.AppId

    if ($IdentifierUris) {
        Write-Host "[+] Updating $Name application: Updating the URIs that identify the application within its Azure AD tenant."
        $body = @{
            identifierUris = @($IdentifierUris)
        }
        $params = @{
            "Method"  = "Patch"
            "Uri"     = "https://graph.microsoft.com/v1.0/applications/$($registeredApp.id)"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress
        }
        Invoke-RestMethod @params
    }

    if (($ReplyUrls) -and !($NativeApp) ) {
        Write-Host "[+] Updating $Name application: Updating URLs where user tokens are sent for sign-in"
        $body = @{ 
            web = @{
                redirectUris = @($ReplyUrls)
                implicitGrantSettings = @{
                    enableIdTokenIssuance = $True
                }
            }
        }
        $params = @{
            "Method"  = "Patch"
            "Uri"     = "https://graph.microsoft.com/v1.0/applications/$($registeredApp.id)"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress -Depth 10
        }
        Invoke-RestMethod @params
    }
     
    # Creating the new Azure AD application service principal
    # Verify if service principal exists
    Write-Host "[+] Creating a service principal mapped to the $Name application"
    $params = @{
        "Method"  = "Get"
        "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals?`$filter=displayName eq '$Name'"
        "Headers" = $Headers
    }
    $appSP = ((Invoke-RestMethod @params).value)[0]
    if ($appSP){
        Write-Host "[!] Azure AD application $Name already has a service principal"
    }
    else {
        $body = @{ 
            appId = $registeredApp.appId
        }
        $params = @{
            "Method"  = "Post"
            "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress -Depth 10
        }
        $appSP = Invoke-RestMethod @params
        # Sleep
        Start-Sleep -s 15
    }
    Write-Host $appSP
    $ScriptOutputs['servicePrincipalId'] = $appSP.id

    #Add credentials to application
    if ($AddSecret) {
        Write-Host "[+] Adding a secret to $Name application"
        $pwdCredentialName = $($Name + "Secret")
        $body = @{
            passwordCredential = @{ displayName = "$($pwdCredentialName)" }
        }
        $params = @{
            "Method"  = "Post"
            "Uri"     = "https://graph.microsoft.com/v1.0/applications/$($registeredApp.id)/addPassword"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress
        }
        $credentials = Invoke-RestMethod @params

        if (!($credentials)){
            Write-Error "Error adding credentials to $Name"
            return
        }
        
        Write-Host "[+] Extracting secret text from results. Save it for future operations"
        $secret = $credentials.secretText
        $ScriptOutputs['appSecretText'] = $secret
        $ScriptOutputs['appCredentialName'] = $pwdCredentialName
    }

    if ($UseV2AccessTokens){
        Write-Host "[+] Updating $Name application: Setting application to use V2 access tokens"
        # Set application to use V2 access tokens
        $body = @{
            api = @{
                requestedAccessTokenVersion = 2
            }
        }
        $params = @{
            "Method"  = "Patch"
            "Uri"     = "https://graph.microsoft.com/v1.0/applications/$($registeredApp.id)"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress
        }
        Invoke-RestMethod @params
    }

    if($RequireAssignedRole){
        Write-Host "[+] Updating $Name application: Setting application to require users being assigned a role "
        $body = @{
            appRoleAssignmentRequired = $True
        }
        $params = @{
            "Method"  = "Patch"
            "Uri"     = "https://graph.microsoft.com/v1.0/servicePrincipals/$($appSP.Id)"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress
        }

        Invoke-RestMethod @params
        # Sleep
        Start-Sleep -s 15
    }

    if($AssignAppRoleToUser){
        Write-Host "[+] Granting app role assignment to $AssignAppRoleToUser "
        Write-Host "    [>>] Getting user's principal ID"
        $params = @{
            "Method"  = "Get"
            "Uri"     = "https://graph.microsoft.com/v1.0/users/$AssignAppRoleToUser"
            "Headers" = $Headers
        }
        $principalId = (Invoke-RestMethod @params).Id

        Write-Host "    [>>] Adding user to application.."
        $body = @{
            appRoleId = [Guid]::Empty.Guid
            principalId = $principalId
            resourceId = $AppSp.id
        }

        $params = @{
            "Method"  = "Post"
            "Uri"     = "https://graph.microsoft.com/v1.0/users/$AssignAppRoleToUser/appRoleAssignments"
            "Headers" = $Headers
            "Body"    = $body | ConvertTo-Json -Compress
        }

        $AssignAppRoleResult = Invoke-RestMethod @params
        if (!$AssignAppRoleResult) {
            Write-Error "Error granting app role assignment to user $AssignAppRoleToUser"
            return
        }
    }
    Write-Host "[+] Additional Output: "
    $ScriptOutputs
}