#######################################################################
# Install PowerShell Az Module
#######################################################################

Install-Module -Name Az -AllowClobber -Scope CurrentUser

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

# Creating a new Key Vault
# Must be unique globally
$random = Get-Random -Minimum 1000 -Maximum 9999
$KeyVaultName = "cs-keyvault-" + $random

$KeyVaultName

# Method 1:
New-AzKeyVault -Name $KeyVaultName -ResourceGroupName $ResourceGroup.ResourceGroupName -Location $ResourceGroup.Location -Sku "Standard"

# Method 2: Splatting
# Key vault parameters for creating a new key vault
$params = @{
    Name = $KeyVaultName
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Location = $ResourceGroup.Location
    Sku = "Standard"
}

$KeyVault = New-AzKeyVault @params

# Display key vault information
$KeyVault

# Display new Vault Name
$KeyVault.VaultName

# Get-AzKeyVault to get get key vault by name
$vault = Get-AzKeyVault -VaultName $KeyVaultName -ResourceGroupName $ResourceGroup.ResourceGroupName
$vault