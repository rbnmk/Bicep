// AADS Configuration
param location string = resourceGroup().location
param tags object = {}
param domainName string
param tlsV1 string = 'Disabled'
param ntlmV1 string = 'Enabled'
param syncNtlmPasswords string = 'Enabled'
param syncOnPremPasswords string = 'Enabled'
param kerberosRc4Encryption string = 'Enabled'
param kerberosArmoring string = 'Disabled'
param domainConfigurationType string = 'FullySynced'
param filteredSync string = 'Disabled'
param notificationsettings object = {
  notifyGlobalAdmins: 'Enabled'
  notifyDcAdmins: 'Enabled'
  additionalRecipients: []
}

// AADS SKU Options
// https://azure.microsoft.com/en-us/pricing/details/active-directory-ds/
@allowed([
  'Standard'
  'Enterprise'
  'Premium'
])
param sku string = 'Standard'

// ReplicaSets params
param vnetResourceGroupName string
param vnetName string
param subnetName string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2020-11-01' existing = {
  name: '${vnetName}/${subnetName}'
  scope: resourceGroup(vnetResourceGroupName)
}

resource aads 'Microsoft.AAD/domainServices@2021-03-01' = {
  name: domainName
  tags: tags
  location: location
  properties: {
    domainName: domainName
    filteredSync: filteredSync
    domainConfigurationType: domainConfigurationType
    notificationSettings: notificationsettings
    replicaSets: [
      {
        subnetId: subnet.id
        location: location
      }
    ]
    domainSecuritySettings: {
      ntlmV1: ntlmV1
      tlsV1: tlsV1
      syncNtlmPasswords: syncNtlmPasswords
      syncOnPremPasswords: syncOnPremPasswords
      kerberosRc4Encryption: kerberosRc4Encryption
      kerberosArmoring: kerberosArmoring
    }
    sku: sku
  }
}
