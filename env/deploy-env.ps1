$rg = "live5rg"
$location = "swedencentral"

Write-Host "🌍 Deploying base infra (env.bicep)..."
az deployment group create `
  --resource-group $rg `
  --template-file ./env.bicep `
  --parameters location=$location

# Kontrollera om storagekontot redan är registrerat för backup
$registered = az backup container list `
  --resource-group $rg `
  --vault-name live5vault `
  --backup-management-type AzureStorage `
  --query "[?friendlyName=='live5storage']" | ConvertFrom-Json

if ($registered.Count -eq 0) {
    Write-Host "📦 Registering 'live5storage' for backup in Recovery Vault..."
    az backup container register `
      --resource-group $rg `
      --vault-name live5vault `
      --backup-management-type AzureStorage `
      --storage-account live5storage
} else {
    Write-Host "✅ 'live5storage' is already registered for backup."
}

Write-Host "✅ Infrastrukturmiljö skapad!"
