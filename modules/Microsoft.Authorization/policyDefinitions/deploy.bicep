// Allowed Virtual Machine SKUs
// https://docs.microsoft.com/en-us/azure/templates/microsoft.authorization/policydefinitions?tabs=bicep
//
targetScope = 'managementGroup'

param policyName string
param policyProperties  object

// Create Custom Policy
resource policyDefintion 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
  name: policyName
  properties: policyProperties
}

output policyName string = policyDefintion.name
output policyDefinitionId string = policyDefintion.id
