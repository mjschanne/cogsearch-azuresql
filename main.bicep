/// FROM DEPLOY BICEP GITHUB ACTION TUTORIAL
/// parameters: 'storagePrefix=mystore storageSKU=Standard_LRS'

// @minLength(3)
// @maxLength(11)
// param storagePrefix string

// @allowed([
//   'Standard_LRS'
//   'Standard_GRS'
//   'Standard_RAGRS'
//   'Standard_ZRS'
//   'Premium_LRS'
//   'Premium_ZRS'
//   'Standard_GZRS'
//   'Standard_RAGZRS'
// ])
// param storageSKU string = 'Standard_LRS'

// param location string = resourceGroup().location

// var uniqueStorageName = '${storagePrefix}${uniqueString(resourceGroup().id)}'

// resource stg 'Microsoft.Storage/storageAccounts@2021-04-01' = {
//   name: uniqueStorageName
//   location: location
//   sku: {
//     name: storageSKU
//   }
//   kind: 'StorageV2'
//   properties: {
//     supportsHttpsTrafficOnly: true
//   }
// }

// output storageEndpoint object = stg.properties.primaryEndpoints


/// FROM VNET BICEP TUTORIAL; stripped of vms and nsgs
@description('Location for all resources.')
param location string = resourceGroup().location

var virtualNetworkName = 'vNet'
var subnetName = 'backendSubnet'

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: virtualNetworkName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: '10.0.2.0/24'
        }
      }
    ]
  }
}



/// FROM AZ SQL BICEP TUTORIAL
@description('The name of the SQL logical server.')
param serverName string = uniqueString('sql', resourceGroup().id)

@description('The name of the SQL Database.')
param sqlDBName string = 'SampleDB'

@description('The administrator username of the SQL logical server.')
param administratorLogin string

@description('The administrator password of the SQL logical server.')
@secure()
param administratorLoginPassword string

resource sqlServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: serverName
  location: location
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
  }
}

resource sqlDB 'Microsoft.Sql/servers/databases@2022-05-01-preview' = {
  parent: sqlServer
  name: sqlDBName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
}


var privateEndpointSQLName = 'b12-privateEndpointSQL'
var subnet1Name = 'mySubnet'

resource privateEndpointSQL 'Microsoft.Network/privateEndpoints@2020-07-01' = {
  name: privateEndpointSQLName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnet1Name)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointSQLName
        properties: {
          privateLinkServiceId: sqlServer.id
          groupIds: [
            'sqlServer'
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}


@description('Service name must only contain lowercase letters, digits or dashes, cannot use dash as the first two or last one characters, cannot contain consecutive dashes, and is limited between 2 and 60 characters in length.')
@minLength(2)
@maxLength(60)
param name string

@allowed([
  'free'
  'basic'
  'standard'
  'standard2'
  'standard3'
  'storage_optimized_l1'
  'storage_optimized_l2'
])
@description('The pricing tier of the search service you want to create (for example, basic or standard).')
param sku string = 'standard'

@description('Replicas distribute search workloads across the service. You need at least two replicas to support high availability of query workloads (not applicable to the free tier).')
@minValue(1)
@maxValue(12)
param replicaCount int = 1

@description('Partitions allow for scaling of document count as well as faster indexing by sharding your index over multiple search units.')
@allowed([
  1
  2
  3
  4
  6
  12
])
param partitionCount int = 1

@description('Applicable only for SKUs set to standard3. You can set this property to enable a single, high density partition that allows up to 1000 indexes, which is much higher than the maximum indexes allowed for any other SKU.')
@allowed([
  'default'
  'highDensity'
])
param hostingMode string = 'default'

resource search 'Microsoft.Search/searchServices@2020-08-01' = {
  name: name
  location: location
  sku: {
    name: sku
  }
  properties: {
    replicaCount: replicaCount
    partitionCount: partitionCount
    hostingMode: hostingMode
    publicNetworkAccess: 'disabled'
  }
}

var privateEndpointSearchName = 'b12-privateEndpointSearch'

resource privateEndpointSearch 'Microsoft.Network/privateEndpoints@2022-01-01' = {
  name: privateEndpointSearchName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', virtualNetworkName, subnetName)
    }
    privateLinkServiceConnections: [
      {
        name: privateEndpointSearchName
        properties: {
          privateLinkServiceId: search.id
          groupIds: [
            'searchService'
          ]
        }
      }
    ]
  }
  dependsOn: [
    virtualNetwork
  ]
}

var privateDnsZoneName = 'privatelink.search.windows.net'

resource privateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
  properties: {}
  dependsOn: [
    virtualNetwork
  ]
}

resource privateDnsZoneName_vnetName_link 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: privateDnsZone
  name: '${virtualNetworkName}-link'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: virtualNetwork.id
    }
  }
}

var privateDnsZoneSQLGroupName = '${privateEndpointSQLName}/dnsgroupname'

resource privateDnsZoneSQLGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  name: privateDnsZoneSQLGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointSQL
  ]
}

var privateDnsZoneSearchGroupName = '${privateEndpointSearchName}/dnsgroupname'

resource privateDnsZoneSearchGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2021-08-01' = {
  name: privateDnsZoneSearchGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'config1'
        properties: {
          privateDnsZoneId: privateDnsZone.id
        }
      }
    ]
  }
  dependsOn: [
    privateEndpointSearch
  ]
}
