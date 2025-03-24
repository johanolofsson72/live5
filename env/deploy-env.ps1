$parameterFile = "./env/parameters.json"

# Hämta resursgrupp från skriptet
$rg = "live5rg"

# Skapa resursgruppen om den inte finns
$rgExists = az group exists --name $rg | ConvertFrom-Json
if (-not $rgExists) {
    Write-Host "📁 Skapar resursgruppen '$rg'..."
    az group create --name $rg --location "swedencentral" | Out-Null
}

Write-Host "🌍 Deploying base infra (env.bicep)..."
$deployment = az deployment group create `
  --resource-group $rg `
  --template-file ./env/env.bicep `
  --parameters @$parameterFile `
  --query "properties.provisioningState" -o tsv

if ($deployment -ne "Succeeded") {
    Write-Error "❌ Deployment misslyckades – avbryter."
    exit 1
}

Write-Host "✅ Infrastrukturmiljö + backup är klar!"