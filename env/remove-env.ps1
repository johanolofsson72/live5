# remove.ps1 - Tar bort hela live5-resursgruppen

param (
    [string]$resourceGroup = "live5-rg"
)

$ErrorActionPreference = "Stop"

Write-Host "⚠️  Du är på väg att ta bort resursgruppen: $resourceGroup"
$confirm = Read-Host "Vill du fortsätta? (ja/nej)"
if ($confirm -ne "ja") {
    Write-Host "❌ Avbrutet."
    exit
}

az group delete --name $resourceGroup --yes --no-wait

Write-Host "🗑️  Radering påbörjad för resursgruppen '$resourceGroup'."
