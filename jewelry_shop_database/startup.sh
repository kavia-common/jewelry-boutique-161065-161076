#!/bin/bash

# MySQL setup and database initialization for Jewelry Shop
DB_NAME="myapp"
DB_USER="appuser"
DB_PASSWORD="dbuser123"
DB_PORT="5000"
MYSQL_SOCKET="/var/run/mysqld/mysqld.sock"
MYSQL_PID="/var/run/mysqld/mysqld.pid"
MYSQL_DATADIR="/var/lib/mysql"

echo "Starting MySQL setup..."

# Helper: wait for MySQL to be ready
wait_for_mysql() {
  echo "Waiting for MySQL to start..."
  for i in {1..30}; do
    if sudo mysqladmin ping --socket="${MYSQL_SOCKET}" --silent >/dev/null 2>&1; then
      echo "MySQL is ready!"
      return 0
    fi
    echo "Waiting... ($i/30)"
    sleep 2
  done
  echo "MySQL did not become ready in time."
  return 1
}

# Helper: apply schema and seed files if present
apply_schema_and_seed() {
  echo ""
  echo "Applying schema and seed to database '${DB_NAME}' (if present)..."

  if [ -f "schema.sql" ]; then
    echo "Applying schema.sql ..."
    sudo mysql --socket="${MYSQL_SOCKET}" -u root -p"${DB_PASSWORD}" "${DB_NAME}" < schema.sql
    if [ $? -eq 0 ]; then
      echo "✓ Schema applied successfully."
    else
      echo "✗ Failed to apply schema.sql"
    fi
  else
    echo "schema.sql not found - skipping schema application."
  fi

  if [ -f "seed.sql" ]; then
    echo "Applying seed.sql ..."
    sudo mysql --socket="${MYSQL_SOCKET}" -u root -p"${DB_PASSWORD}" "${DB_NAME}" < seed.sql
    if [ $? -eq 0 ]; then
      echo "✓ Seed data loaded successfully."
    else
      echo "✗ Failed to load seed.sql"
    fi
  else
    echo "seed.sql not found - skipping seed."
  fi
}

# 1) Check if MySQL is already running via socket
if sudo mysqladmin ping --socket="${MYSQL_SOCKET}" --silent >/dev/null 2>&1; then
  echo "MySQL is already running."
else
  # 2) If mysqld is running on the specified port, verify TCP connection (informational)
  if pgrep -f "mysqld.*--port=${DB_PORT}" >/dev/null 2>&1; then
    echo "Found existing MySQL process on port ${DB_PORT}"
  fi

  # 3) Initialize MySQL data directory if needed
  if [ ! -d "${MYSQL_DATADIR}/mysql" ]; then
    echo "Initializing MySQL data directory..."
    sudo mysqld --initialize-insecure --user=mysql --datadir="${MYSQL_DATADIR}"
  fi

  # 4) Start MySQL server in background using sudo
  echo "Starting MySQL server on port ${DB_PORT} ..."
  sudo mysqld --user=mysql --datadir="${MYSQL_DATADIR}" --socket="${MYSQL_SOCKET}" --pid-file="${MYSQL_PID}" --port="${DB_PORT}" &

  # 5) Wait for server to be ready
  wait_for_mysql
fi

# 6) Configure database, users, and privileges (idempotent)
echo "Configuring database, users, and privileges..."
sudo mysql --socket="${MYSQL_SOCKET}" << EOF
-- Ensure root uses mysql_native_password so we can authenticate with a password
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';

-- Create application database
CREATE DATABASE IF NOT EXISTS ${DB_NAME};

-- Create or ensure app user exists and has privileges
CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${DB_USER}'@'%';

-- Grant privileges to root (localhost)
GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO 'root'@'localhost';

FLUSH PRIVILEGES;
EOF

# 7) Save connection command
echo "mysql -u ${DB_USER} -p${DB_PASSWORD} -h localhost -P ${DB_PORT} ${DB_NAME}" > db_connection.txt
echo "Connection command saved to db_connection.txt"

# 8) Save environment variables for the DB visualizer
cat > db_visualizer/mysql.env << EOF
export MYSQL_URL="mysql://localhost:${DB_PORT}/${DB_NAME}"
export MYSQL_USER="${DB_USER}"
export MYSQL_PASSWORD="${DB_PASSWORD}"
export MYSQL_DB="${DB_NAME}"
export MYSQL_PORT="${DB_PORT}"
EOF

# 9) Apply schema and seed
apply_schema_and_seed

# 10) Summary
echo ""
echo "MySQL setup complete!"
echo "Database: ${DB_NAME}"
echo "Root user: root (password: ${DB_PASSWORD})"
echo "App user: ${DB_USER} (password: ${DB_PASSWORD})"
echo "Port: ${DB_PORT}"
echo ""
echo "Environment variables saved to db_visualizer/mysql.env"
echo "To use with Node.js viewer, run: source db_visualizer/mysql.env"
echo "To connect to the database, use the following command:"
echo "$(cat db_connection.txt)"
echo ""
echo "MySQL is running in the background. You can now start your application."
