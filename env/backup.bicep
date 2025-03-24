param location string
param storageAccountName string
param fileShareName string
param vaultName string = 'live5vault'
param policyName string = 'live5-dailypolicy'

resource vault 'Microsoft.RecoveryServices/vaults@2022-01-01' = {
  name: vaultName
  location: location
  properties: {
    sku: {
      name: 'Standard'
    }
  }
}

resource backupPolicy 'Microsoft.RecoveryServices/vaults/backupPolicies@2022-01-01' = {
  name: '${vault.name}/${policyName}'
  properties: {
    backupManagementType: 'AzureStorage'
    workLoadType: 'AzureFileShare'
    schedulePolicy: {
      schedulePolicyType: 'SimpleSchedulePolicy'
      scheduleRunFrequency: 'Daily'
      scheduleRunTimes: [
        '2024-01-01T07:30:00Z'
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

resource protectionContainer 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers@2022-01-01' existing = {
  name: '${vault.name}/Azure/StorageContainer;${storageAccountName};${storageAccountName}'
}

resource protectedItem 'Microsoft.RecoveryServices/vaults/backupFabrics/protectionContainers/protectedItems@2022-01-01' = {
  name: '${vault.name}/Azure/StorageContainer;${storageAccountName};${storageAccountName}/AzureFileShare;${fileShareName}'
  properties: {
    protectedItemType: 'AzureFileShareProtectedItem'
    policyId: backupPolicy.id
    sourceResourceId: resourceId('Microsoft.Storage/storageAccounts/fileServices/shares', storageAccountName, 'default', fileShareName)
  }
  dependsOn: [
    backupPolicy
  ]
}
