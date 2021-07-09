targetScope = 'resourceGroup'

param location string = 'westeurope'
param loganalyticsWorkspaceName string
param loganalyticsRetentionInDays int = 31
param linkAutomationAccount bool = false
param automationAccountName string = ''
param enableVMInsights bool = false
param enableUpdateManagement bool = false
param enableAntiMalware bool = false
param enableSQLAssessment bool = false
param tags object = {}

//Create Workspace
resource law 'Microsoft.OperationalInsights/workspaces@2020-10-01' = {
  name: loganalyticsWorkspaceName
  location: location
  properties: {
    retentionInDays: loganalyticsRetentionInDays
  }
  tags: tags
}

// Link Automation Account (i.e. for Update Management)
resource automationaccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' existing = if (linkAutomationAccount) {
  name: automationAccountName
}

resource linkedservice_AutomationAccount 'Microsoft.OperationalInsights/workspaces/linkedServices@2020-08-01' = if (linkAutomationAccount) {
  name: '${law.name}/Automation'
  tags: tags
  properties: {
    resourceId: automationaccount.id
  }
}

// Enable solutions
resource solution_vminsights 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableVMInsights) {
  name: 'VMInsights(${law.name})'
  tags: tags
  location: location
  properties: {
    workspaceResourceId: law.id
  }
  plan: {
    name: 'VMInsights(${law.name})'
    product: 'OMSGallery/VMInsights'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource solution_updates 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableUpdateManagement && linkAutomationAccount) {
  name: 'Updates(${law.name})'
  tags: tags
  location: location
  properties: {
    workspaceResourceId: law.id
  }
  plan: {
    name: 'Updates(${law.name})'
    product: 'OMSGallery/Updates'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource solution_antimalware 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableAntiMalware) {
  name: 'AntiMalware(${law.name})'
  tags: tags
  location: location
  properties: {
    workspaceResourceId: law.id
  }
  plan: {
    name: 'AntiMalware(${law.name})'
    product: 'OMSGallery/AntiMalware'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

resource solution_sql_assessment 'Microsoft.OperationsManagement/solutions@2015-11-01-preview' = if (enableSQLAssessment) {
  name: 'SQLAssessment(${law.name})'
  tags: tags
  location: location
  properties: {
    workspaceResourceId: law.id
  }
  plan: {
    name: 'SQLAssessment(${law.name})'
    product: 'OMSGallery/SQLAssessment'
    promotionCode: ''
    publisher: 'Microsoft'
  }
}

output loganalyticsWorkspaceName string = law.name
output loganalyticsWorkspaceId string = law.id
