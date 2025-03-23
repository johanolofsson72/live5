# deploy-mysql-backup.ps1 - Deployar backup-ACA för MySQL

param (
    [string]$resourceGroup = "live5-rg",
    [string]$location = "swedencentral",
    [string]$bicepFile = "./mysql/mysql-backup.bicep"
)

$ErrorActionPreference = "Stop"

az deployment group create `
  --resource-group $resourceGroup `
  --template-file $bicepFile `
  --parameters location=$location

Write-Host "✅ Backup-ACA för MySQL deployad!"
