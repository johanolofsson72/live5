# deploy-edge-backup.ps1 - Deployar backup-ACA för SQL Edge

param (
    [string]$resourceGroup = "live5-rg",
    [string]$location = "swedencentral",
    [string]$bicepFile = "./edge/edge-backup.bicep"
)

$ErrorActionPreference = "Stop"

az deployment group create `
  --resource-group $resourceGroup `
  --template-file $bicepFile `
  --parameters location=$location

Write-Host "✅ Backup-ACA för SQL Edge deployad!"
