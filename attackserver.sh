#!/bin/bash
echo "[*] Updating & Installing Dependencies..."
apt update && apt upgrade -y
apt install -y docker.io docker-compose unzip curl

echo "[*] Starting Docker Service..."
systemctl enable --now docker

echo "[*] Creating Docker Network..."
docker network create pentest-lab

echo "[*] Deploying Vulnerable Web Apps..."
docker run -d --name dvwa --network pentest-lab -p 8081:80 vulnerables/web-dvwa
docker run -d --name mutillidae --network pentest-lab -p 8082:80 citizenstig/nowasp
docker run -d --name juiceshop --network pentest-lab -p 8083:3000 bkimminich/juice-shop
docker run -d --name wordpress --network pentest-lab -p 8084:80 wordpress:5.0
docker run -d --name joomla --network pentest-lab -p 8085:80 joomla:3.9

echo "[*] Deploying Exploitable Network Services..."
docker run -d --name ftp --network pentest-lab -p 21:21 stilliard/pure-ftpd:hardened
docker run -d --name smb --network pentest-lab -p 445:445 dperson/samba -p -u "hacker;password"
docker run -d --name ssh --network pentest-lab -p 2222:22 rastasheep/ubuntu-sshd
docker run -d --name rdp --network pentest-lab -p 3389:3389 scottyhardy/xrdp
docker run -d --name telnet --network pentest-lab -p 23:23 cmplopes/telnet-server

echo "[*] Installing Red Team Tools..."
docker run -d --name metasploit --network pentest-lab metasploitframework/metasploit-framework
docker run -d --name empire --network pentest-lab bcsecurity/empire
docker run -d --name covenant --network pentest-lab rasta-mouse/covenant
docker run -d --name bloodhound --network pentest-lab specterops/bloodhound
docker run -d --name caldera --network pentest-lab mitre/caldera

echo "[*] Setup Complete. Your Attack Lab is Running!"
docker ps
