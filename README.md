

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



## 💾 Backup av SQL Edge

Backup-ACA:n (`sqledge-backup`) skapar varje natt:
- En zip-fil: `backup-YYYY-MM-DD.zip`
- Plats: `/mnt/afs/backups/sqledge/`
- Bevarar senaste **7 dagarna**

Deploy:
```bash
pwsh ./edge/deploy-edge-backup.ps1
```

Backupen kör varje natt kl 02:00 med:
- `sqlcmd` mot `sqledge`
- `.bak` → `.zip`
- Automatisk rensning av äldre filer



## 💾 Backup av MySQL

Backup-ACA:n (`mysql-backup`) skapar varje natt:
- En zip-fil: `backup-YYYY-MM-DD.zip`
- Plats: `/mnt/afs/backups/mysql/`
- Bevarar senaste **7 dagarna**

Deploy:
```bash
pwsh ./mysql/deploy-mysql-backup.ps1
```

Backupen kör varje natt kl 02:00 med:
- `mysqldump` mot `mysql`
- `.sql` → `.zip`
- Automatisk rensning av äldre filer

