#!/bin/bash

#ЗАПРОС ДАННЫХ
clear
read -ep "Enter your RU domain:"$'\n' ru_domain
read -ep "Enter your EN domain:"$'\n' en_domain
read -ep "Enter your EN ip:"$'\n' en_ip
read -ep "Enter your EN login:"$'\n' en_login
read -ep "Enter your EN password:"$'\n' en_password
apt update && apt install -y sshpass
read() { true; }

#НАСТРОЙКА EN
remote_output=$(sshpass -p "$en_password" ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "$en_login@$en_ip" bash -s "$en_domain" << 'EOF'
    read() { true; }
    export TERM=xterm
    export choice_warp="n"
    export choice_mtp="n"
    export fp_choice="2"
    source <(wget -qO- https://raw.githubusercontent.com/xVRVx/autoXRAY/main/autoXRAY1.sh) "$en_domain" > /dev/null 2>&1
    echo "$linkRTY2"
    echo "$configListLink"
EOF
)
mapfile -t en_url <<< "$remote_output"

#НАСТРОЙКА RU
export choice_mtp="n"
export fp_choice="5"
source <(wget -qO- https://raw.githubusercontent.com/xVRVx/autoXRAY/main/autoXRAYselfRUbrEUxhttp.sh) "$ru_domain" "${en_url[0]}"

#УСТАНОВКА ZAPRET
while sleep 1; do echo; done | script -q -e -c "wget https://raw.githubusercontent.com/IndeecFOX/z4r/4/z4r && sh z4r" /dev/null

#РЕДАКТИРОВАНИЕ МАРШРУТОВ

#ВЫДАЧА ДАННЫХ
systemctl restart xray
clear
echo "EN подписка: ${en_url[1]}"
