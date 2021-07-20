targetScope = 'resourceGroup'

param AppInsightsName string
param AppName string
param tags object = {
  
}

var default_tags = {
  'hidden-link:${resourceGroup().id}/providers/Microsoft.Web/sites/${AppName}': 'Resource'
  displayName: 'Application Insights'
}

resource ApplicationInsights 'Microsoft.Insights/components@2020-02-02-preview' = {
  name: AppInsightsName
  location: resourceGroup().location
  kind: 'web'
  tags: union(tags, default_tags)
  properties: {
    Application_Type: 'web'
  }
}

output applicationInsightsName string = ApplicationInsights.name
output applicationInsightsResourceId string = ApplicationInsights.id
output applicationInsightsType string = ApplicationInsights.properties.Application_Type
