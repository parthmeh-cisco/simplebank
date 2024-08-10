#!/bin/sh

set -e

echo "run db migration"
source /app/app.env
# Debug output
echo "DB_SOURCE is set to: $DB_SOURCE"
/app/migrate -path /app/migration -database "$DB_SOURCE" -verbose up

echo "start the app"
exec "$@"
