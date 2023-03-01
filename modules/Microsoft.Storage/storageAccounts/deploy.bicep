param location string = 'westeurope'
param name string
param accountType string
param kind string
param accessTier string = 'Hot'
param minimumTlsVersion string = 'TLS1_2'
param supportsHttpsTrafficOnly bool = true
param allowBlobPublicAccess bool = false
param allowSharedKeyAccess bool  = true
param allowCrossTenantReplication bool = true
param defaultOAuth bool = false
param networkAclsBypass string = 'AzureServices'
param networkAclsDefaultAction string = 'Deny'
param isContainerRestoreEnabled bool = false
param isBlobSoftDeleteEnabled bool = true
param blobSoftDeleteRetentionDays int = 7
param isContainerSoftDeleteEnabled bool = true
param containerSoftDeleteRetentionDays int = 7
param changeFeed bool = false
param isVersioningEnabled bool = false
param isShareSoftDeleteEnabled bool = true
param shareSoftDeleteRetentionDays int = 7
param tags object = {}

resource storage_resource 'Microsoft.Storage/storageAccounts@2021-06-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    accessTier: accessTier
    minimumTlsVersion: minimumTlsVersion
    supportsHttpsTrafficOnly: supportsHttpsTrafficOnly
    allowBlobPublicAccess: allowBlobPublicAccess
    allowSharedKeyAccess: allowSharedKeyAccess
    allowCrossTenantReplication: allowCrossTenantReplication
    defaultToOAuthAuthentication: defaultOAuth
    networkAcls: {
      bypass: networkAclsBypass
      defaultAction: networkAclsDefaultAction
      ipRules: []
    }
  }
  sku: {
    name: accountType
  }
  kind: kind
  dependsOn: []
}

resource storage_default 'Microsoft.Storage/storageAccounts/blobServices@2021-06-01' = {
  parent: storage_resource
  name: 'default'
  properties: {
    restorePolicy: {
      enabled: isContainerRestoreEnabled
    }
    deleteRetentionPolicy: {
      enabled: isBlobSoftDeleteEnabled
      days: blobSoftDeleteRetentionDays
    }
    containerDeleteRetentionPolicy: {
      enabled: isContainerSoftDeleteEnabled
      days: containerSoftDeleteRetentionDays
    }
    changeFeed: {
      enabled: changeFeed
    }
    isVersioningEnabled: isVersioningEnabled
  }
}

resource Microsoft_Storage_storageAccounts_fileservices_storageAccountName_default 'Microsoft.Storage/storageAccounts/fileServices@2021-06-01' = {
  parent: storage_resource
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: isShareSoftDeleteEnabled
      days: shareSoftDeleteRetentionDays
    }
  }
  dependsOn: [
    storage_default
  ]
}
