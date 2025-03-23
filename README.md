

## 🧱 SQL Edge (Azure SQL Edge i ACA)

För att deploya SQL Edge-containern:

```bash
pwsh ./edge/deploy-edge.ps1
```

Den skapar en Azure Container App med:
- ✅ SQL Edge (`mcr.microsoft.com/azure-sql-edge`)
- 🔐 Användare: `sa`
- 🔐 Lösenord: `D4yCru!s3r2025!`
- 📦 Mount till `/mnt/afs/sqledge/data`

### 🧠 Åtkomst från andra appar i live5env:

```csharp
Server=sqledge;User Id=sa;Password=D4yCru!s3r2025!;
```

> `sqledge` fungerar som DNS-namn internt mellan appar i samma ACA-miljö.

