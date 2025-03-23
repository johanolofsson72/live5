param location string = 'swedencentral'
param environmentName string = 'live5env'
param storageAccountName string = 'live5storage'
param fileShareName string = 'afs'
param appName string = 'mysql-backup'

resource mysqlBackup 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  properties: {
    managedEnvironmentId: resourceId('Microsoft.App/managedEnvironments', environmentName)
    configuration: {
      ingress: {
        external: false
        targetPort: 80
      }
      secrets: [
        {
          name: 'mysql-root-password'
          value: 'D4yCru!s3r2025!'
        }
      ]
      environmentVariables: [
        {
          name: 'MYSQL_HOST'
          value: 'mysql'
        }
        {
          name: 'MYSQL_USER'
          value: 'root'
        }
        {
          name: 'MYSQL_PASSWORD'
          secretRef: 'mysql-root-password'
        }
        {
          name: 'MYSQL_DATABASE'
          value: 'appdb'
        }
      ]
      volumes: [
        {
          name: 'backup-vol'
          storageType: 'AzureFile'
          storageAccountName: storageAccountName
          shareName: fileShareName
          mountPath: '/mnt/backups'
          subPath: 'backups/mysql'
        }
      ]
    }
    template: {
      containers: [
        {
          name: appName
          image: 'ubuntu'
          command: [
            "/bin/bash",
            "-c"
          ]
          args: [
            "apt update && apt install -y zip mysql-client &&             while true; do               sleep $((60 * (60 * 2)));               mysqldump -h $MYSQL_HOST -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE > /tmp/appdb.sql &&               zip -j /mnt/backups/backup-$(date +%F).zip /tmp/appdb.sql &&               find /mnt/backups/ -name '*.zip' -mtime +6 -delete;             done"
          ]
          resources: {
            cpu: 0.5
            memory: '0.5Gi'
          }
          volumeMounts: [
            {
              volumeName: 'backup-vol'
              mountPath: '/mnt/backups'
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
