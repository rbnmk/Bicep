targetScope = 'resourceGroup'

@description('Name for the App Service Plan')
param hostingPlanName string

@description('Name of the Tier to use Basic includes F/D/B/S series, Standard includes P* series')
@allowed([
  'Basic'
  'Standard'
])
param hostingPlanSkuTier string = 'Standard'

@description('Sku to use (F1 to P3V3)')
@allowed([
  'F1'
  'D1'
  'B1'
  'S1'
  'P1V2'
  'P2V2'
  'P3V2'
  'P1V3'
  'P2V3'
  'P3V3'
])
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

