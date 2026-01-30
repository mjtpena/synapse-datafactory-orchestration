// Key Vault module for secrets management
@description('Key Vault name')
param keyVaultName string

@description('Location for Key Vault')
param location string

@description('Environment name')
param environment string

@description('Azure AD tenant ID')
param tenantId string = subscription().tenantId

@description('SKU for Key Vault')
param skuName string = 'standard'

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: skuName
    }
    tenantId: tenantId
    enableRbacAuthorization: true
    enableSoftDelete: true
    softDeleteRetentionInDays: 7
    enablePurgeProtection: true
    networkAcls: {
      defaultAction: 'Allow' // Change to 'Deny' for production
      bypass: 'AzureServices'
    }
  }
  tags: {
    Environment: environment
    Purpose: 'SecretsManagement'
  }
}

output keyVaultName string = keyVault.name
output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
