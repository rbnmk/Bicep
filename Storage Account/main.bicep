param location string = resourceGroup().location
param stgnamePrefix string = 'stg'
param kvnamePrefix string = 'kev'
param vnetNamePrefix string = 'vnt'
param globalRedundancy bool = true // defaults to true, but can be overridden

var storageAccountName = '${stgnamePrefix}${uniqueString(resourceGroup().id)}'
var keyVaultName = '${kvnamePrefix}${uniqueString(resourceGroup().id)}'
var vnetName = '${vnetNamePrefix}${uniqueString(resourceGroup().id)}'

resource stg 'Microsoft.Storage/storageAccounts@2019-06-01' = {
    name: storageAccountName // must be globally unique
    location: location
    kind: 'Storage'
    sku: {
        name: globalRedundancy ? 'Standard_LRS' : 'Standard_GRS' // if true --> GRS, else --> LRS
    }
}

resource blob 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = {
    name: '${stg.name}/default/logs'
    // dependsOn will be added when the template is compiled
  }

resource kv 'Microsoft.KeyVault/vaults@2019-09-01' = {
    name: keyVaultName
    location: location
    properties: {
    enabledForDeployment: true
    enabledforDiskEncryption: true
    enabledforTemplateDeployment: true
    networkAcls: {
        bypass: 'AzureServices'
        defaultAction: 'bypass'
        }
    }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-05-01' = {
    name: vnetName
    location: location
    properties: {
        addressSpace: {
          addressPrefixes: [
            '20.0.0.0/16'
          ]
        }
}
}

output storageId string = stg.id // output resourceId of storage account
output computedStorageName string = stg.name
output blobEndpoint string = stg.properties.primaryEndpoints.blob // replacement for reference(...).*