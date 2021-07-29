@description('Object parameter containing all information for the VNET')
param vnet object

param location string = resourceGroup().location

var privateEndpointNetworkPolicyDefault = 'Enabled'
var privateLinkServiceNetworkPolicyDefault = 'Enabled'
var nsgId = [for i in range(0, length(vnet.vnet.subnets)): {
  id: resourceId('Microsoft.Network/networkSecurityGroups', vnet.vnet.subnets[i].nsgName)
}]
var rtId = [for i in range(0, length(vnet.vnet.subnets)): {
  id: resourceId('Microsoft.Network/routeTables', vnet.vnet.subnets[i].routeTableName)
}]

resource vnet_vnet_name 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnet.vnet.name
  location: location
  tags: {}
  properties: {
    addressSpace: {
      addressPrefixes: vnet.vnet.addressPrefixes
    }
    subnets: [for j in range(0, length(vnet.vnet.subnets)): {
      name: vnet.vnet.subnets[j].name
      properties: {
        addressPrefix: vnet.vnet.subnets[j].addressPrefix
        networkSecurityGroup: (empty(vnet.vnet.subnets[j].nsgName) ? json('null') : nsgId[j])
        routeTable: (empty(vnet.vnet.subnets[j].routeTableName) ? json('null') : rtId[j])
        delegations: (empty(vnet.vnet.subnets[j].delegations) ? json('null') : vnet.vnet.subnets[j].delegations)
        serviceEndpoints: (empty(vnet.vnet.subnets[j].serviceEndpoints) ? json('null') : vnet.vnet.subnets[j].serviceEndpoints)
        privateEndpointNetworkPolicies: (empty(vnet.vnet.subnets[j].privateEndpointNetworkPolicies) ? privateEndpointNetworkPolicyDefault : vnet.vnet.subnets[j].privateEndpointNetworkPolicies)
        privateLinkServiceNetworkPolicies: (empty(vnet.vnet.subnets[j].privateLinkServiceNetworkPolicies) ? privateLinkServiceNetworkPolicyDefault : vnet.vnet.subnets[j].privateLinkServiceNetworkPolicies)
      }
    }]
  }
}

output virtualNetworkName object = vnet
