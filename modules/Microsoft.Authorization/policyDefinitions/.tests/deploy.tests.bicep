targetScope = 'managementGroup'

module Require_tag_on_resource_group '../deploy.bicep' = {
  scope: managementGroup('mg')
  name: 'Require_tag_on_resource_group'
  params: {
    policyName: 'Require tag on resource group'
    policyProperties: {
      displayName: 'Require a tag on resource group'
      description: 'Require a tag on resource group for the scope.'
      policyType: 'Custom'
      mode: 'All'
      parameters: {
        effect: {
          type: 'String'
          metadata: {
            displayName: 'Effect'
            description: 'Enable or disable the execution of the policy'
          }
          allowedValues: [
            'Audit'
            'Deny'
            'Disabled'
          ]
          defaultValue: 'Deny'
        }
        tagName: {
          type: 'String'
          metadata: {
            displayName: 'Required tag'
            description: 'Required tag on resource group'
          }
        }
      }
      policyRule: {
        if: {
          allOf: [
            {
              field: 'type'
              equals: '"Microsoft.Resources/subscriptions/resourceGroups'
            }
            {

              field: '[concat(\'tags[\', parameters(\'tagName\'), \']\')]'
              exists: 'false'

            }
          ]
        }
        then: {
          effect: '[parameters(\'effect\')]'
        }
      }
      metadata: {
        category: 'governance'
      }
    }
  }
}

module allowed_vm_skus '../deploy.bicep' = {
  scope: managementGroup('mg')
  name: 'allowed-vm-skus'
  params: {
    policyName: 'Allowed Virtual Machine SKUs'
    policyProperties: {
      policyType: 'Custom'
      mode: 'All'
      displayName: 'Allowed Virtual Machine SKUs'
      description: 'Allowed Virtual Machine SKUs for the scope.'
      parameters: {
        listOfAllowedSkus: {
          type: 'Array'
          metadata: {
            displayName: 'List of allowed skus'
            description: 'Allowed skus'
          }
          defaultValue: []
        }
      }
      policyRule: {
        if: {
          allOf: [
            {
              field: 'type'
              equals: 'Microsoft.Compute/virtualMachines'
            }
            {
              Not: {
                field: 'Microsoft.Compute/virtualMachines/sku.name'
                in: '[parameters(\'listOfAllowedSkus\')]'
              }
            }
          ]
        }
      }
      metadata: {
        category: 'governance'
      }
    }
  }
}

module deny_rdp_from_internet '../deploy.bicep' = {
  scope: managementGroup('mg')
  name: 'deny-rdp-from-internet'
  params: {
    policyName: 'Deny Remote Desktop Protocol from Internet service tag'
    policyProperties: {
      displayName: 'Deny Remote Desktop Protocol from Internet service tag'
      description: 'Deny Remote Desktop Protocol from Internet service tag for the scope.'
      policyType: 'Custom'
      mode: 'All'
      parameters: {
        effect: {
          type: 'String'
          metadata: {
            displayName: 'Effect'
            description: 'Enable or disable the execution of the policy'
          }
          allowedValues: [
            'Audit'
            'Deny'
            'Disabled'
          ]
          defaultValue: 'Deny'
        }
      }
      policyRule: {
        if: {
          allOf: [
            {
              field: 'type'
              equals: 'Microsoft.Network/networkSecurityGroups/securityRules'
            }
            {
              allOf: [
                {
                  field: 'Microsoft.Network/networkSecurityGroups/securityRules/access'
                  equals: 'Allow'
                }
                {
                  field: 'Microsoft.Network/networkSecurityGroups/securityRules/direction'
                  equals: 'Inbound'
                }
                {
                  anyOf: [
                    {
                      field: 'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange'
                      equals: '*'
                    }
                    {
                      field: 'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange'
                      equals: '3389'
                    }
                    {
                      value: '[if(and(not(empty(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange\'))), contains(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange\'),\'-\')), and(lessOrEquals(int(first(split(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange\'), \'-\'))),3389),greaterOrEquals(int(last(split(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRange\'), \'-\'))),3389)), \'false\')]'
                      equals: 'true'
                    }
                    {
                      count: {
                        field: 'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]'
                        where: {
                          value: '[if(and(not(empty(first(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]\')))), contains(first(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]\')),\'-\')), and(lessOrEquals(int(first(split(first(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]\')), \'-\'))),3389),greaterOrEquals(int(last(split(first(field(\'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]\')), \'-\'))),3389)) , \'false\')]'
                          equals: 'true'
                        }
                      }
                      greater: 0
                    }
                    {
                      not: {
                        field: 'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]'
                        notEquals: '*'
                      }
                    }
                    {
                      not: {
                        field: 'Microsoft.Network/networkSecurityGroups/securityRules/destinationPortRanges[*]'
                        notEquals: '3389'
                      }
                    }
                  ]
                }
                {
                  anyOf: [
                    {
                      field: 'Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'
                      equals: '*'
                    }
                    {
                      field: 'Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefix'
                      equals: 'Internet'
                    }
                    {
                      not: {
                        field: 'Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefixes[*]'
                        notEquals: '*'
                      }
                    }
                    {
                      not: {
                        field: 'Microsoft.Network/networkSecurityGroups/securityRules/sourceAddressPrefixes[*]'
                        notEquals: 'Internet'
                      }
                    }
                  ]
                }
              ]
            }
          ]
        }
        then: {
          effect: '[parameters(\'effect\')]'
        }
      }
      metadata: {
        category: 'security'
      }
    }
  }
}
module audit_subnets_without_udr '../deploy.bicep' = {
  scope: managementGroup('mg')
  name: 'audit_subnets_without_udr'
  params: {
    policyName: 'Audit subnets without UDR'
    policyProperties: {
      displayName: 'Audit subnets without UDR'
      description: 'Audit subnets without UDR for the scope.'
      policyType: 'Custom'
      mode: 'All'
      parameters: {
        effect: {
          type: 'String'
          metadata: {
            displayName: 'Effect'
            description: 'Enable or disable the execution of the policy'
          }
          allowedValues: [
            'Audit'
            'Deny'
            'Disabled'
          ]
          defaultValue: 'Audit'
        }
        excludedSubnets: {
          type: 'Array'
          metadata: {
            displayName: 'Excluded Subnets'
            description: 'Array of subnet names that are excluded from this policy'
          }
          defaultValue: [
            'AzureBastionSubnet'
            'AzureFirewallSubnet'
          ]
        }
      }
      policyRule: {
        if: {
          anyOf: [
            {
              allOf: [
                {
                  equals: 'Microsoft.Network/virtualNetworks'
                  field: 'type'
                }
                {
                  count: {
                    field: 'Microsoft.Network/virtualNetworks/subnets[*]'
                    where: {
                      allOf: [
                        {
                          exists: 'false'
                          field: 'Microsoft.Network/virtualNetworks/subnets[*].routeTable.id'
                        }
                        {
                          field: 'Microsoft.Network/virtualNetworks/subnets[*].name'
                          notIn: '[parameters(\'excludedSubnets\')]'
                        }
                      ]
                    }
                  }
                  notEquals: 0
                }
              ]
            }
            {
              allOf: [
                {
                  field: 'type'
                  equals: 'Microsoft.Network/virtualNetworks/subnets'
                }
                {
                  field: 'name'
                  notIn: '[parameters(\'excludedSubnets\')]'
                }
                {
                  field: 'Microsoft.Network/virtualNetworks/subnets/routeTable.id'
                  exists: 'false'
                }
              ]
            }
          ]
        }
        then: {
          effect: '[parameters(\'effect\')]'
        }
      }
      metadata: {
        category: 'security'
      }
    }
  }
}

module deny_subnets_without_nsg '../deploy.bicep' = {
  scope: managementGroup('mg')
  name: 'deny_subnets_without_nsg'
  params: {
    policyName: 'Deny subnets without NSG'
    policyProperties: {
      displayName: 'Deny subnets without NSG'
      description: 'Deny subnets without NSG for the scope.'
      policyType: 'Custom'
      mode: 'All'
      parameters: {
        effect: {
          type: 'String'
          metadata: {
            displayName: 'Effect'
            description: 'Enable or disable the execution of the policy'
          }
          allowedValues: [
            'Audit'
            'Deny'
            'Disabled'
          ]
          defaultValue: 'Deny'
        }
        excludedSubnets: {
          type: 'Array'
          metadata: {
            displayName: 'Excluded Subnets'
            description: 'Array of subnet names that are excluded from this policy'
          }
          defaultValue: [
            'GatewaySubnet'
            'AzureFirewallSubnet'
            'AzureFirewallManagementSubnet'
            'reservedsubnet1'
            'reservedsubnet2'
            'reservedsubnet3'
          ]
        }
      }
      policyRule: {
        if: {
          anyOf: [
            {
              allOf: [
                {
                  equals: 'Microsoft.Network/virtualNetworks'
                  field: 'type'
                }
                {
                  count: {
                    field: 'Microsoft.Network/virtualNetworks/subnets[*]'
                    where: {
                      allOf: [
                        {
                          exists: 'false'
                          field: 'Microsoft.Network/virtualNetworks/subnets[*].networkSecurityGroup.id'
                        }
                        {
                          field: 'Microsoft.Network/virtualNetworks/subnets[*].name'
                          notIn: '[parameters(\'excludedSubnets\')]'
                        }
                      ]
                    }
                  }
                  notEquals: 0
                }
              ]
            }
            {
              allOf: [
                {
                  field: 'type'
                  equals: 'Microsoft.Network/virtualNetworks/subnets'
                }
                {
                  field: 'name'
                  notIn: '[parameters(\'excludedSubnets\')]'
                }
                {
                  field: 'Microsoft.Network/virtualNetworks/subnets/networkSecurityGroup.id'
                  exists: 'false'
                }
              ]
            }
          ]
        }
        then: {
          effect: '[parameters(\'effect\')]'
        }
      }
      metadata: {
        category: 'security'
      }
    }
  }
}
