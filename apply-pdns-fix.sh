#!/usr/bin/env bash
set -e
echo "Applying PostgreSQL initialization and schema fixes..."

# 1️⃣ Fix 01-postgres.yaml
awk '
/CREATE USER pdns/ && !done {
  print;
  print "                    -- Set postgres superuser password so remote md5 auth works";
  print "                    ALTER USER postgres WITH ENCRYPTED PASSWORD '\''${POSTGRES_PASSWORD}'\'';";
  print "                    CREATE EXTENSION IF NOT EXISTS pg_stat_statements;";
  done=1; next
}
{print}
' 01-postgres.yaml > tmp && mv tmp 01-postgres.yaml

# 2️⃣ Fix 02-postgres-pdns-init.yaml
if sed --version >/dev/null 2>&1; then
  sed -i 's/EOSQL/EOF/g' 02-postgres-pdns-init.yaml
else
  sed -i '' 's/EOSQL/EOF/g' 02-postgres-pdns-init.yaml
fi

echo "✅ Patch applied successfully!"
