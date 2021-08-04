param keyVaultName string
@allowed([
  'standard'
  'premium'
])
param keyVaultSku string = 'standard'
@allowed([
  'recover'
  'default'
])
param keyVaultCreateMode string = 'default'
param keyVaultAccessPolicies array = []
@allowed([
  'AzureServices'
  'None'
])
param byPass string = 'AzureServices'
@allowed([
  'Allow'
  'Deny'
])
param defaultAction string = 'Deny'
param allowedIPs array = []
param allowedVNETs array = []
param enableSoftDelete bool = true
param enablePurgeProtection bool = false
param enabledForDeployment bool = true
param enabledForDiskEncryption bool = true
param enabledForTemplateDeployment bool = true
param enableRbacAuthorization bool = true
param resourceTags object = {}

resource kv 'Microsoft.KeyVault/vaults@2021-04-01-preview' = {
  name: keyVaultName
  location: resourceGroup().location
  tags: resourceTags
  properties: {
    tenantId: subscription().tenantId
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    createMode: keyVaultCreateMode
    enableSoftDelete: enableSoftDelete
    enablePurgeProtection: enablePurgeProtection
    enableRbacAuthorization: enableRbacAuthorization
    sku: {
      name: keyVaultSku
      family: 'A'
    }
    networkAcls: {
      bypass: byPass
      defaultAction: defaultAction
      ipRules: allowedIPs
      virtualNetworkRules: allowedVNETs
    }
    accessPolicies: keyVaultAccessPolicies
  }
}
