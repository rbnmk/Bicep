targetScope = 'subscription'

//naming convention common parameters
param company string = 'hob'
param solution string = 'psf'
param shortregion string = 'we'
param environment string = 'h'
param sequence string = '01'

//tag related parameters
param costcenter string = 'HOB90001'
param ownerEmail string = 'email@hob.hob'
param department string = 'Hob IT'

// Define the resource group here because we need to be able to calculate the scope before deployment.
var resourceGroupName = 'rg-${shortregion}-${company}-${solution}-${environment}-${sequence}'


module nc '../_modules/mod-naming-convention.bicep' = {
  name: 'NamingConvention'
  scope: subscription()
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
  scope: subscription()
  params: {
    company: company
    solution: solution
    environment: environment
    costcenter: costcenter
    ownerEmail: ownerEmail
    department: department
  }
}

module mid '../_modules/mod-managedidentity.bicep' = {
  name: 'managedidentity-deployment'
  scope: resourceGroup(resourceGroupName)
  params: {
    managedidentityName: nc.outputs.ManagedIdentity
    tags: tags.outputs.tags
  }
}

module mid_ra '../_modules/mod-rg-contributor-roleassignment.bicep' = {
  name: 'managedidentity-role-assignment'
  scope: resourceGroup(resourceGroupName)
  params: {
    principalId: mid.outputs.midPrincipalId
  }
}

module sig '../_modules/mod-sharedimagegallery.bicep' = {
  name: 'sig-deployment'
  scope: resourceGroup(resourceGroupName)
  params:{
    galleryName: nc.outputs.SharedImageGalleryName
    tags: tags.outputs.tags
  }
}

module template '../_modules/mod-aib-server-2019.bicep' = {
  name: 'build-template-deployment'
  scope: resourceGroup(resourceGroupName)
  params:{
    imageGalleryName: sig.outputs.galleryName
    resourceTags: tags.outputs.tags
    userAssignedIdentityId: mid.outputs.midId
    imageTemplateName: 'devopsagentserver2019'
  }
}


