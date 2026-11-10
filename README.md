# eduardteodor-db

PostgreSQL database infrastructure and sql migration management for my personal project [eduardteodor.co.uk](https://www.eduardteodor.co.uk)

This repository contains the database configuration, versioned SQL migrations, and a lightweight Bash migration runner for managing schema changes.

## Tech Stack
- **PostgreSQL:** Relational Database
- **Docker Compose:** Database container orchestration
- **Bash:** SQL migration execution
- **psql:** PostgreSQL command line client

## Project Structure
```
eduardteodor-db/
├── .github/                # CI/CD workflows
├── migrations/             # Versioned SQL migrations
│   ├── 0001_INITIAL_CREATE.sql
│   ├── ...sql
│   └── ...sql
├── MigrationRunner/        # Migration runner
├── .env.sample             # Example environment configuration
├── compose.dev.yml         # Development Docker Compose configuration
└── README.md
```

## Running the migration service

Required Docker Compose and .NET 10 SDK.
From the repo root, create your configuration:
```bash
cp .env.sample .env
```

Update `.env` with your database credentials. Ensure `DEFAULT_CONNECTION` matches your PostgreSQL settings and `SCRIPTS=../migrations`.
Start PostgreSQL:
```bash
docker compose -f compose.dev.yml up -d --wait db
```
Run the service from the `MigrationRunner` directory:
```bash
cd MigrationRunner
dotnet run -- test
dotnet run -- status
dotnet run -- migrate
dotnet run -- help
```
The Service Automatically loads `../.env`
