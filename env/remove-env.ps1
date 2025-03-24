# Ta bort hela live5-miljön (Resource Group)
$resourceGroup = "live5rg"

Write-Host "🗑️ Tar bort hela resursgruppen '$resourceGroup'..."
az group delete --name $resourceGroup --yes --no-wait

Write-Host "⏳ Borttagning initierad. Det kan ta några minuter."

Write-Host " Gläm inte köra 'az deployment group delete --resource-group live5rg --name env' efteråt för att ta bort deploymenten."
