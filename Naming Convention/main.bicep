targetScope = 'subscription'

param company string = 'hob'
param solution string = 'mon'
param shortregion string = 'we'
param environment string = 'd'
param sequence string = '01'

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

output virtualNetworkName string = nc.outputs.virtualNetworkName
