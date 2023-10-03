@description('Prefix used for naming resources in the resource group.')
param prefix string = 'b12'

@description('The administrator username of the SQL logical server.')
param administratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

@description('Location for all resources.')
param location string = resourceGroup().location

// var virtualNetworkName = 'vNet'
// var subnetName = 'backendSubnet'
// var privateEndpointSQLName = 'b12-privateEndpointSQL'
// var subnet1Name = 'mySubnet'
// var privateEndpointSearchName = 'b12-privateEndpointSearch'
// var privateDnsZoneName = 'privatelink.search.windows.net'
// var privateDnsZoneSQLGroupName = '${privateEndpointSQLName}/dnsgroupname'
// var privateDnsZoneSearchGroupName = '${privateEndpointSearchName}/dnsgroupname'

// resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
//   name: virtualNetworkName
//   location: location
//   properties: {
//     addressSpace: {
//       addressPrefixes: [
//         '10.0.0.0/16'
//       ]
//     }
//     subnets: [
//       {
//         name: subnetName
//         properties: {
//           addressPrefix: '10.0.2.0/24'
//         }
//       }
//     ]
//   }
// }

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: '${prefix}-sqlserver'
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    // publicNetworkAccess: 'Disabled'
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: 'SampleDB'
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}

// resource privateEndpointSQL 'Microsoft.Network/privateEndpoints@2020-07-01' = {
//   name: privateEndpointSQLName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnet1Name)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: privateEndpointSQLName
//         properties: {
//           privateLinkServiceId: sqlServer.id
//           groupIds: [
//             'sqlServer'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     virtualNetwork
//   ]
// }

resource search 'Microsoft.Search/searchServices@2020-08-01' = {
  name: '${prefix}-search'
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    replicaCount: 1
    partitionCount: 1
    hostingMode: 'default'
    // publicNetworkAccess: 'disabled'
  }
}

// resource privateEndpointSearch 'Microsoft.Network/privateEndpoints@2022-01-01' = {
//   name: privateEndpointSearchName
//   location: location
//   properties: {
//     subnet: {
//       id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
//     }
//     privateLinkServiceConnections: [
//       {
//         name: privateEndpointSearchName
//         properties: {
//           privateLinkServiceId: search.id
//           groupIds: [
//             'searchService'
//           ]
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     virtualNetwork
//   ]
// }

// resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
//   name: privateDnsZoneName
//   location: 'global'
//   properties: {}
//   dependsOn: [
//     virtualNetwork
//   ]
// }

// resource privateDnsZoneName_vnetName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
//   parent: privateDnsZone
//   name: '${virtualNetworkName}-link'
//   location: 'global'
//   properties: {
//     registrationEnabled: false
//     virtualNetwork: {
//       id: virtualNetwork.id
//     }
//   }
// }

// resource privateDnsZoneSQLGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
//   name: privateDnsZoneSQLGroupName
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config1'
//         properties: {
//           privateDnsZoneId: privateDnsZone.id
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     privateEndpointSQL
//   ]
// }

// resource privateDnsZoneSearchGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
//   name: privateDnsZoneSearchGroupName
//   properties: {
//     privateDnsZoneConfigs: [
//       {
//         name: 'config1'
//         properties: {
//           privateDnsZoneId: privateDnsZone.id
//         }
//       }
//     ]
//   }
//   dependsOn: [
//     privateEndpointSearch
//   ]
// }
