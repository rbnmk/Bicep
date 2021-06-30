targetScope = 'subscription'

param company string = ''
param solution string = ''
param costcenter string = ''
param environment string = ''
param department string = ''
param ownerEmail string = ''

var tags = {
  company: company
  solution: solution
  environment: environment
  costcenter: costcenter
  ownerEmail: ownerEmail
  department: department
}

output tags object = tags

