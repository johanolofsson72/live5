param (
    [string]$resourceGroup = "live5-rg",
    [string]$location = "swedencentral",
    [string]$acrName = "testacr"
)

$ErrorActionPreference = "Stop"

Write-Host "📦 Skapar ACR: $acrName i $location ..."

az acr create `
  --name $acrName `
  --resource-group $resourceGroup `
  --sku Basic `
  --location $location `
  --admin-enabled true

Write-Host "`n✅ ACR '$acrName' skapad!"
Write-Host "Använd login-server: $acrName.azurecr.io"
