@description('The ID of Log Analytics workspace')
param logAnalyticsWorkspaceName string

@description('The ID of the action group')
param actionGroupName string

@description('Specifies the prefix for the alert name')
param alertNamePrefix string = ''

@description('Specifies the query rules to create alerts for.')
param scheduledQueryRules array = []

resource actiongroup 'microsoft.insights/actionGroups@2019-06-01' existing = {
  name: actionGroupName
}

resource loganalyticsworkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
}

resource alertNamePrefix_scheduledQueryRules_name 'Microsoft.Insights/scheduledQueryRules@2018-04-16' = [for item in scheduledQueryRules: {
  name: '[${alertNamePrefix}] ${item.name}'
  location: resourceGroup().location
  properties: {
    description: item.properties.description
    enabled: item.properties.enabled
    source: {
      authorizedResources: item.properties.source.authorizedResources
      query: item.properties.source.query
      dataSourceId: loganalyticsworkspace.id
      queryType: item.properties.source.queryType
    }
    schedule: item.properties.schedule
    action: {
      'odata.type': 'Microsoft.WindowsAzure.Management.Monitoring.Alerts.Models.Microsoft.AppInsights.Nexus.DataContracts.Resources.ScheduledQueryRules.AlertingAction'
      severity: item.properties.action.severity
      throttlingInMin: item.properties.action.throttlingInMin
      aznsAction: {
        actionGroup: [
          actiongroup.id
        ]
        emailSubject: null
        customWebhookPayload: null
      }
      trigger: item.properties.action.trigger
    }
  }
}]
