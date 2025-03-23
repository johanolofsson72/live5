# Live5 – Infrastruktur och Deploy för RMK

Detta repo innehåller uppdelad infrastruktur och appdeploy för RMK-projektet.

## 🔧 Steg 1 – Skapa miljö (Storage, ACR, File Share, ACA Environment)

1. Gå till mappen:
   ```bash
   cd live5
   ```

2. Logga in till Azure (om du inte redan gjort det):
   ```bash
   az login
   ```

3. Kör:
   ```bash
   pwsh ./env/deploy-env.ps1
   ```

Detta skapar:
- Azure Container Registry (`live5acr`)
- Azure Storage + File Share (`afs`)
- ACA Environment (`live5env`)

## 🚀 Steg 2 – Bygg & ladda upp image manuellt

Bygg din image lokalt:
```bash
docker build -t live5acr.azurecr.io/rmk:latest .
```

Logga in i ACR:
```bash
az acr login --name live5acr
```

Pusha imagen:
```bash
docker push live5acr.azurecr.io/rmk:latest
```

## 📦 Steg 3 – Deploya RMK-appen

```bash
pwsh ./rmk/deploy-rmk.ps1
```

Appen mountar `Azure File Share` till `/mnt/afs/sqlite` i containern.

---

## 🧪 Testa SQLite-volymen

Lägg till ett test-kommando i din `rmk`-container för att verifiera att du kan skriva:

```bash
sqlite3 /mnt/afs/sqlite/test.db "CREATE TABLE IF NOT EXISTS ping (id INTEGER PRIMARY KEY, msg TEXT); INSERT INTO ping (msg) VALUES ('hej från ACA');"
```

Sedan kan du läsa:
```bash
sqlite3 /mnt/afs/sqlite/test.db "SELECT * FROM ping;"
```

---

## 🧾 Filer

| Fil                                | Beskrivning                              |
|-------------------------------------|------------------------------------------|
| `env/env.bicep`                    | Skapar all grundinfrastruktur            |
| `env/deploy-env.ps1`              | Kör upp infrastrukturen i Azure          |
| `env/remove-env.ps1`              | Tar bort hela RG                         |
| `rmk/rmk.bicep`                   | Skapar ACA för RMK med mount             |
| `rmk/deploy-rmk.ps1`              | Deployar själva appen                    |
| `rmk/remove-rmk.ps1`              | Tar bort endast ACA-appen                |
| `Dockerfile` (din egen)           | Din backend-image                        |


## 🔐 Lägg till certifikat som secret

När din ACA-app är deployad kan du ladda upp ditt certifikat (https.pfx) som en Azure Secret:

```bash
az containerapp secret set \
  --name rmk \
  --resource-group live5-rg \
  --secrets https-pfx=@./certs/https.pfx
```

Certifikatet mountas sedan automatiskt till `/certs/https.pfx` i containern.
