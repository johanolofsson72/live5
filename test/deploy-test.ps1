# Variabler
$resourceGroup = "live5rg"
$appName = "test"
$location = "swedencentral"
$environmentName = "live5env"
$storageAccount = "live5storage"
$fileShare = "afs"
$acrServer = "live5testacr.azurecr.io"
$volumeName = "upload-vol"
$mountPath = "/mnt/afs/uploads"
$yamlPath = "./test/volume-patch.yaml"

# Steg 1: Deploya ACA (med ACR-auth, utan volym)
Write-Host "🚀 Deploying base ACA with ACR auth..."
az deployment group create `
  --resource-group $resourceGroup `
  --template-file "./test/test.bicep" `
  --parameters location=$location `
              environmentName=$environmentName `
              appName=$appName `
              acrServer=$acrServer `
  | Out-Null

# Steg 2: Skapa YAML-patch för volym och mount
Write-Host "📦 Creating YAML volume patch..."
$yaml = @"
template:
  volumes:
    - name: $volumeName
      storageType: AzureFile
      storageName: $storageAccount
  containers:
    - name: $appName
      image: $acrServer/test:latest
      volumeMounts:
        - volumeName: $volumeName
          mountPath: $mountPath
"@

$yaml | Set-Content -Encoding UTF8 $yamlPath

# Steg 3: Patcha ACA med volym via YAML
Write-Host "📦 Patching ACA with volume via YAML..."
az containerapp update `
  --name $appName `
  --resource-group $resourceGroup `
  --yaml $yamlPath `
  | Out-Null

Write-Host "✅ Test-ACA (upload API) deployad och volym monterad!"
