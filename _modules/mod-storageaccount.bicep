//Define Azure Files parmeters
param storageaccountlocation string = 'westeurope'
param storageaccountName string
@allowed([
  'BlobStorage'
  'BlockBlobStorage'
  'FileStorage'
  'StorageV2'
  'Storage'
])
param storageaccountkind string = 'StorageV2'
param storageaccountglobalRedundancy bool = false
param allowBlobPublicAccess bool = false
param isHnsEnabled bool = false
@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'
@allowed([
  'Enabled'
  'Disabled'
])
param largeFileSharesState string = 'Disabled'
param tags object = {}


resource storageaccount 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name : storageaccountName
  location : storageaccountlocation
  kind : storageaccountkind
  tags : tags
  sku: {
    name: storageaccountglobalRedundancy ? 'Standard_GRS' : 'Standard_LRS'
  }
  properties: {
    isHnsEnabled: isHnsEnabled
    minimumTlsVersion: 'TLS1_2'
    accessTier: accessTier
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: true
    largeFileSharesState: largeFileSharesState
    allowSharedKeyAccess: null
  }
}

output storageAccountName string = storageaccount.name
output storageAccountResourceGroupName string = resourceGroup().name
