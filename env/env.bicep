param location string = 'swedencentral'
param environmentName string = 'live5env'
param storageAccountName string = 'live5storage'
param fileShareName string = 'afs'
param workspaceName string = 'live5logs'
param insightsName string = 'live5appinsights'

var workspaceKey = logAnalyticsWorkspace.listKeys().primarySharedKey

// Storage account
resource storage 'Microsoft.Storage/storageAccounts@2022-09-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
  }
}

// File share (med parent-syntax)
resource fileService 'Microsoft.Storage/storageAccounts/fileServices@2022-09-01' = {
  name: 'default'
  parent: storage
}

resource fileShare 'Microsoft.Storage/storageAccounts/fileServices/shares@2022-09-01' = {
  name: fileShareName
  parent: fileService
  properties: {
    accessTier: 'Hot'
  }
}

// Log Analytics Workspace
resource logAnalyticsWorkspace 'Microsoft.OperationalInsights/workspaces@2021-06-01' = {
  name: workspaceName
  location: location
  properties: {
    sku: {
      name: 'PerGB2018'
    }
    retentionInDays: 30
  }
}

// Application Insights kopplad till workspace
resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: insightsName
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    WorkspaceResourceId: logAnalyticsWorkspace.id
  }
}

// ACA Environment
resource containerEnv 'Microsoft.App/managedEnvironments@2023-05-01' = {
  name: environmentName
  location: location
  properties: {
    appLogsConfiguration: {
      destination: 'log-analytics'
      logAnalyticsConfiguration: {
        customerId: logAnalyticsWorkspace.properties.customerId
        sharedKey: workspaceKey
      }
    }
    storageAccounts: [
      {
        name: storageAccountName
        accountName: storage.name
        shareName: fileShareName
        accessKey: listKeys(storage.id, storage.apiVersion).keys[0].value
      }
    ]
  }
}
