targetScope = 'resourceGroup'

param functionAppName string
param appServicePlanName string
param appServicePlanResourceGroupName string = resourceGroup().name
param applicationInsightsName string
param applicationInsightsResourceGroupName string = resourceGroup().name
param webJobsStorageAccountName string
param webJobsStorageAccountResourceGroupName string = resourceGroup().name
param logAnalyticsWorkspaceName string
param logAnalyticsWorkspaceResourceGroupName string = resourceGroup().name
@allowed([
  'readonly'
  'readwrite'
])
@description('')
param editMode string = 'readonly'
param alwaysOn bool = true
param tags object = {}
param deployStagingslot bool = false

var functionAppSlotName = 'staging'
var stagingslot_tag = { 
  functionslot : 'stagingslot'
}


resource webjobstorageaccount 'Microsoft.Storage/storageAccounts@2021-04-01' existing = {
  name: webJobsStorageAccountName
  scope: resourceGroup(webJobsStorageAccountResourceGroupName)
}

resource diagnosticsWorkspace 'Microsoft.OperationalInsights/workspaces@2020-10-01' existing = {
  name: logAnalyticsWorkspaceName
  scope: resourceGroup(logAnalyticsWorkspaceResourceGroupName)
}

resource applicationInsights 'Microsoft.Insights/components@2020-02-02-preview' existing = {
  name: applicationInsightsName
  scope: resourceGroup(applicationInsightsResourceGroupName)
}

resource appserviceplan 'Microsoft.Web/serverfarms@2021-01-01' existing = {
  name: appServicePlanName
  scope: resourceGroup(appServicePlanResourceGroupName)
}


resource function 'Microsoft.Web/sites@2021-01-01' = {
  name: functionAppName
  location: resourceGroup().location
  tags: tags
  kind: 'functionapp'
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    siteConfig: {
      phpVersion: 'off'
      use32BitWorkerProcess: false
      powerShellVersion: '~7'
      alwaysOn: alwaysOn
      remoteDebuggingEnabled: false
      remoteDebuggingVersion: ''
      ftpsState: 'Disabled'
      appSettings: [
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~3'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: 'powershell'
        }
      ]
    }
    serverFarmId: appserviceplan.id
    clientAffinityEnabled: true
    httpsOnly: true
  }
}

resource functionAppName_slotConfigNames 'Microsoft.Web/sites/config@2018-11-01' = {
  name: '${function.name}/slotConfigNames'
  properties: {
    appSettingNames: [
      'DisableAllFunctions'
    ]
  }
}

resource functionAppName_appsettings 'Microsoft.Web/sites/config@2018-11-01' = {
  name: '${function.name}/appsettings'
  properties: {
    DisableAllFunctions: 'false'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${webjobstorageaccount.name};AccountKey=${listKeys(webjobstorageaccount.id, '2021-04-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    FUNCTIONS_EXTENSION_VERSION: '~3'
    FUNCTIONS_WORKER_RUNTIME: 'powershell'
    FUNCTION_APP_EDIT_MODE: editMode
    APPINSIGHTS_INSTRUMENTATIONKEY: reference(applicationInsights.id, '2020-02-02-preview').InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: reference(applicationInsights.id, '2020-02-02-preview').ConnectionString
    WEBSITE_TIME_ZONE: 'W. Europe Standard Time'
    WEBSITE_ENABLE_SYNC_UPDATE_SITE: '1'
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG: '1'
    FUNCTIONS_WORKER_PROCESS_COUNT: '4'
    PSWorkerInProcConcurrencyUpperBound: '1'
  }
}

resource functionAppName_Microsoft_Insights_LogAnalytics 'Microsoft.Web/sites/providers/diagnosticSettings@2017-05-01-preview' = {
  name: '${function.name}/Microsoft.Insights/LogAnalytics'
  tags: {
    displayName: 'Diagnostic Setting'
  }
  properties: {
    name: 'LogAnalytics'
    logs: [
      {
        category: 'FunctionAppLogs'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 31
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
        enabled: true
        retentionPolicy: {
          enabled: true
          days: 31
        }
      }
    ]
    workspaceId: diagnosticsWorkspace.id
  }
}

resource function_staging_slot 'Microsoft.Web/sites/slots@2021-01-01' = if (deployStagingslot) {
  name: '${function.name}/${functionAppSlotName}'
  location: resourceGroup().location
  tags: stagingslot_tag
  kind: 'functionapp'
  properties: {
    enabled: true
    serverFarmId: appserviceplan.id
  }
}

resource functionAppName_functionAppSlotName_appsettings 'Microsoft.Web/sites/slots/config@2021-01-01' = if (deployStagingslot) {
  name: '${function_staging_slot.name}/appsettings'
  properties: {
    DisableAllFunctions: 'false'
    AzureWebJobsStorage: 'DefaultEndpointsProtocol=https;AccountName=${webjobstorageaccount.name};AccountKey=${listKeys(webjobstorageaccount.id, '2021-04-01').keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
    FUNCTIONS_EXTENSION_VERSION: '~3'
    FUNCTIONS_WORKER_RUNTIME: 'powershell'
    FUNCTION_APP_EDIT_MODE: editMode
    APPINSIGHTS_INSTRUMENTATIONKEY: reference(applicationInsights.id, '2020-02-02-preview').InstrumentationKey
    APPLICATIONINSIGHTS_CONNECTION_STRING: reference(applicationInsights.id, '2020-02-02-preview').ConnectionString
    WEBSITE_TIME_ZONE: 'W. Europe Standard Time'
    WEBSITE_ENABLE_SYNC_UPDATE_SITE: '1'
    WEBSITE_ADD_SITENAME_BINDINGS_IN_APPHOST_CONFIG: '1'
    FUNCTIONS_WORKER_PROCESS_COUNT: '4'
    PSWorkerInProcConcurrencyUpperBound: '1'
  }
}
