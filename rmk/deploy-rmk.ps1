# deploy-rmk.ps1 - Deployar ACA-appen för RMK

param (
    [string]$resourceGroup = "live5-rg",
    [string]$location = "swedencentral",
    [string]$bicepFile = "./rmk.bicep"
)

$ErrorActionPreference = "Stop"

az deployment group create `
  --resource-group $resourceGroup `
  --template-file $bicepFile `
  --parameters location=$location

Write-Host "✅ RMK ACA-app deployad!"
