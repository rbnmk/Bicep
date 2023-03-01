targetScope = 'resourceGroup'

param managedidentityName string
param location string = resourceGroup().location
param tags object = {}

module minimal 'deploy.bicep' = {
  name: managedidentityName
  params: {
    managedidentityName: 'managedIdentity'
    location: location
  }
}

module complete 'deploy.bicep' = {
  name: managedidentityName
  params: {
    managedidentityName: 'managedIdentity'
    location: location
    tags: tags
  }
}
