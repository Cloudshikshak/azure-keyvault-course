#######################################################################
# Key vault initialization
#######################################################################
# Login/connect to azure account
Login-AzAccount

#Select the correct subscription
Get-AzSubscription -SubscriptionName "SUBSCRIPTION_NAME" | Select-AzSubscription

# Create a new resource group
$ResourceGroup = New-AzResourceGroup -Name "<RESOURCE_GROUP>" -Location EastUS

# Or get existing resource group
$ResourceGroup = Get-AzResourceGroup -Name "<RESOURCE_GROUP>"

# Display Resource Group Name
$ResourceGroup.ResourceGroupName

$KeyVaultName = "<KEYVAULT_NAME>"
$KeyVault = Get-AzKeyVault -VaultName $KeyVaultName

# Display  Vault Name
$KeyVault.VaultName


# Grant access to keys and secrets for a user
# Documentation: https://docs.microsoft.com/en-us/powershell/module/az.keyvault/set-azkeyvaultaccesspolicy?view=azps-5.6.0
$accessPolicyParams = @{
    VaultName = $keyVault.VaultName
    ResourceGroupName = $keyVault.ResourceGroupName
    PermissionsToSecrets = @("get","list")
    PermissionsToKeys = @("get","list","import")
    UserPrincipalName = "<USER_ID_OR_EMAIL>"
}

Set-AzKeyVaultAccessPolicy @accessPolicyParams

