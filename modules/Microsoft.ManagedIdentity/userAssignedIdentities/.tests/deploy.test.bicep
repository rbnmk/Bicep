targetScope = 'resourceGroup'

param location string = resourceGroup().location

module complete '../deploy.bicep' = {
  name: 'deploy-managed-identity'
  params: {
    managedidentityName: 'managedIdentityName'
    location: location
    tags: {
      environment: 'test'
    }
  }
}
