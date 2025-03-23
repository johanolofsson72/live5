param location string = 'swedencentral'
param environmentName string = 'live5env'
param storageAccountName string = 'live5storage'
param fileShareName string = 'afs'
param appName string = 'sqledge-backup'

resource edgeBackup 'Microsoft.App/containerApps@2023-05-01' = {
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
          name: 'sql-sa-password'
          value: 'D4yCru!s3r2025!'
        }
      ]
      environmentVariables: [
        {
          name: 'SQL_HOST'
          value: 'sqledge'
        }
        {
          name: 'SQL_USER'
          value: 'sa'
        }
        {
          name: 'SQL_PASSWORD'
          secretRef: 'sql-sa-password'
        }
      ]
      volumes: [
        {
          name: 'backup-vol'
          storageType: 'AzureFile'
          storageAccountName: storageAccountName
          shareName: fileShareName
          mountPath: '/mnt/backups'
          subPath: 'backups/sqledge'
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
            "apt update && apt install -y zip curl gnupg &&             curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - &&             curl https://packages.microsoft.com/config/ubuntu/20.04/prod.list > /etc/apt/sources.list.d/mssql-release.list &&             apt update && ACCEPT_EULA=Y apt install -y mssql-tools &&             while true; do               sleep $((60 * (60 * 2)));               /opt/mssql-tools/bin/sqlcmd -S sqledge -U $SQL_USER -P $SQL_PASSWORD -Q "BACKUP DATABASE [appdb] TO DISK='/tmp/appdb.bak'" &&               zip -j /mnt/backups/backup-$(date +%F).zip /tmp/appdb.bak &&               find /mnt/backups/ -name '*.zip' -mtime +6 -delete;             done"
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
