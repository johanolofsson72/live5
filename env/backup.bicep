param location string
param storageAccountName string
param fileShareName string
param vaultName string = 'live5vault'
param policyName string = 'live5-dailypolicy'

// Recovery Services Vault
resource vault 'Microsoft.RecoveryServices/vaults@2022-01-01' = {
  name: vaultName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {}
}

// Backup Policy for Azure File Share
resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-01-01' = {
  name: '${vault.name}/${policyName}'
  properties: {
    backupManagementType: 'AzureStorage'
    workLoadType: 'AzureFileShare'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        '2024-01-01T07:30:00Z' // 07:30 UTC
      ]
    }
    retentionPolicy: {
      retentionPolicyType: 'SimpleRetentionPolicy'
      retentionDuration: {
        count: 30
        durationType: 'Days'
      }
    }
  }
}
