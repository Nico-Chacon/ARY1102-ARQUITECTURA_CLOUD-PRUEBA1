#!/bin/bash
exec > /var/log/user-data-db.log 2>&1
set -x

# ============================================================
# Bootstrap EC2 MySQL - Capa Data - chacon-freshbox (EP1)
# Generado por Terraform (templatefile) - NO editar a mano
# Amazon Linux 2023 (ARM) - usa el paquete mariadb105-server
# (motor MySQL-compatible) por ser el disponible en AL2023.
# ============================================================

dnf update -y
dnf install -y mariadb105-server

systemctl enable mariadb
systemctl start mariadb

# Esperar a que el servicio este arriba
for i in $(seq 1 15); do
  mysqladmin ping >/dev/null 2>&1 && break
  echo "Esperando a MySQL/MariaDB... intento $i/15"
  sleep 5
done

# Password root + usuario de aplicacion + base de datos (idempotente)
mysql -u root <<SQL
ALTER USER 'root'@'localhost' IDENTIFIED BY '${db_root_password}';
FLUSH PRIVILEGES;
SQL

mysql -u root -p'${db_root_password}' <<SQL
CREATE USER IF NOT EXISTS '${db_user}'@'%' IDENTIFIED BY '${db_password}';
GRANT ALL PRIVILEGES ON ${db_name}.* TO '${db_user}'@'%';
FLUSH PRIVILEGES;
SQL

# Permitir conexiones remotas (desde la capa App, ya filtrado por Security Group)
sed -i 's/^bind-address.*/bind-address=0.0.0.0/' /etc/my.cnf.d/mariadb-server.cnf 2>/dev/null || true
systemctl restart mariadb

# Cargar init.sql SOLO si la tabla aun no tiene datos (evita duplicar filas
# si la instancia se recrea)
echo "${db_init_sql_b64}" | base64 -d > /tmp/init.sql

ROW_COUNT=$(mysql -u root -p'${db_root_password}' -N -B \
  -e "SELECT COUNT(*) FROM ${db_name}.productos;" 2>/dev/null || echo "0")

if [ "$ROW_COUNT" = "0" ]; then
  echo "Tabla vacia o inexistente: cargando init.sql..."
  mysql -u root -p'${db_root_password}' < /tmp/init.sql \
    && echo "init.sql cargado correctamente" \
    || echo "ADVERTENCIA: init.sql fallo (revisar /var/log/user-data-db.log)"
else
  echo "La tabla ya tiene $ROW_COUNT filas, se omite init.sql"
fi

echo "chacon-freshbox DB setup completado"
