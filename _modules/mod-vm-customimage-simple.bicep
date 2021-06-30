// vm specific params
@maxLength(15)
param vmNamePrefix string
param vmSku string = 'D4s_v3'
param numberofVMs int
param imageId string
param vmAdministratorLogin string
@secure()
param vmAdministratorPassword string
param subnetName string
param virtualNetworkName string
param virtualNetworkResourceGroupName string
param availabilitySet bool = true


resource subnet 'Microsoft.Network/virtualNetworks/subnets@2021-02-01' existing = {
  name: '${virtualNetworkName}/${subnetName}'
  scope: resourceGroup(virtualNetworkResourceGroupName)
}

resource avset 'Microsoft.Compute/availabilitySets@2021-03-01' = if (availabilitySet) {
  name: 'as-${vmNamePrefix}'
  location: resourceGroup().location
  properties: {
    platformUpdateDomainCount: 5
    platformFaultDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}

resource vmnic 'Microsoft.Network/networkInterfaces@2021-02-01' = [for i in range(1, numberofVMs): {
  name: 'nic-we-${vmNamePrefix}-${i}'
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnet.id
          }
        }
      }
    ]
  }
}]

resource virtualmachine 'Microsoft.Compute/virtualMachines@2021-03-01' = [for i in range(1, numberofVMs): {
  name: '${vmNamePrefix}-${i}'
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  
  properties: {
    licenseType: 'Windows_Client'
    hardwareProfile: {
      vmSize: vmSku
    }
    availabilitySet: {
      id: availabilitySet ? avset.id : null
    }
    osProfile: {
      computerName: '${vmNamePrefix}-${i}'
      adminUsername: vmAdministratorLogin
      adminPassword: vmAdministratorPassword
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: resourceId('Microsoft.Network/networkInterfaces', 'nic-we-${vmNamePrefix}-${i}')
          properties: {
            primary: true
          }
        }
      ]
    }
    storageProfile: {
      imageReference: {
        id: imageId
      }
      osDisk: {
        createOption: 'FromImage'
      }
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
      }
    }
  }
}]
