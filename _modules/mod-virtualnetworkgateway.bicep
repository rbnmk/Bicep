param resourcetags object = {}
param gatewayName string
param gatewaySku string = 'VpnGw1'
param gatewayType string = 'Vpn'
param gatewayVpnType string = 'RouteBased'
param gatewayVpnClientProtocols array = [
  'IkeV2'
  'SSTP'
]
param virtualNetworkName string
param virtualNetworkResourceGroupName string

@secure()
param p2sCertData string

var pipname = 'pip-we-${gatewayName}'

resource vngsubnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${virtualNetworkName}/GatewaySubnet'
  scope: resourceGroup(virtualNetworkResourceGroupName)
}

resource vngpip 'Microsoft.Network/publicIPAddresses@2021-02-01' = {
  name: pipname
  location: resourceGroup().location
  tags: resourcetags
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
}

resource vng 'Microsoft.Network/virtualNetworkGateways@2021-02-01' = {
  name: gatewayName
  location: resourceGroup().location
  tags: resourcetags
  properties: {
    ipConfigurations: [
      {
        name: 'ipcfgvng'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vngsubnet.id
          }
          publicIPAddress: {
            id: vngpip.id
          }
        }
      }
    ]
    gatewayType: gatewayType
    vpnType: gatewayVpnType
    vpnGatewayGeneration: 'Generation1'
    enableBgp: false
    enablePrivateIpAddress: true
    activeActive: false
    sku: {
      name: gatewaySku
      tier: gatewaySku
    }
    vpnClientConfiguration: {
      vpnClientAddressPool: {
        addressPrefixes: vngsubnet.properties.addressPrefixes
      }
      vpnClientProtocols: gatewayVpnClientProtocols
      vpnClientRootCertificates: [
        {
          name: 'P2S'
          properties: {
            publicCertData: p2sCertData
          }
        }
      ]
    }
  }
}
