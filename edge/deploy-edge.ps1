# deploy-edge.ps1 - Deploy SQL Edge to ACA

param (
    [string]$resourceGroup = "live5-rg",
    [string]$location = "swedencentral",
    [string]$bicepFile = "./edge/edge.bicep"
)

$ErrorActionPreference = "Stop"

az deployment group create `
  --resource-group $resourceGroup `
  --template-file $bicepFile `
  --parameters location=$location

Write-Host "✅ SQL Edge ACA deployad!"
