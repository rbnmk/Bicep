targetScope = 'subscription'

//naming convention common parameters
param company string = 'hob'
param solution string = 'mon'
param shortregion string = 'we'
param environment string = 'd'
param sequence string = '01'

//tag related parameters
param costcenter string = 'HOB90001'
param ownerEmail string = 'email@domain.com'
param department string = 'Hob IT'

// common modules for naming and resource groups
module nc '../_modules/mod-naming-convention.bicep' = {
  name: 'NamingConvention'
  params: {
    company: company
    solution: solution
    shortregion: shortregion
    environment: environment
    sequence: sequence
  }
}

module tags '../_modules/mod-tags.bicep' = {
  name: 'Tags'
  params:{
    company: company
    solution: solution
    environment: environment
    costcenter: costcenter
    ownerEmail: ownerEmail
    department: department
  }
}

var resourceGroups = [
  nc.outputs.ResourceGroupManagement
  nc.outputs.virtualNetworkName
  nc.outputs.ResourceGroupSolution
]
var resourceGroupTags = tags.outputs.tags
var resourceGroupsLocation = 'WestEurope'

module rgs '../_modules/mod-resourcegroups.bicep' = {
  name: 'resourcegroup-deployment'
  params: {
    resourceGroups: resourceGroups
    resourceGroupTags: resourceGroupTags
    resourceGroupsLocation: resourceGroupsLocation
  }
}
