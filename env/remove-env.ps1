# Ta bort hela live5-miljön (Resource Group)
$resourceGroup = "live5-rg"

Write-Host "🗑️ Tar bort hela resursgruppen '$resourceGroup'..."
az group delete --name $resourceGroup --yes --no-wait

Write-Host "⏳ Borttagning initierad. Det kan ta några minuter."
