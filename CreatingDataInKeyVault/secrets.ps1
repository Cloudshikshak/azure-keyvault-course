#######################################################################
# Key vault initialization
#######################################################################
# Login/connect to azure account
Login-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "<SUBSCRIPTION_NAME>" | Select-AzSubscription

# Create a new resource group
$ResourceGroup = New-AzResourceGroup -Name "<RESOURCE_GROUP>" -Location EastUS

# Or get existing resource group
$ResourceGroup = Get-AzResourceGroup -Name "<RESOURCE_GROUP>"

# Display Resource Group Name
$ResourceGroup.ResourceGroupName

#######################################################################
# Get Key Vault
#######################################################################

$KeyVaultName = "<KEYVAULT_NAME>"

$keyVault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroup.ResourceGroupName
$keyVault.VaultName

#######################################################################
# Key vault secrets
#######################################################################
# Create OR Update secret in key vault. If secret with given name does not exists,
# it create or if the secret with given name exists, it creates new version of it.

# Convert secret to a secure string
$SecretValue = ConvertTo-SecureString "mysupersecretstring" -AsPlainText -Force

# Complete list of supported parameters for Set-AzKeyVaultSecret command: 
# https://docs.microsoft.com/en-us/powershell/module/az.keyvault/set-azkeyvaultsecret?view=azps-5.5.0
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MySecret"
    SecretValue = $SecretValue
    Expires = (Get-Date).AddYears(1).ToUniversalTime()
    NotBefore = (Get-Date).AddDays(1).ToUniversalTime()
    ContentType = "DBPassword"
    Tags = @{ 'Severity' = 'high'; 'IT' = 'true' }
}

Set-AzKeyVaultSecret @params
 
# New versions of same secret
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MySecret"
    SecretValue = $secretvalue
    Expires = (Get-Date).AddYears(1).ToUniversalTime()
    NotBefore = (Get-Date).AddDays(1).ToUniversalTime()
    ContentType = "API Key"
    Tags = @{ 'Severity' = 'high'; 'IT' = 'true' }
}

Set-AzKeyVaultSecret @params

# Retrieve all secrets from a key vault (current version)
$params = @{
    VaultName = $keyVault.VaultName
}

Get-AzKeyVaultSecret @params | Select-Object Name, Id, Created

# Retrieve a secret from key vault by name (current version)
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MySecret"
}

$secret = Get-AzKeyVaultSecret @params
ConvertFrom-SecureString $secret.SecretValue -AsPlainText

# Retrieve all versions of a secret from key vault by name
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MySecret"
    IncludeVersions = $true
}

Get-AzKeyVaultSecret @params | Select-Object Version, Id, Created

# Retrieve a specific version of the secret from key vault by name
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MySecret"
    Version = "<VERSION_NUMBER>"
}

Get-AzKeyVaultSecret @params 

# Remove a secret from key vault
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MySecret"
    Force = $true
}

Remove-AzKeyVaultSecret @params