@description('Location for resources')
param location string = 'swedencentral'

@description('Name of the Container Apps environment')
param environmentName string = 'live5env'

@description('Name of the app')
param appName string = 'test'

@description('ACR login server')
param acrServer string = 'live5testacr.azurecr.io'

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environmentName)
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
      registries: [
        {
          server: acrServer
          identity: 'system'
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: '${acrServer}/${appName}:latest'
          resources: {
            cpu: '0.25'
            memory: '0.5Gi'
          }
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}
