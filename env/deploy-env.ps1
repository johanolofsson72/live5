$rg = "live5rg"
$location = "swedencentral"
$vaultName = "live5vault"
$storageAccount = "live5storage"
$fileShare = "afs"
$policyName = "live5-dailypolicy"

# Skapa resursgruppen om den inte finns
$rgExists = az group exists --name $rg | ConvertFrom-Json
if (-not $rgExists) {
    Write-Host "📁 Skapar resursgruppen '$rg'..."
    az group create --name $rg --location $location | Out-Null
}

Write-Host "🌍 Deploying base infra (env.bicep)..."
$deployment = az deployment group create `
  --resource-group $rg `
  --template-file ./env/env.bicep `
  --parameters location=$location `
  --query "properties.provisioningState" -o tsv

if ($deployment -ne "Succeeded") {
    Write-Error "❌ Deployment misslyckades – avbryter."
    exit 1
}

# Hämta resourceId för storage account
$storageResourceId = az storage account show `
  --name $storageAccount `
  --resource-group $rg `
  --query "id" -o tsv

if (-not $storageResourceId) {
    Write-Error "❌ Kunde inte hämta Resource ID för '$storageAccount'"
    exit 1
}

# Kontrollera om storagekontot redan är registrerat för backup
$registered = az backup container list `
  --resource-group $rg `
  --vault-name $vaultName `
  --backup-management-type AzureStorage `
  --query "[?friendlyName=='$storageAccount']" | ConvertFrom-Json

if ($registered.Count -eq 0) {
    Write-Host "📦 Registrerar '$storageAccount' för backup..."
    az backup container register `
      --resource-group $rg `
      --vault-name $vaultName `
      --backup-management-type AzureStorage `
      --resource-id $storageResourceId `
      --workload-type AzureFileShare
} else {
    Write-Host "✅ '$storageAccount' är redan registrerat för backup."
}

# Hämta containerId för backup
$containerId = az backup container list `
  --resource-group $rg `
  --vault-name $vaultName `
  --backup-management-type AzureStorage `
  --query "[?friendlyName=='$storageAccount'].id" -o tsv

if (-not $containerId) {
    Write-Error "❌ Kunde inte hämta containerId för '$storageAccount' – kan ej aktivera backup."
    exit 1
}

# Kontrollera om backup redan är aktiverad för file share
$existing = az backup item list `
  --resource-group $rg `
  --vault-name $vaultName `
  --backup-management-type AzureStorage `
  --workload-type AzureFileShare `
  --query "[?properties.friendlyName=='$fileShare']" | ConvertFrom-Json

if ($existing.Count -eq 0) {
    Write-Host "🔐 Aktiverar backup för file share '$fileShare'..."
    az backup protection enable-for-azurefileshare `
      --resource-group $rg `
      --vault-name $vaultName `
      --storage-account $storageAccount `
      --item-name $fileShare `
      --policy-name $policyName
} else {
    Write-Host "✅ Backup för file share '$fileShare' är redan aktiverad."
}

Write-Host "✅ Infrastrukturmiljö + backup är klar!"
