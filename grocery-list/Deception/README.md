# Microsoft Sentinel + Azure Key Vault Honey Tokens

## Create Unique Azure Function Application Name

```PowerShell
$functionAppName = (-join ('honeytoken',-join ((65..90) + (97..122) | Get-Random -Count 10 | % {[char]$_}))).ToLower()
```