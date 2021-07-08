targetScope = 'subscription'

//naming convention common parameters
param company string = 'hob'
param solution string = 'psf'
param shortregion string = 'we'
param environment string = 'h'
param sequence string = '01'

//tag related parameters
param costcenter string = 'HOB90001'
param ownerEmail string = 'email@hob.hob'
param department string = 'Hob IT'

// Define the resource group here because we need to be able to calculate the scope before deployment.
var resourceGroupName = 'rg-${shortregion}-${company}-${solution}-${environment}-mgt-${sequence}'

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

module law '../_modules/mod-loganalytics.bicep' = {
  name: 'loganalytics'
  scope: resourceGroup(resourceGroupName)
  params: {
    tags: tags.outputs.tags
    loganalyticsWorkspaceName: nc.outputs.LogAnalyticsWorkspaceName
  }
}

module asp '../_modules/mod-appserviceplan.bicep' = {
  name: 'appserviceplan'
  scope: resourceGroup(resourceGroupName)
  params: {
    tags: tags.outputs.tags
    hostingPlanName: nc.outputs.AppServicePlanName
  }
}

module sta '../_modules/mod-storageaccount.bicep' = {
  name: 'jobsaccount'
  scope: resourceGroup(resourceGroupName)
  params: {
    tags: tags.outputs.tags
    storageaccountName: nc.outputs.StorageAccount
  }
}

module appinsights '../_modules/mod-applicationinsights.bicep' = {
  name: 'appinsights'
  scope: resourceGroup(resourceGroupName)
  params:{
    AppInsightsName: nc.outputs.AppInsightsName
    AppName: nc.outputs.FunctionAppName
  }
}

module functionapp '../_modules/mod-powershell-functionapp.bicep' = {
  name: 'powershell-function'
  scope: resourceGroup(resourceGroupName)
  params: {
    applicationInsightsName: appinsights.outputs.applicationInsightsName
    appServicePlanName: asp.outputs.hostingPlanName
    logAnalyticsWorkspaceName: law.outputs.loganalyticsWorkspaceName
    webJobsStorageAccountName: sta.outputs.storageAccountName
    functionAppName: nc.outputs.FunctionAppName
  }
}
