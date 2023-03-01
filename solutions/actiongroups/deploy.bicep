targetScope = 'resourceGroup'

@description('')
param actionGroups array

param tags object = {}

var filteredActionGroups = filter(actionGroups, value => contains(value.enabledForsubscriptionIds, subscription().subscriptionId) || contains(value.enabledForsubscriptionIds, 'All'))

resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = [for actionGroup in filteredActionGroups: {
  name: actionGroup.name
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: contains(actionGroup.properties, 'shortName') ? actionGroup.properties.shortName : take(replace(actionGroup.name, '-', ''), 12)
    enabled: contains(actionGroup.properties, 'enabled') ? actionGroup.properties.Enabled : false
    emailReceivers: contains(actionGroup.properties, 'emailReceivers') ? actionGroup.properties.emailReceivers : []
    smsReceivers: contains(actionGroup.properties, 'smsReceivers') ? actionGroup.properties.smsReceivers : []
    webhookReceivers: contains(actionGroup.properties, 'webhookReceivers') ? actionGroup.properties.webhookReceivers : []
    itsmReceivers: contains(actionGroup.properties, 'itsmReceivers') ? actionGroup.properties.itsmReceivers : []
    azureAppPushReceivers: contains(actionGroup.properties, 'azureAppPushReceivers') ? actionGroup.properties.azureAppPushReceivers : []
    automationRunbookReceivers: contains(actionGroup.properties, 'automationRunbookReceivers') ? actionGroup.properties.automationRunbookReceivers : []
    voiceReceivers: contains(actionGroup.properties, 'voiceReceivers') ? actionGroup.properties.voiceReceivers : []
    logicAppReceivers: contains(actionGroup.properties, 'logicAppReceivers') ? actionGroup.properties.logicAppReceivers : []
    azureFunctionReceivers: contains(actionGroup.properties, 'azureFunctionReceivers') ? actionGroup.properties.azureFunctionReceivers : []
    armRoleReceivers: contains(actionGroup.properties, 'armRoleReceivers') ? actionGroup.properties.armRoleReceivers : []
  }
}]

output created_actionGroups array = [for (ag, i) in filteredActionGroups: {
  name: actionGroup[i].name
  id: actionGroup[i].id
  properties: actionGroup[i].properties
  enabledForSubscriptionIds: actionGroups[i].enabledForSubscriptionIds
  resourceGroup: resourceGroup().name
  subscriptionId: subscription().subscriptionId
}]
output debug_actionGroupsToDeploy array = filteredActionGroups
