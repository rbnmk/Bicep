targetScope = 'subscription'

@description('Azure Region where Resource Group will be created.  No Default')
param location string

@description('Name of Resource Group to be created.  No Default')
param resourceGroupName string

@description('Tags you would like to be applied to all resources in this module')
param tags object = {}

param roleAssignments array = []

resource resourceGroup 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  location: location
  name: resourceGroupName
  tags: tags
}

module resourceGroupRoleAssignment '../../Microsoft.Authorization/roleAssignments/roleAssignmentResourceGroup.bicep' = [for (roleassignment, i) in roleAssignments: {
  scope: resourceGroup
  name: take('rg-role-${i + 1}-${resourceGroup.name}-${roleassignment.principalId}', 64)
  params: {
    parAssigneeObjectId: roleassignment.principalId
    parAssigneePrincipalType: contains(roleassignment, 'principalType') ? roleassignment.PrincipalType : 'Group'
    parRoleDefinitionId: roleassignment.roleDefinitionId
  }
}]

output outResourceGroupName string = resourceGroup.name
output outResourceGroupId string = resourceGroup.id
