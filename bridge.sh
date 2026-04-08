#!/bin/bash

#ЗАПРОС ДАННЫХ
clear
read -ep "Enter your RU domain:"$'\n' ru_domain
read -ep "Enter your EN domain:"$'\n' en_domain
read -ep "Enter your EN ip:"$'\n' en_ip
read -ep "Enter your EN login:"$'\n' en_login
read -ep "Enter your EN password:"$'\n' en_password
apt update && apt install -y sqlite3 sshpass expect
read() { true; }

#НАСТРОЙКА EN
en_url=$(sshpass -p "$en_password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$en_login@$en_ip" bash -s "$en_domain" << 'EOF'
    export TERM=xterm
    read() { true; }
    install_choice=1
    input_domain="$1"
    configure_ssh_input="n"
    configure_warp_input="n"
    source <(wget -qO- https://github.com/Akiyamov/xray-vps-setup/raw/main/vps-setup.sh) > /dev/null 2>&1
    echo "vless://$XRAY_UUID@$VLESS_DOMAIN:443?type=tcp&security=reality&pbk=$XRAY_PBK&fp=chrome&sni=$VLESS_DOMAIN&sid=&spx=%2F&flow=xtls-rprx-vision#EN"
EOF
)

#НАСТРОЙКА RU
export install_choice=2
export input_domain=$ru_domain
export configure_ssh_input="n"
export configure_warp_input="n"
expect -c '
  set timeout 60
  spawn bash -x -c "source <(wget -qO- https://github.com/Akiyamov/xray-vps-setup/raw/main/vps-setup.sh)"
  expect {
    -re {read .* (\w+)\r?\n} {
      set v $expect_out(1,string)
      if {[info exists env($v)]} {send "$env($v)\r"}
      exp_continue
    }
    eof { exit }
  }
'

#УСТАНОВКА ZAPRET
expect -c '
  set timeout 60
  spawn bash -x -c "source <(wget -qO- https://raw.githubusercontent.com/IndeecFOX/z4r/4/z4r)"
  expect {
    -re "\[?:] " { send "\r"; exp_continue }
    eof { exit }
  }
'

#УСТАНОВКА БАЗ
geoip_url="https://cdn.jsdelivr.net/gh/hydraponique/roscomvpn-geoip/release/geoip.dat"
geosite_url="https://cdn.jsdelivr.net/gh/hydraponique/roscomvpn-geosite/release/geosite.dat"
geoip_file="/opt/xray-vps-setup/xray-core/geoip.dat"
geosite_file="/opt/xray-vps-setup/xray-core/geosite.dat"
docker_compose_file="/opt/xray-vps-setup/docker-compose.yml"
curl -L "$geoip_url" -o "$geoip_file"
curl -L "$geosite_url" -o "$geosite_file"
sed -i '/marzban:/,/volumes:/s|volumes:|volumes:\n      - ./xray-core/geosite.dat:/usr/local/share/xray/geosite.dat|' "$docker_compose_file"
sed -i '/marzban:/,/volumes:/s|volumes:|volumes:\n      - ./xray-core/geoip.dat:/usr/local/share/xray/geoip.dat|' "$docker_compose_file"

#ВЫДАЧА ДАННЫХ
docker compose -f /opt/xray-vps-setup/docker-compose.yml down && docker compose -f /opt/xray-vps-setup/docker-compose.yml up -d
clear
echo "Dashboard: https://${VLESS_DOMAIN}/${MARZBAN_PATH}"
echo "User: xray_admin"
echo "Password: ${MARZBAN_PASS}"
