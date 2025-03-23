param (
    [string]$resourceGroup = "live5-rg",
    [string]$location = "swedencentral",
    [string]$bicepFile = "./test/test.bicep"
)

$ErrorActionPreference = "Stop"

az deployment group create `
  --resource-group $resourceGroup `
  --template-file $bicepFile `
  --parameters location=$location

Write-Host "✅ Test-ACA (upload API) deployad!"
