#eduardteodor-db

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
│   └── 0002_SECOND_TABLE.sql
├── scripts/
│   └── migrate.sh          # Migration runner
├── .env.sample             # Example environment configuration
├── compose.dev.yml         # Development Docker Compose configuration
└── README.md
```

## Running the migration service

Ensure that you run the following bash commands inside /script
```bash
set -a
source .env
set +a
```
