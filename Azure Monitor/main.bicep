// Customer related params
param customer string = 'HOB'
param MonitoringResourceGroupName string

// Monitor Related params
param actionGroupName string
param actionGroupShortName string
param emailReceivers array = []
param webhookReceivers array = []
param logAnalyticsWorkspaceName string = ''

// Alert related params
@description('This parameter will be used to provide an array of Resource Group resource ids for the alerts that can be scoped to resource group')
param resourceGroupScopes array = []
@description('This parameter will be used to provide an object with arrays of resource ids for the alerts that can only be scoped to resource')
param resourceScopes object = {}
param vm_scheduledQueryRules array = []
param rsv_scheduledQueryRules array = []
param vm_metricAlerts array = []
param asp_metricAlerts array = []
param search_metricAlerts array = []
param sites_metricAlerts array = []
param sqlep_metricAlerts array = []
param sqldb_metricAlerts array = []
param agw_metricAlerts array = []
param redis_metricAlerts array = []
param kv_metricAlerts array = []
param aut_metricAlerts array = []
param sb_metricAlerts array = []
param adf_metricAlerts array = []
param egtopic_metricAlerts array = []

var alertNamePrefix = '${toUpper(customer)}'

module ag '../_modules/mod-actiongroup.bicep' = {
  name: 'default-actiongroup-deployment'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: actionGroupName
    actionGroupShortName: actionGroupShortName
    emailReceivers: emailReceivers
    webhookReceivers: webhookReceivers
  }
}

module law '../_modules/mod-loganalytics.bicep' = if (!empty(logAnalyticsWorkspaceName)) {
  name: 'log-analytics-enable-monitoring'
  params: {
    loganalyticsWorkspaceName: logAnalyticsWorkspaceName
    enableVMInsights: true
  }
}

module activitylogalerts '../_modules/mod-activitylogalerts.bicep' = {
  name: 'activitylogalerts-deployment'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
  }
}

// Scheduled Query Alerts & Rules
module vm_scheduled_query_rules '../_modules/mod-scheduledqueryrules.bicep' = if (!empty(resourceScopes.virtualMachines) && !empty(logAnalyticsWorkspaceName)) {
  name: 'vm-scheduled-query-alerts'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    logAnalyticsWorkspaceName: law.outputs.loganalyticsWorkspaceName
    scheduledQueryRules: vm_scheduledQueryRules
  }
}

module rsv_scheduled_query_rules '../_modules/mod-scheduledqueryrules.bicep' = if (!empty(resourceScopes.RecoveryServices_vaults) && !empty(logAnalyticsWorkspaceName)) {
  name: 'rsv-scheduled-query-alerts'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    logAnalyticsWorkspaceName: law.outputs.loganalyticsWorkspaceName
    scheduledQueryRules: rsv_scheduledQueryRules
  }
}

// ResourceGroupScoped Alerts
module vm_metric_alerts '../_modules/mod-rg-metricalerts.bicep' = if (!empty(resourceScopes.virtualMachines)) {
  name: 'vm-metric-alerts'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    scopes: resourceGroupScopes
    metricAlerts: vm_metricAlerts
  }
}

module sqldb_metric_alerts '../_modules/mod-rg-metricalerts.bicep' = if (!empty(resourceScopes.databases)) {
  name: 'sqldb-metric-alerts'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    scopes: resourceGroupScopes
    metricAlerts: sqldb_metricAlerts
  }
}

module sqlep_metric_alerts '../_modules/mod-rg-metricalerts.bicep' = if (!empty(resourceScopes.elasticPools)) {
  name: 'sqlep-metric-alerts'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    scopes: resourceGroupScopes
    metricAlerts: sqlep_metricAlerts
  }
}

module redis_metric_alerts '../_modules/mod-rg-metricalerts.bicep' = if (!empty(resourceScopes.redis)) {
  name: 'redis-metric-alerts'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    scopes: resourceGroupScopes
    metricAlerts: redis_metricAlerts
  }
}

module kv_metric_alerts '../_modules/mod-rg-metricalerts.bicep' = if (!empty(resourceScopes.KeyVault_vaults)) {
  name: 'kv-metric-alerts'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    scopes: resourceGroupScopes
    metricAlerts: kv_metricAlerts
  }
}

// Resource Scoped Alerts
module asp_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (asp, i) in resourceScopes.serverFarms: {
  name: 'asp-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: asp
    metricAlerts: asp_metricAlerts
  }
}]

module search_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (search, i) in resourceScopes.searchServices: {
  name: 'search-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: search
    metricAlerts: search_metricAlerts
  }
}]

module webapp_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (sites, i) in resourceScopes.sites: {
  name: 'sites-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: sites
    metricAlerts: sites_metricAlerts
  }
}]

module agw_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (applicationgateways, i) in resourceScopes.applicationgateways: {
  name: 'agw-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: applicationgateways
    metricAlerts: agw_metricAlerts
  }
}]

module aut_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (automationaccounts, i) in resourceScopes.automationaccounts: {
  name: 'aut-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: automationaccounts
    metricAlerts: aut_metricAlerts
  }
}]

module sb_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (namespaces, i) in resourceScopes.namespaces: {
  name: 'sb-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: namespaces
    metricAlerts: sb_metricAlerts
  }
}]

module adf_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (factories, i) in resourceScopes.factories: {
  name: 'adf-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: factories
    metricAlerts: adf_metricAlerts
  }
}]

module eventgrid_systemtopics_metric_alerts '../_modules/mod-resource-metricalerts.bicep' = [for (systemtopics, i) in resourceScopes.systemtopics: {
  name: 'systemtopics-metric-alerts-${i + 1}'
  scope: resourceGroup(MonitoringResourceGroupName)
  params: {
    actionGroupName: ag.outputs.actionGroupName
    alertNamePrefix: alertNamePrefix
    resource: systemtopics
    metricAlerts: egtopic_metricAlerts
  }
}]
