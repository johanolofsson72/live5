$resourceGroup = "live5rg"

Write-Host "🔍 Kontrollerar resurser i $resourceGroup..."

# Lista viktiga resurser
$resources = @(
  "Microsoft.App/managedEnvironments/live5env",
  "Microsoft.Storage/storageAccounts/live5storage",
  "Microsoft.Storage/storageAccounts/live5storage/fileServices/default/shares/afs",
  "Microsoft.OperationalInsights/workspaces/live5logs",
  "Microsoft.Insights/components/live5appinsights"
)

foreach ($res in $resources) {
  $exists = az resource show --ids "/subscriptions/$(az account show --query id -o tsv)/resourceGroups/$resourceGroup/providers/$res" --query "id" -o tsv 2>$null
  if ($exists) {
    Write-Host "✅ Finns: $res"
  } else {
    Write-Host "❌ Saknas: $res"
  }
}
