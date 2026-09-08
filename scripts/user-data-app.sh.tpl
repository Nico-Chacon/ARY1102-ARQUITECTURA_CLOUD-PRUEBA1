#!/bin/bash
exec > /var/log/user-data-app.log 2>&1
set -x

# ============================================================
# Bootstrap EC2 App - Capa App - chacon-freshbox (EP1)
# Generado por Terraform (templatefile) - NO editar a mano
# Instala Docker + Compose y levanta los 5 contenedores
# (frontend + get/create/update/delete-product) leyendo las
# imagenes ya publicadas en Amazon ECR.
# Solo el puerto 80 (frontend/Nginx) se expone al host; los
# 4 microservicios backend se comunican por la red interna de
# docker-compose usando su nombre de servicio (igual que en
# nginx.conf: get-products:3001, create-product:3002, etc).
# ============================================================

dnf update -y
dnf install -y docker

systemctl enable docker
systemctl start docker
usermod -a -G docker ec2-user
usermod -a -G docker ssm-user

# Plugin docker compose v2
mkdir -p /usr/local/lib/docker/cli-plugins
curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-$(uname -m)" \
  -o /usr/local/lib/docker/cli-plugins/docker-compose
chmod +x /usr/local/lib/docker/cli-plugins/docker-compose

mkdir -p /home/ec2-user/app
cd /home/ec2-user/app

# Login a ECR usando el rol IAM de la instancia (LabInstanceProfile)
aws ecr get-login-password --region ${aws_region} | \
  docker login --username AWS --password-stdin ${account_id}.dkr.ecr.${aws_region}.amazonaws.com

cat > docker-compose.yml << COMPOSEEOF
services:
  frontend:
    image: ${frontend_image}
    container_name: chacon-freshbox-frontend
    ports:
      - "80:80"
    restart: always
    depends_on:
      - get-products
      - create-product
      - update-product
      - delete-product

  get-products:
    image: ${get_products_image}
    container_name: chacon-freshbox-get-products
    environment:
      DB_HOST: "${db_host}"
      DB_USER: "${db_user}"
      DB_PASS: "${db_password}"
      DB_NAME: "${db_name}"
      DB_PORT: "3306"
      PORT: "3001"
    restart: always

  create-product:
    image: ${create_product_image}
    container_name: chacon-freshbox-create-product
    environment:
      DB_HOST: "${db_host}"
      DB_USER: "${db_user}"
      DB_PASS: "${db_password}"
      DB_NAME: "${db_name}"
      DB_PORT: "3306"
      PORT: "3002"
    restart: always

  update-product:
    image: ${update_product_image}
    container_name: chacon-freshbox-update-product
    environment:
      DB_HOST: "${db_host}"
      DB_USER: "${db_user}"
      DB_PASS: "${db_password}"
      DB_NAME: "${db_name}"
      DB_PORT: "3306"
      PORT: "3003"
    restart: always

  delete-product:
    image: ${delete_product_image}
    container_name: chacon-freshbox-delete-product
    environment:
      DB_HOST: "${db_host}"
      DB_USER: "${db_user}"
      DB_PASS: "${db_password}"
      DB_NAME: "${db_name}"
      DB_PORT: "3306"
      PORT: "3004"
    restart: always
COMPOSEEOF

chown -R ec2-user:ec2-user /home/ec2-user/app

docker compose pull || exit 1
docker compose up -d || exit 1
docker ps -a

echo "chacon-freshbox APP setup completado (5 contenedores)"
