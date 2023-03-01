@description('Name for the Action Rule.')
param actionruleName string

@description('Description for the Action Rule.')
param actionruleDescription string = 'Action rule created via Bicep template'

@description('Type of action rule, either Suppression (Suppress alerts) or ActionGroup')
@allowed([
  'AddActionGroups'
  'RemoveAllActionGroups'
])
param actionRuleType string

@description('Scope for the action rule leave empty for subscription, works with actionRuleScopeValues parameter.')
@allowed([
  ''
  'Resource'
  'ResourceGroup'
  'Subscription'
])
param actionruleScope string

@description('Array of resource IDs, either Resource Group or Resource. Works when actionRuleScope is set to Resource or ResourceGroup.')
param actionruleScopeValues array = []

@description('Start Date for the action rule to become active in MM/dd/YYYY notation')
param actionruleEffectiveFrom string

@description('End Date for the action rule to become active in MM/dd/YYYY notation')
param actionruleEffectiveUntil string

@description('Start Time for the action rule to become active in 24 hour (UTC) notation')
param actionruleStartTime string

@description('End Time for the action rule to become active in 24 hour (UTC) notation')
param actionruleEndTime string

@description('Decide if the action rule is active on a certain interval or always')
@allowed([
  'Once'
  'Daily'
  'Weekly'
  'Monthly'
  'Always'
])
param actionruleRecurrenceType string

@description('0 = Sunday, 1 = Monday and so on')
@allowed([
  null
  ''
  'Monday'
  'Tuesday'
  'Wednesday'
  'Thursday'
  'Friday'
  'Saturday'
  'Sunday'
])
param actionruleWeeklyRecurrence array = []

@description('1 = First day of the month, 2 = Second day of the month and so on.')
@allowed([
  null
  ''
  '1'
  '2'
  '3'
  '4'
  '5'
  '6'
  '7'
  '8'
  '9'
  '10'
  '11'
  '12'
  '13'
  '14'
  '15'
  '16'
  '17'
  '18'
  '19'
  '20'
  '21'
  '22'
  '23'
  '24'
  '25'
  '26'
  '27'
  '28'
  '29'
  '30'
  '31'
])
param actionruleMonthlyRecurrence array = []

@description('Conditions for the action rule in object format.')
param actionRuleConditions array

@description('Enable or Disable the action rule. Bool.')
param actionRuleStatus bool = true

@description('ResourceId of the action group. Only used when actionruleType is set to ActionGroup.')
param actionGroupIds array = []

@description('TimeZone for the Action Rule schedule')
param scheduleTimeZone string = 'W. Europe Standard Time'

param tags object = {}

var filteredActionRuleScopeValues = filter(actionruleScopeValues, value => contains(value, subscription().subscriptionId))

var ruleScope = {
  Resource: filteredActionRuleScopeValues
  ResourceGroup: empty(actionruleScopeValues) ? array(resourceGroup().id) : filteredActionRuleScopeValues
  Subscription: empty(actionruleScopeValues) ? array(subscription().id) : filteredActionRuleScopeValues
}

var recurrenceType = {
  Once: {
    recurrenceType: 'Once'
    schedule: {
      effectiveFrom: actionruleEffectiveFrom
      effectiveUntil: actionruleEffectiveUntil
      timeZone: scheduleTimeZone
    }
  }
  Daily: {
    effectiveFrom: actionruleEffectiveFrom
    effectiveUntil: actionruleEffectiveUntil
    recurrences: [
      {
        recurrenceType: 'Daily'
        startTime: actionruleStartTime
        endTime: actionruleEndTime
      }
    ]
    timeZone: scheduleTimeZone
  }
  Weekly: {
    effectiveFrom: actionruleEffectiveFrom
    effectiveUntil: actionruleEffectiveUntil
    recurrences: [
      {
        recurrenceType: 'Weekly'
        daysOfWeek: actionruleWeeklyRecurrence
        startTime: actionruleStartTime
        endTime: actionruleEndTime
      }
    ]
    timeZone: scheduleTimeZone
  }
  Monthly: {
    effectiveFrom: actionruleEffectiveFrom
    effectiveUntil: actionruleEffectiveUntil
    recurrences: [
      {
        recurrenceType: 'Monthly'
        daysOfWeek: actionruleMonthlyRecurrence
        startTime: actionruleStartTime
        endTime: actionruleEndTime
      }
    ]
    timeZone: scheduleTimeZone
  }
  Always: {
    recurrenceType: 'Always'
  }
}

var ruleType = {
  RemoveAllActionGroups: {
    enabled: actionRuleStatus
    actions: [
      {
        actionType: 'RemoveAllActionGroups'
      }
    ]
    scopes: ruleScope[actionruleScope]
    conditions: actionRuleConditions
    schedule: recurrenceType[actionruleRecurrenceType]
    description: actionruleDescription
  }
  AddActionGroups: {
    enabled: actionRuleStatus
    scopes: ruleScope[actionruleScope]
    conditions: actionRuleConditions
    actions: [
      {
        actionType: 'AddActionGroups'
        actionGroupIds: [
          actionGroupIds
        ]
      }
    ]
    schedule: recurrenceType[actionruleRecurrenceType]
    description: actionruleDescription
  }
}

resource actionRule 'Microsoft.AlertsManagement/actionRules@2021-08-08' = if (!empty(ruleScope[actionruleScope])) {
  name: actionruleName
  location: 'global'
  tags: tags
  properties: ruleType[actionRuleType]
}

output filteredActionruleScopeValuesOutput array = filteredActionRuleScopeValues
output actionRuleOutput object = ruleType[actionRuleType]
