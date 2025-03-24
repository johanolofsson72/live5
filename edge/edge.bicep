param location string = 'swedencentral'
param environmentName string = 'live5env'
param storageAccountName string = 'live5storage'
param fileShareName string = 'afs'
param appName string = 'sqledge'

resource sqlEdge 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environmentName)
    configuration: {
      ingress: {
        external: false
        targetPort: 1433
      }
      secrets: [
        {
          name: 'mssql-sa-password'
          value: 'Mitt5tarkal0senOr7'
        }
      ]
      environmentVariables: [
        {
          name: 'ACCEPT_EULA'
          value: 'Y'
        }
        {
          name: 'MSSQL_SA_PASSWORD'
          secretRef: 'mssql-sa-password'
        }
      ]
      volumes: [
        {
          name: 'sqledge-vol'
          storageType: 'AzureFile'
          storageAccountName: storageAccountName
          shareName: fileShareName
          mountPath: '/var/opt/mssql'
          subPath: 'sqledge/data'
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: 'mcr.microsoft.com/azure-sql-edge'
          resources: {
            cpu: 1.0
            memory: '1Gi'
          }
          volumeMounts: [
            {
              volumeName: 'sqledge-vol'
              mountPath: '/var/opt/mssql'
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
