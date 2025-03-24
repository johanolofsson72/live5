param location string = 'swedencentral'
param environmentName string = 'live5env'
param appName string = 'test'
param acrServer string = 'live5testacr.azurecr.io'

resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
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
    identity: {
      type: 'SystemAssigned'
    }
    template: {
      containers: [
        {
          name: appName
          image: '${acrServer}/test:latest'
          resources: {
            cpu: 0.25
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
