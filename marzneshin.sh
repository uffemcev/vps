#!/bin/bash

#ЗАПРОС ДОМЕНА
clear
read -ep "Enter your domain:"$'\n' input_domain
apt update && apt install sqlite3 -y
read() { true; }

# УСТАНОВКИ ПАНЕЛИ
install_mode="1"
input_domain=$input_domain
configure_ssh_input="n"
input_admin_user=$(tr -dc A-Za-z0-9 </dev/urandom | head -c 16; echo)
enable_xhttp="y"
enable_hysteria="y"
configure_ufw_input="y"
source <(wget -qO- https://github.com/artemscine/xray-vps-setup/raw/main/vps-setup.sh)

# НАСТРОЙКИ
db_path="/opt/marzneshin-vps-setup/marzneshin_data/db.sqlite3"
sqlite3 "$db_path" "INSERT INTO services (name) VALUES ('Service');"
sqlite3 "$db_path" "INSERT INTO inbounds_services (inbound_id, service_id) VALUES (1, 1), (2, 1), (3, 1);"
sqlite3 "$db_path" "UPDATE hosts SET remark='{TRANSPORT}' WHERE remark IS NOT NULL AND remark != '';"
sqlite3 "$db_path" "UPDATE settings SET subscription = json_set(subscription, '\$.profile_title', 'VPN', '\$.support_link', '');"

# НАСТРОЙКА РОУТИНГА
#subscription_url="https://github.com/hydraponique/roscomvpn-happ-routing/raw/main/Auto-routing%20for%20some%20panels/Marzneshin%20NON-JSON/subscription.py"
#subscription_file="/opt/marzneshin-vps-setup/marzneshin_data/templates/subscription.py"
#docker_compose_file="/opt/marzneshin-vps-setup/docker-compose.yml"
#mkdir -p /opt/marzneshin-vps-setup/marzneshin_data/templates
#curl -L "$subscription_url" -o "$subscription_file"
#sed -i '/marzneshin:/,/volumes:/s|volumes:|volumes:\n      - ./marzneshin_data/templates/subscription.py:/app/app/routes/subscription.py|' "$docker_compose_file"

# ВЫДАЧА ДАННЫХ
docker compose -f /opt/marzneshin-vps-setup/docker-compose.yml down && docker compose -f /opt/marzneshin-vps-setup/docker-compose.yml up -d
clear
echo "Dashboard: https://${VLESS_DOMAIN}/${DASHBOARD_PATH}/"
echo "User: ${ADMIN_USER}"
echo "Password: ${MARZNESHIN_PASS}"
