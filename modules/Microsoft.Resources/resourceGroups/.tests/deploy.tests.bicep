targetScope = 'subscription'

param location string = deployment().location

module minimal '../deploy.bicep' = {
  name: 'deploy-resource-group'
  params: {
    location: location
    resourceGroupName: 'rg-psrule'
    tags: {
      environment: 'test'
    }
  }
}
