//Define Azure Files parmeters
param storageaccountlocation string = 'westeurope'
param storageaccountName string
param storageaccountkind string
param storgeaccountglobalRedundancy string = 'Standard_LRS'
param containerName string
param tags object = {}


//Concat FileShare
var container = '${sa.name}/default/${containerName}'

//Create Storage account
resource sa 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {
  name : storageaccountName
  location : storageaccountlocation
  kind : storageaccountkind
  tags : tags
  sku: {
    name: storgeaccountglobalRedundancy
  }
}

resource ct 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-02-01' = {
  name: container
}
