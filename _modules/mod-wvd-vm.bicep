// vm specific params
@maxLength(15)
param vmNamePrefix string = 'sh'
param vmSku string = 'D4s_v3'
param numberofVMs int = 1
param vmAdministratorLogin string
param forceUpdate string = utcNow()
param imageId string
@secure()
param vmAdministratorPassword string
param domainToJoin string
param domainOuPath string
param domainJoinUPN string
@secure()
param domainJoinPassword string
param subnetName string
param virtualNetworkName string
param virtualNetworkResourceGroupName string
param wvdRegistrationKey string
param availabilitySet bool = true

var domainJoinOptions = '3'

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

resource virtualMachineExtension 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(1, numberofVMs): {
  name: '${vmNamePrefix}-${i}/joindomain'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      name: domainToJoin
      ouPath: domainOuPath
      user: domainJoinUPN
      restart: true
      NumberOfRetries: 4
      RetryIntervalInMilliseconds: 30000
      options: domainJoinOptions
    }
    protectedSettings: {
      password: domainJoinPassword
    }
  }
  dependsOn: [
    virtualmachine
  ]
}]

resource virtualMachineExtension2 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(1, numberofVMs): {
  name: '${vmNamePrefix}-${i}/AddWvDSessionHost'
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    forceUpdateTag: forceUpdate
    protectedSettings: {
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File Add-WvdSessionHost.ps1 ${wvdRegistrationKey}'
      fileUris: [
        'https://raw.githubusercontent.com/rbnmk/PowerShell/master/Add-WvdSessionHost.ps1'
      ]
    }
  }
  dependsOn: [
    virtualMachineExtension
  ]
}]
