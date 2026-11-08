#!/usr/bin/env bash

set -euo pipefail

# 1. Create migration tracking table
docker exec -i "${POSTGRES_CONTAINER_NAME:-postgres}" psql \
    -v ON_ERROR_STOP=1 \
    -U "${POSTGRES_USER:-local}" \
    -d "${POSTGRES_DB:-database}" <<SQL
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    applied_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
SQL

# 2. Loop through migration files
for file in ../migrations/*.sql; do
    version=$(basename "$file" .sql)

    # Check if migration already exists
    applied=$(docker exec -i "${POSTGRES_CONTAINER_NAME:-postgres}" psql \
        -tA -v ON_ERROR_STOP=1 \
        -U "${POSTGRES_USER:-local}" \
        -d "${POSTGRES_DB:-database}" <<SQL
SELECT EXISTS(
    SELECT 1 FROM schema_migrations
    WHERE version = '$version'
);
SQL
)

    if [[ "$applied" == "t" ]]; then
        echo "$version already applied"
    else
        echo "Applying $version"

        # Execute migration
        docker exec -i "${POSTGRES_CONTAINER_NAME:-postgres}" psql \
            -v ON_ERROR_STOP=1 \
            -U "${POSTGRES_USER:-local}" \
            -d "${POSTGRES_DB:-database}" < "$file"

        # Record successful migration
        docker exec -i "${POSTGRES_CONTAINER_NAME:-postgres}" psql \
            -v ON_ERROR_STOP=1 \
            -U "${POSTGRES_USER:-local}" \
            -d "${POSTGRES_DB:-database}" <<SQL
INSERT INTO schema_migrations (version)
VALUES ('$version');
SQL

    fi
done
