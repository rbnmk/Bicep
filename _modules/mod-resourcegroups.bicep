targetScope = 'subscription'

param resourceGroups array = []
param resourceGroupTags object = {}
param resourceGroupsLocation string = 'WestEurope'

resource rgs 'Microsoft.Resources/resourceGroups@2021-04-01' = [for rg in resourceGroups: {
  name: rg
  location: resourceGroupsLocation
  tags: resourceGroupTags
}]

output resourceGroups array = [for rg in resourceGroups: {
  name: reference(rg.name)
}]
