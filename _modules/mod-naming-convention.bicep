targetScope = 'subscription'

param company string
param solution string
param shortregion string
param environment string
param sequence string = '01'

// Example var
// var nc                        = 'vnt-${shortregion}-${company}-${solution}-${environment}-${sequence}'

// Resource Groups
var ncResourceGroupNetwork = 'rg-${shortregion}-${company}-${solution}-${environment}-ntw-${sequence}'
var ncResourceGroupManagement = 'rg-${shortregion}-${company}-${solution}-${environment}-mgt-${sequence}'
var ncResourceGroupSolution = 'rg-${shortregion}-${company}-${solution}-${environment}-sol-${sequence}'

//Common Resources
var ncVirtualNetworkName = 'vnt-${shortregion}-${company}-${solution}-${environment}-${sequence}'
var ncLogAnalyticsWorkspaceName = 'law-${shortregion}-${company}-${solution}-${environment}-${sequence}'
var ncAutomationAccountName = 'aut-${shortregion}-${company}-${solution}-${environment}-${sequence}'
var ncManagedIdentity = 'mid-${shortregion}-${company}-${solution}-${environment}-${sequence}'
var ncStorageAccount = replace('sta-${shortregion}-${company}-${solution}-${environment}-${sequence}', '-', '')
var ncKeyVault = replace('kev-${shortregion}-${company}-${solution}-${environment}-${sequence}', '-', '')

// Shared Image Gallery Resources
var ncSharedImageGalleryName = replace('sig-${shortregion}-${company}-${solution}-${environment}-${sequence}','-','')
var ncSharedImageTemplateName = 'img-${shortregion}-${company}-${solution}-${environment}-${sequence}'

// WvD Components
var ncWvdHostpoolName = 'sig-${shortregion}-${company}-${solution}-${environment}-${sequence}'
var ncWvdAppgroupName = 'apg-${shortregion}-${company}-${solution}-${environment}-${sequence}'
var ncWvdworkspaceName = 'wpc-${shortregion}-${company}-${solution}-${environment}-${sequence}'

output ResourceGroupNetwork string = ncResourceGroupNetwork
output ResourceGroupManagement string = ncResourceGroupManagement
output ResourceGroupSolution string = ncResourceGroupSolution
output virtualNetworkName string = ncVirtualNetworkName
output LogAnalyticsWorkspaceName string = ncLogAnalyticsWorkspaceName
output ManagedIdentity string = ncManagedIdentity
output StorageAccount string = ncStorageAccount
output KeyVault string = ncKeyVault
output AutomationAccountName string = ncAutomationAccountName
output SharedImageGalleryName string = ncSharedImageGalleryName
output SharedImageTemplateName string = ncSharedImageTemplateName
output WvdHostpoolName string = ncWvdHostpoolName
output WvdAppgroupName string = ncWvdAppgroupName
output WvdworkspaceName string = ncWvdworkspaceName
