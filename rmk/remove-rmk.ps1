# remove-rmk.ps1 - Tar bort endast ACA-appen för RMK

param (
    [string]$resourceGroup = "live5-rg",
    [string]$appName = "rmk"
)

$ErrorActionPreference = "Stop"

Write-Host "⚠️  Du är på väg att ta bort ACA-appen: $appName"
$confirm = Read-Host "Vill du fortsätta? (ja/nej)"
if ($confirm -ne "ja") {
    Write-Host "❌ Avbrutet."
    exit
}

az containerapp delete --name $appName --resource-group $resourceGroup --yes

Write-Host "🗑️  ACA-app '$appName' borttagen."
