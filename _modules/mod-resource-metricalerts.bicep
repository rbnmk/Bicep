param actionGroupName string

@description('Specifies the prefix for the alert name')
param alertNamePrefix string = '[CUSTOMER-SLA]]'

@description('Specifies the metrics to create alerts for.')
param metricAlerts array = []
param targetResourceRegion string = 'WestEurope'
param resource string = ''

resource alertNamePrefix_metricAlerts_name_ResourceId_8 'Microsoft.Insights/metricAlerts@2018-03-01' = [for item in metricAlerts: if (resource != '') {
  name: '[${alertNamePrefix}] ${split(resource,'/')[8]} ${item.name}'
  location: 'global'
  properties: {
    description: item.properties.description
    severity: item.properties.severity
    enabled: item.properties.enabled
    scopes: [
      resource
    ]
    evaluationFrequency: item.properties.evaluationFrequency
    windowSize: item.properties.windowSize
    targetResourceType: item.properties.targetResourceType
    targetResourceRegion: targetResourceRegion
    criteria: item.properties.criteria
    actions: [
      {
        actionGroupId: resourceId('microsoft.insights/actionGroups', actionGroupName)
      }
    ]
  }
}]
