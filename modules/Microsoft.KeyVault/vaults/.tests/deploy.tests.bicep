param location string = resourceGroup().location

module minimal '../deploy.bicep' = {
  name: 'minimal-keyvault-params'
  params: {
    name: 'keyvault'
    publicNetworkAccess: 'Enabled'
    location: location
    loganalyticsWorkspaceId: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/resourceGroupName/providers/Microsoft.OperationalInsights/workspaces/logAnalyticsWorkspaceName'
    tags: {
      environment: 'test'
    }
  }
}
