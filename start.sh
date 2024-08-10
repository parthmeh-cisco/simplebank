#!/bin/sh

set -e

echo "Sourcing environment variables..."
if [ -f app.env ]; then
    echo "app.env found. Contents:"
    cat app.env
    source app.env
    echo "DB_SOURCE after sourcing: $DB_SOURCE"
else
    echo "app.env file not found!"
fi

echo "run db migration"
migrate -path db/migration -database "$DB_SOURCE" -verbose up

echo "start the app"
exec "$@"
