#!/bin/sh

set -e

echo "Sourcing environment variables..."
if [ -f /app/app.env ]; then
    source /app/app.env
    echo "DB_SOURCE after sourcing: $DB_SOURCE"
else
    echo "app.env file not found!"
fi

echo "run db migration"
/app/migrate -path /app/migration -database "$DB_SOURCE" -verbose up

echo "start the app"
exec "$@"
