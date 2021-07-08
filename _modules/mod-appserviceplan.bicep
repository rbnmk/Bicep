targetScope = 'resourceGroup'

@description('')
param hostingPlanName string

@description('')
param hostingPlanSkuTier string = 'Standard'

@description('')
param hostingPlanSkuName string = 'S1'

param tags object = {}

resource hostingPlan 'Microsoft.Web/serverfarms@2021-01-01' = {
  name: hostingPlanName
  location: resourceGroup().location
  tags: tags
  sku: {
    tier: hostingPlanSkuTier
    name: hostingPlanSkuName
  }
  properties: {}
  dependsOn: []
}

output hostingPlanName string = hostingPlan.name
output hostingPlanResourceId string = hostingPlan.id
output hostingPlaneResourceGroupName string = resourceGroup().name

