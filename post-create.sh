#!/usr/bin/env bash
set -e

echo "⏳ Restoring dotnet packages..."
dotnet restore src/Web/Web.csproj || true

# Ensure sqlcmd is available (tools18 already in image)
echo "⏳ Waiting for SQL Server to be healthy..."
until /usr/bin/docker compose -f .devcontainer/docker-compose.yml ps --format json | grep -q '"State":"running"'; do
  echo "Waiting for compose services..."; sleep 3
done

# Wait specifically for db health
for i in {1..60}; do
  if docker exec $(docker ps -q -f name=_db) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "${MSSQL_SA_PASSWORD:-YourStrong!Passw0rd}" -C -Q "SELECT 1" > /dev/null 2>&1; then
    echo "✅ SQL Server is ready."
    break
  fi
  echo "Waiting for SQL Server... ($i)"; sleep 2
done

echo "⏳ Creating database and running DDL/seed..."
DB_NAME="PrioritizationTool"
SQLCMD="docker exec $(docker ps -q -f name=_db) /opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P ${MSSQL_SA_PASSWORD:-YourStrong!Passw0rd} -C"

$SQLCMD -Q "IF DB_ID('$DB_NAME') IS NULL CREATE DATABASE [$DB_NAME];"
$SQLCMD -d "$DB_NAME" -i db/ddl.sql
$SQLCMD -d "$DB_NAME" -i db/seed.sql || true

echo "✅ Database initialized."
echo "👉 To run the app: dotnet run --project src/Web/Web.csproj"
