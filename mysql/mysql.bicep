param location string = 'swedencentral'
param environmentName string = 'live5env'
param storageAccountName string = 'live5storage'
param fileShareName string = 'afs'
param appName string = 'mysql'

resource mysqlApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environmentName)
    configuration: {
      ingress: {
        external: true
        targetPort: 3306
        transport: 'auto'
      }
      secrets: [
        {
          name: 'mysql-root-password'
          value: 'temporarypass123'
        }
      ]
      environmentVariables: [
        {
          name: 'MYSQL_ROOT_PASSWORD'
          secretRef: 'mysql-root-password'
        }
        {
          name: 'MYSQL_DATABASE'
          value: 'appdb'
        }
      ]
      volumes: [
        {
          name: 'mysql-vol'
          storageType: 'AzureFile'
          storageAccountName: storageAccountName
          shareName: fileShareName
          mountPath: '/var/lib/mysql'
          subPath: 'mysql/data'
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: 'mysql:8.0'
          resources: {
            cpu: 1.0
            memory: '1Gi'
          }
          volumeMounts: [
            {
              volumeName: 'mysql-vol'
              mountPath: '/var/lib/mysql'
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
