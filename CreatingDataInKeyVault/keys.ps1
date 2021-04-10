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
# Key vault keys
#######################################################################
# Add key to key vault
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MyRSAKey"
    Destination = "Software"
    Expires = (Get-Date).AddYears(1).ToUniversalTime()
    NotBefore = (Get-Date).ToUniversalTime()
    KeyOps = @("decrypt","encrypt")
    Tags = @{ 'Function' = 'data sign'; 'IT' = 'false' }
}
  
Add-AzKeyVaultKey @params

# Retrieve all keys from a key vault (current version)
$params = @{
    VaultName = $keyVault.VaultName
}

Get-AzKeyVaultKey @params | Select-Object Name, Id, Created

# Retrieve a key from key vault by name (current version)
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MyRSAKey"
}

$key = Get-AzKeyVaultKey @params
# Get JWK
# https://docs.microsoft.com/en-us/javascript/api/@azure/keyvault-keys/jsonwebkey?view=azure-node-latest
$key.Key


# Retrieve all versions of a key from key vault by name
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MyRSAKey"
    IncludeVersions = $true
}

Get-AzKeyVaultKey @params | Select-Object Version, Id

# Retrieve a specific version of the key from key vault by name
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MyRSAKey"
    Version = "<VERSION_NUMBER>"
}

Get-AzKeyVaultKey @params 

# Download public key in .pem format
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MyRSAKey"
    OutFile = "C:\public.pem"
}
Get-AzKeyVaultKey @params

# Remove a key from key vault
$params = @{
    VaultName = $keyVault.VaultName
    Name = "MyRSAKey"
    Force = $true
}

Remove-AzKeyVaultKey @params