#!/bin/sh

set -e

# Load environment variables from app.env
if [ -f /app/app.env ]; then
  export $(cat /app/app.env | grep -v ^# | xargs)
fi

echo "run db migration"
/app/migrate -path /app/db/migration -database "$DB_SOURCE" -verbose up

echo "start the app"
exec /app/main
