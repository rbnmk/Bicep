targetScope = 'resourceGroup'

@description('Name for the automation account')
param automationAccountName string
param tags object = {}

resource automationAccount 'Microsoft.Automation/automationAccounts@2020-01-13-preview' = {
  name: automationAccountName
  location: resourceGroup().location
  tags: tags
  properties: {
    sku: {
      name: 'Free'
    }
  }
}

resource runbook_Update_AutomationAzureModulesForAccount 'Microsoft.Automation/automationAccounts/runbooks@2019-06-01' = {
  name: '${automationAccount.name}/Update-AutomationAzureModulesForAccount'
  location: resourceGroup().location
  tags: tags
  properties: {
    description: 'https://github.com/Microsoft/AzureAutomation-Account-Modules-Update'
    runbookType: 'PowerShell'
    logProgress: false
    logVerbose: true
    publishContentLink: {
      uri: 'https://raw.githubusercontent.com/microsoft/AzureAutomation-Account-Modules-Update/master/Update-AutomationAzureModulesForAccount.ps1'
      version: '1.0.0.0'
    }
  }
}

output automationAccount string = automationAccount.name
output automationAccountId string = automationAccount.id
