param location string = resourceGroup().location
param sqlServerName string = 'rm-sql-d-001'
param sqlDatabaseName string = 'datahub'
param globalRedundancy bool = true // defaults to true but can be overridden

resource sqls 'Microsoft.Sql/servers@2019-06-01-preview' = {
    name: sqlServerName // must be globally unique
    location: location
    tags: {}
    identity: {
      type: 'SystemAssigned'
    }
    properties: {
      administratorLogin: 'databaseAdmin'
      administratorLoginPassword: 'VerySecurePassword123!'
      minimalTlsVersion: '1.2'
      publicNetworkAccess: 'Enabled'
    }
}

output storageId string = sqls.id // output resourceId of storage account