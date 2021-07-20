targetScope = 'resourceGroup'

@description('The name of the action group')
param actionGroupName string

@description('Specifies the prefix for the alert name')
param alertNamePrefix string

@description('Specifies the activity log alerts to create alerts for.')
param activityLogAlerts array = [
  {
    name: 'Service Health Alert'
    properties: {
      condition: {
        allOf: [
          {
            field: 'category'
            equals: 'ServiceHealth'
          }
          {
            field: 'properties.incidentType'
            equals: 'Incident'
          }
        ]
      }
      enabled: true
    }
  }
  {
    name: 'Resource Health Alert'
    properties: {
      condition: {
        allOf: [
          {
            field: 'category'
            equals: 'ResourceHealth'
            containsAny: null
            'odata.type': null
          }
          {
            anyOf: [
              {
                field: 'properties.currentHealthStatus'
                equals: 'Available'
                containsAny: null
                'odata.type': null
              }
              {
                field: 'properties.currentHealthStatus'
                equals: 'Unavailable'
                containsAny: null
                'odata.type': null
              }
              {
                field: 'properties.currentHealthStatus'
                equals: 'Degraded'
                containsAny: null
                'odata.type': null
              }
            ]
            'odata.type': null
          }
          {
            anyOf: [
              {
                field: 'properties.previousHealthStatus'
                equals: 'Available'
                containsAny: null
                'odata.type': null
              }
              {
                field: 'properties.previousHealthStatus'
                equals: 'Unavailable'
                containsAny: null
                'odata.type': null
              }
              {
                field: 'properties.previousHealthStatus'
                equals: 'Degraded'
                containsAny: null
                'odata.type': null
              }
            ]
            'odata.type': null
          }
          {
            anyOf: [
              {
                field: 'properties.cause'
                equals: 'PlatformInitiated'
                containsAny: null
                'odata.type': null
              }
            ]
            'odata.type': null
          }
          {
            anyOf: [
              {
                field: 'status'
                equals: 'Active'
                containsAny: null
                'odata.type': null
              }
              {
                field: 'status'
                equals: 'Resolved'
                containsAny: null
                'odata.type': null
              }
              {
                field: 'status'
                equals: 'In Progress'
                containsAny: null
                'odata.type': null
              }
              {
                field: 'status'
                equals: 'Updated'
                containsAny: null
                'odata.type': null
              }
            ]
            'odata.type': null
          }
        ]
      }
      enabled: true
    }
  }
]

resource actiongroup 'microsoft.insights/actionGroups@2019-06-01' existing = {
  name: actionGroupName
}

resource alertNamePrefix_activityLogAlerts_name 'microsoft.insights/activityLogAlerts@2017-04-01' = [for item in activityLogAlerts: {
  name: '[${alertNamePrefix}] ${item.name}'
  location: 'Global'
  properties: {
    scopes: [
      subscription().id
    ]
    condition: item.properties.condition
    actions: {
      actionGroups: [
        {
          actionGroupId: actiongroup.id
        }
      ]
    }
    enabled: item.properties.enabled
  }
}]
