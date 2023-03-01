param location string = resourceGroup().location

module test '../deploy.bicep' = {
  name: 'deploy-storage-account'
  params: {
    accountType: 'Standard_LRS'
    kind: 'StorageV2'
    name: 'storageaccount1'
    location: location
    tags: {
      environment: 'test'
    }
  }
}
