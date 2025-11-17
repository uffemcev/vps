#!/bin/bash

read -ep "Enter your domain:"$'\n' input_domain

read() { true; }

input_domain=$input_domain
marzban_input="y"
configure_ssh_input="n"
configure_warp_input="n"
source <(wget -qO- https://github.com/Akiyamov/xray-vps-setup/raw/main/vps-setup.sh)

install_choice="2"
choice="1"
meta_title="Подписка"
meta_description="VPN"
source <(wget -qO- https://github.com/legiz-ru/marz-sub/raw/main/marz-sub.sh)

subscription_url="https://github.com/hydraponique/roscomvpn-happ-routing/raw/main/Auto-routing%20for%20Non-json%20Marzban/subscription.py"
subscription_file="/opt/xray-vps-setup/marzban/templates/subscription.py"
docker_compose_file="/opt/xray-vps-setup/docker-compose.yml"
mkdir -p /opt/xray-vps-setup/marzban/templates
curl -L "$subscription_url" -o "$subscription_file"
sed -i '/marzban:/,/volumes:/s|volumes:|volumes:\n      - ./marzban/templates/subscription.py:/code/app/routers/subscription.py|' "$docker_compose_file"

env_file="/opt/xray-vps-setup/marzban/.env"
source_var="XRAY_SUBSCRIPTION_URL_PREFIX"
target_var="SUB_PROFILE_TITLE"
domain=$(grep -E "^$source_var" "$env_file" | sed -E "s/^[^=]+=\s*\"?https?:\/\/([^\"/]+).*/\1/")
sed -i -E "s|^#?\s*$target_var.*|$target_var=\"$domain\"|" "$env_file"

docker compose -f /opt/xray-vps-setup/docker-compose.yml down && docker compose -f /opt/xray-vps-setup/docker-compose.yml up -d
clear

echo "Panel: https://${VLESS_DOMAIN}/${MARZBAN_PATH}"
echo "User: xray_admin"
echo "Password: ${MARZBAN_PASS}"