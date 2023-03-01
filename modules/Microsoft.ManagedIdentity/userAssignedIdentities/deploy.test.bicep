targetScope = 'resourceGroup'

param managedidentityName string = 'managedidentityName'
param location string = resourceGroup().location
param tags object = {}

module minimal 'deploy.bicep' = {
  name: managedidentityName
  params: {
    managedidentityName: managedidentityName
    location: location
  }
}

module complete 'deploy.bicep' = {
  name: managedidentityName
  params: {
    managedidentityName: managedidentityName
    location: location
    tags: tags
  }
}
