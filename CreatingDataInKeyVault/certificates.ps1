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
# Key vault Certificates
#######################################################################
# Add certificate to key vault

# Create a self-signed certificate
# Certificate Policy: https://docs.microsoft.com/en-us/powershell/module/az.keyvault/new-azkeyvaultcertificatepolicy?view=azps-5.5.0
$params = @{
    IssuerName = "Self"
    SubjectName = "CN=www.mycompany.com"
    SecretContentType = "application/x-pkcs12"
    ValidityInMonths = 12
}

# Create in-memory certificate policy object
$Policy = New-AzKeyVaultCertificatePolicy @params
  
# Create certificate in key vault
$certificateParams = @{
    VaultName = $keyVault.VaultName
    Name = "MyCompanyCert"
    CertificatePolicy = $Policy
}
  
Add-AzKeyVaultCertificate @certificateParams

# Get Certificate from key vault by name
Get-AzKeyVaultCertificate -VaultName $keyVault.VaultName -Name "MyCompanyCert"
  
# Get RSA public Key of the certificate
$key = Get-AzKeyVaultKey -VaultName $keyVault.VaultName -Name "MyCompanyCert"
$key
# Get JWK
$key.Key

# Get certificate as secret
Get-AzKeyVaultSecret -VaultName $keyVault.VaultName -Name "MyCompanyCert"