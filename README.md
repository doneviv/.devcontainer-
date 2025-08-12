# Codespaces / Dev Container

This folder enables running the Prioritization Tool in **GitHub Codespaces** (or locally via VS Code Dev Containers).

## Usage
1. Commit this `.devcontainer/` folder to the repo root.
2. Open the repo in **GitHub Codespaces** (Code → Codespaces → Create).
3. The container will start, SQL Server will be provisioned, and the `db/ddl.sql` + `db/seed.sql` scripts will auto-run.
4. Start the app:
   ```bash
   dotnet run --project src/Web/Web.csproj
   ```
5. Open forwarded port **5001** to view the app.

### Environment
- .NET 8 SDK
- Node LTS (for future front-end assets)
- SQL Server 2022 (Linux) service `db`
- Connection string is provided through environment:
  `Server=db;Database=PrioritizationTool;User Id=sa;Password=${MSSQL_SA_PASSWORD};TrustServerCertificate=True`
