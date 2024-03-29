targetScope = 'resourceGroup'

@description('Unique name (within the Resource Group) for the Action group.')
param actionGroupName string

@description('Short name (maximum 12 characters) for the Action group.')
@maxLength(12)
param actionGroupShortName string

@description('Enable or disable the action group.')
param enabled bool = true

@description('The list of email receivers that are part of this action group.')
param emailReceivers array = [
  {
    name: '#TBD#'
    emailAddress: '#TBD#'
    useCommonAlertSchema: 'True'
  }
]

@description('The list of SMS receivers that are part of this action group.')
param smsReceivers array = []

@description('The list of webhook receivers that are part of this action group.')
param webhookReceivers array = []

@description('The list of ITSM receivers that are part of this action group')
param itsmReceivers array = []

@description('The list of AzureAppPush receivers that are part of this action group')
param azureAppPushReceivers array = []

@description('The list of AutomationRunbook receivers that are part of this action group.')
param automationRunbookReceivers array = []

@description('The list of voice receivers that are part of this action group.')
param voiceReceivers array = []

@description('The list of logic app receivers that are part of this action group.')
param logicAppReceivers array = []

@description('The list of azure function receivers that are part of this action group.')
param azureFunctionReceivers array = []

@description('The list of ARM role receivers that are part of this action group. Roles are Azure RBAC roles and only built-in roles are supported.')
param armRoleReceivers array = []

param tags object = {}

resource actionGroup 'Microsoft.Insights/actionGroups@2022-06-01' = {
  name: actionGroupName
  location: 'Global'
  tags: tags
  properties: {
    groupShortName: actionGroupShortName
    enabled: enabled
    emailReceivers: emailReceivers
    smsReceivers: smsReceivers
    webhookReceivers: webhookReceivers
    itsmReceivers: itsmReceivers
    azureAppPushReceivers: azureAppPushReceivers
    automationRunbookReceivers: automationRunbookReceivers
    voiceReceivers: voiceReceivers
    logicAppReceivers: logicAppReceivers
    azureFunctionReceivers: azureFunctionReceivers
    armRoleReceivers: armRoleReceivers
  }
}

output actionGroupId string = actionGroup.id
output actionGroupName string = actionGroup.name
output actionGroupProperties object = actionGroup.properties
output actionGroupResourceGroupName string = resourceGroup().name
output actionGroupSubscriptionId string = subscription().subscriptionId
