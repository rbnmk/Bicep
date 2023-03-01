targetScope = 'resourceGroup'

@description('')
param actionGroups array
param suffixId string = utcNow()

var filteredActionGroups = filter(actionGroups, value => contains(value.enabledForsubscriptionIds, subscription().subscriptionId) || contains(value.enabledForsubscriptionIds, 'All'))

module actionGroup '../../modules/Microsoft.Insights/actionGroups/deploy.bicep' = [for actionGroup in actionGroups: {
  name: 'deploy-ag-${actionGroup.name}-${suffixId}'
  params: {
    actionGroupName: actionGroup.name
    actionGroupShortName: contains(actionGroup.properties, 'shortName') ? actionGroup.properties.shortName : take(replace(actionGroup.name, '-', ''), 12)
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
    tags: contains(actionGroup, 'tags') ? actionGroup.tags : {}
  }
}]

output created_actionGroups array = [for (ag, i) in filteredActionGroups: {
  name: actionGroup[i].outputs.actionGroupName
  id: actionGroup[i].outputs.actionGroupId
  properties: actionGroup[i].outputs.actionGroupProperties
  enabledForSubscriptionIds: actionGroups[i].enabledForSubscriptionIds
  resourceGroup: resourceGroup().name
  subscriptionId: subscription().subscriptionId
}]
output debug_actionGroupsToDeploy array = filteredActionGroups
