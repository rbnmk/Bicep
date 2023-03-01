targetScope = 'resourceGroup'

// required parameters
param name string
param location string = resourceGroup().location
param tags object = {}
// softDeleteRetentionInDays can only be set on creation, the value cannot be changed afterwards
param softDeleteRetentionInDays int = 90
// optional parameters
param enableRbacAuthorization bool = false
// access policies are ignored if RBAC authentication is enabled
param accessPolicies array = []
param enabledForDeployment bool = true
param enabledForDiskEncryption bool = true
param enabledForTemplateDeployment bool = true
param enablePurgeProtection bool = true
param skuName string = 'standard'
param tenantId string = subscription().tenantId
@allowed([
  'AzureServices'
  'None'
])
param networkBypass string = 'None'
@allowed([
  'Allow'
  'Deny'
])
param networkDefaultAction string = 'Deny'
param ipRules array = []
param virtualNetworkRules array = []
@secure()
param keyvaultSecrets object = {}
param privateDnsZoneProperties object = {}
param roleAssignments array = []
param publicNetworkAccess string = 'Disabled'
@metadata({
  strongType: 'Microsoft.OperationalInsights/workspaces'
})
param loganalyticsWorkspaceId string = ''

// if enabledForDeployment is true, networkBypass for AzureServices has to be enabled
var varNetworkBypass = (enabledForDeployment == true || enabledForTemplateDeployment == true) ? 'AzureServices' : networkBypass

resource existing_subnet 'Microsoft.Network/virtualNetworks/subnets@2022-01-01' existing = [for (subnet, i) in range(0, length(virtualNetworkRules)): if (!empty(virtualNetworkRules))  {
  name: '${virtualNetworkRules[i].virtualNetworkName}/${virtualNetworkRules[i].subnetName}'
  scope: resourceGroup(virtualNetworkRules[i].subscriptionId, virtualNetworkRules[i].resourceGroupName)
}]

resource existing_privateDNSZone 'Microsoft.Network/privateDnsZones@2020-06-01' existing = if (publicNetworkAccess == 'Disabled') {
  name: privateDnsZoneProperties.name
  scope: resourceGroup(privateDnsZoneProperties.subscriptionId, privateDnsZoneProperties.resourceGroupName)
}

resource keyvault 'Microsoft.KeyVault/vaults@2022-07-01' = {
  name: name
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: skuName
    }
    accessPolicies: accessPolicies
    enabledForDeployment: enabledForDeployment
    enabledForDiskEncryption: enabledForDiskEncryption
    enabledForTemplateDeployment: enabledForTemplateDeployment
    enableSoftDelete: true
    softDeleteRetentionInDays: softDeleteRetentionInDays
    enableRbacAuthorization: enableRbacAuthorization
    enablePurgeProtection: enablePurgeProtection ? true : null
    publicNetworkAccess: publicNetworkAccess
    networkAcls: {
      bypass: varNetworkBypass
      defaultAction: networkDefaultAction
      ipRules: ipRules
      virtualNetworkRules: [for (subnet, i) in range(0, length(virtualNetworkRules)): {
        id: existing_subnet[i].id
      }]
    }

  }
}

resource keyvaultPrivateEndpoint 'Microsoft.Network/privateEndpoints@2022-01-01' = if (publicNetworkAccess == 'Disabled') {
  name: 'pve-${name}'
  location: location
  tags: tags
  properties: {
    subnet: {
      id: publicNetworkAccess == 'Disabled' ? existing_subnet[0].id : ''
    }
    privateLinkServiceConnections: [
      {
        name: 'pve-con-${name}'
        properties: {
          privateLinkServiceId: keyvault.id
          groupIds: [
            'vault'
          ]
        }

      }
    ]
  }
  resource privateDNSZoneGroup 'privateDnsZoneGroups' = {
    name: 'dns-pve-con-${name}'
    properties: {
      privateDnsZoneConfigs: [
        {
          name: 'config1'
          properties: {
            privateDnsZoneId: publicNetworkAccess == 'Disabled' ? existing_privateDNSZone.id : ''
          }
        }
      ]
    }
  }
}

resource keyVaultSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = [for secret in items(keyvaultSecrets): {
  parent: keyvault
  tags: tags
  name: secret.key
  properties: {
    value: secret.value
  }
}]

resource keyvaultRoleAssignments 'Microsoft.Authorization/roleAssignments@2022-04-01' = [for (roleassignment, i) in roleAssignments: if (!empty(roleAssignments)) {
  scope: keyvault
  name: guid(keyvault.id, roleassignment.principalId, roleassignment.roleDefinitionId)
  properties: {
    principalId: roleassignment.principalId
    principalType: roleassignment.principalType
    roleDefinitionId: subscriptionResourceId('Microsoft.Authorization/roleDefitions', roleassignment.roleDefinitionId)
  }
}]

resource diagnostics 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = if (!empty(loganalyticsWorkspaceId)) {
  name: 'diagnostics'
  scope: keyvault
  properties: {
    workspaceId: loganalyticsWorkspaceId
    logs: [
      {
        category: 'auditEvent'
        enabled: true
      }
      {
        categoryGroup: 'allLogs'
        enabled: true
      }
    ]
  }
}

output keyvault object = keyvault
output keyvaultName string = keyvault.name
