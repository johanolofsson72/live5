param location string = 'swedencentral'
param environmentName string = 'live5env'
param storageAccountName string = 'live5storage'
param fileShareName string = 'afs'
param appName string = 'test'

resource testApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environmentName)
    configuration: {
      ingress: {
        external: true
        targetPort: 8080
      }
      volumes: [
        {
          name: 'upload-vol'
          storageType: 'AzureFile'
          storageAccountName: storageAccountName
          shareName: fileShareName
          mountPath: '/mnt/afs/uploads'
          subPath: 'uploads'
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: '<your-acr-name>.azurecr.io/test:latest'
          resources: {
            cpu: 0.5
            memory: '0.5Gi'
          }
          volumeMounts: [
            {
              volumeName: 'upload-vol'
              mountPath: '/mnt/afs/uploads'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 1
        maxReplicas: 1
      }
    }
  }
}
