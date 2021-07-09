//naming convention common parameters
param company string = 'hob'
param solution string = 'upd'
param shortregion string = 'we'
param environment string = 'h'
param sequence string = '01'

//tag related parameters
param costcenter string = 'HOB90001'
param ownerEmail string = 'email@hob.hob'
param department string = 'Hob IT'


// Define the resource group here because we need to be able to calculate the scope before deployment.
var resourceGroupName = 'rg-${shortregion}-${company}-${solution}-${environment}-${sequence}'

module nc '../_modules/mod-naming-convention.bicep' = {
  name: 'NamingConvention'
  scope: subscription()
  params: {
    company: company
    solution: solution
    shortregion: shortregion
    environment: environment
    sequence: sequence
  }
}

module tags '../_modules/mod-tags.bicep' = {
  name: 'Tags'
  scope: subscription()
  params: {
    company: company
    solution: solution
    environment: environment
    costcenter: costcenter
    ownerEmail: ownerEmail
    department: department
  }
}

module aut '../_modules/mod-automationaccount.bicep' = {
  name: 'automationaccount'
  scope: resourceGroup(resourceGroupName)
  params:{
    tags: tags.outputs.tags
    automationAccountName: nc.outputs.AutomationAccountName

  }
}

module law '../_modules/mod-loganalytics.bicep' = {
  name: 'loganalytics'
  scope: resourceGroup(resourceGroupName)
  params: {
    tags: tags.outputs.tags
    loganalyticsWorkspaceName: nc.outputs.LogAnalyticsWorkspaceName
    automationAccountName: aut.outputs.automationAccount
    linkAutomationAccount: true
  }
}
