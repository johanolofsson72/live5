param location string = 'swedencentral'
param environmentName string = 'live5env'
param storageAccountName string = 'live5storage'
param fileShareName string = 'afs'
param acrName string = 'live5acr'
param appName string = 'rmk'

resource rmkApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environmentName)
    configuration: {
      ingress: {
        external: true
        targetPort: 80
      }
      registries: [
        {
          server: '${acrName}.azurecr.io'
          username: acr.listCredentials().username
          passwordSecretRef: 'acr-password'
        }
      ]
      secrets: [
        {
          name: 'acr-password'
          value: acr.listCredentials().passwords[0].value
        }
      ]
      volumes: [
        {
          name: 'certs-vol'
          storageType: 'Secret'
          secrets: [
            {
              secretRef: 'https-pfx'
              path: 'https.pfx'
            }
          ]
        },
        {
          name: 'afs-vol'
          storageType: 'AzureFile'
          storageAccountName: storageAccountName
          shareName: fileShareName
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: '${acrName}.azurecr.io/rmk:latest'
          resources: {
            cpu: 0.5
            memory: '0.5Gi'
          }
          volumeMounts: [
            {
              volumeName: 'certs-vol'
              mountPath: '/certs'
            }
            {
              volumeName: 'afs-vol'
              mountPath: '/app/appsettings.json'
              subPath: 'rmk/appsettings.json'
            }
            {
              volumeName: 'afs-vol'
              mountPath: '/app/artikel_mall.xlsx'
              subPath: 'rmk/artikel_mall.xlsx'
            }
            {
              volumeName: 'afs-vol'
              mountPath: '/app/kund_mall.xlsx'
              subPath: 'rmk/kund_mall.xlsx'
            }
            {
              volumeName: 'afs-vol'
              mountPath: '/app/Uploads'
              subPath: 'rmk/uploads'
            }
            {
              volumeName: 'afs-vol'
              mountPath: '/app/Data'
              subPath: 'rmk/data'
            }
          ]
        }
      ]
      scale: {
        minReplicas: 0
        maxReplicas: 1
      }
    }
  }
}
