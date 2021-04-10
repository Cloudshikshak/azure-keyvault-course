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

# Create a new VM
# Make sure it is a strong password
$cred = Get-Credential

$vm_params = @{
    Name = "MyVM"
    Credential = $cred
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Image = "win2016datacenter"
    size = "Standard_B1ls"
}
$VM = New-AzVM @vm_params

# OR
# Get an existing VM
$VM = Get-AzVM -ResourceGroupName $ResourceGroup.ResourceGroupName -Name "MyVM"
$VM.Name

# Create a new Key Vault
# Key Vault Name must be unique globally
$random = Get-Random -Minimum 1000 -Maximum 9999
$KeyVaultName = "cs-vmencrypt-" + $random
$KeyVaultName

# Key vault parameters for creating a new key vault
$params = @{
    Name = $KeyVaultName
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    Location = $ResourceGroup.Location
    Sku = "Standard"
    EnabledForDiskEncryption = $true
}

$KeyVault = New-AzKeyVault @params

# Use an existing key vault
$KeyVault = Get-AzKeyVault -VaultName "<KEYVAULT_NAME>"
# Display new Vault Name
$KeyVault.VaultName

# Create a Key Encrypting Key
$kekParameters = @{
    VaultName = $KeyVault.VaultName
    Name = "kek"
    Destination = "Software"
}

$KEK = Add-AzKeyVaultKey @kekParameters

# Encrypt the Disks using Azure Disk Encryption
$ade_params = @{
    ResourceGroupName = $ResourceGroup.ResourceGroupName
    VMname = $VM.Name
    DiskEncryptionKeyVaultUrl = $KeyVault.VaultUri
    DiskEncryptionKeyVaultId = $KeyVault.ResourceId
    KeyEncryptionKeyUrl = $KEK.Key.Kid
    KeyEncryptionKeyVaultId = $KeyVault.ResourceId
}
Set-AzVMDiskEncryptionExtension @ade_params

# Check the status of disk encryption (on another terminal)
Get-AzVmDiskEncryptionStatus -VMName MyVM -ResourceGroupName AzureKeyVaultCourse