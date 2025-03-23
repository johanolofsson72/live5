# deploy-env.ps1 - Skapar ACR, Storage, File Share och ACA Environment

param (
    [string]$resourceGroup = "live5-rg",
    [string]$location = "swedencentral",
    [string]$bicepFile = "./env/env.bicep"
)

$ErrorActionPreference = "Stop"

az group create --name $resourceGroup --location $location

az deployment group create `
  --resource-group $resourceGroup `
  --template-file $bicepFile `
  --parameters location=$location

Write-Host "✅ Infrastrukturmiljö skapad!"
