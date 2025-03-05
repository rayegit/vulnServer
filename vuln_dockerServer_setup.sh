#!/bin/bash

# VULN_SERVER_SETUP - Fully Automated Vulnerable Pentest Lab
# Supports Linux-based systems with Docker installed

echo "[*] Checking for Docker..."
if ! command -v docker &>/dev/null; then
    echo "[!] Docker is not installed! Installing now..."
    sudo apt update && sudo apt install -y docker.io
    sudo systemctl enable --now docker
fi

echo "[*] Pulling vulnerable Docker images..."
docker pull vulnerables/web-dvwa
docker pull citizenstig/nowasp
docker pull vulnerables/cve-2017-5638
docker pull vulnerables/metasploitable2
docker pull raesene/bwapp
docker pull opendns/security-ninjas
docker pull diogomonica/docker-bench-security
docker pull vulnerablewordpress/latest
docker pull vulnerables/exploit-db
docker pull cyberxsecurity/psa-lab  # PrintNightmare
docker pull cyberxsecurity/eternalblue-vulnerable  # MS17-010
docker pull public.ecr.aws/smugglers/log4shell-vulnerable-app  # Log4Shell

echo "[*] Creating Docker network: vulnnet"
docker network create vulnnet

echo "[*] Deploying vulnerable web apps..."
docker run -d --name dvwa --network vulnnet -p 8081:80 vulnerables/web-dvwa
docker run -d --name mutillidae --network vulnnet -p 8082:80 citizenstig/nowasp
docker run -d --name struts2-exploit --network vulnnet -p 8083:8080 vulnerables/cve-2017-5638
docker run -d --name bwapp --network vulnnet -p 8084:80 raesene/bwapp
docker run -d --name security-ninjas --network vulnnet -p 8085:80 opendns/security-ninjas
docker run -d --name wordpress-vuln --network vulnnet -p 8086:80 vulnerablewordpress/latest
docker run -d --name exploit-db --network vulnnet -p 8087:80 vulnerables/exploit-db

echo "[*] Deploying vulnerable services..."
docker run -d --name metasploitable --network vulnnet -p 2222:22 -p 445:445 -p 3389:3389 -p 23:23 -p 21:21 vulnerables/metasploitable2
docker run -d --name ldap --network vulnnet -p 389:389 osixia/openldap
docker run -d --name log4shell --network vulnnet -p 8088:8080 public.ecr.aws/smugglers/log4shell-vulnerable-app
docker run -d --name eternalblue --network vulnnet -p 445:445 cyberxsecurity/eternalblue-vulnerable
docker run -d --name printnightmare --network vulnnet -p 9100:9100 cyberxsecurity/psa-lab

echo "[*] Deploying exploitable databases..."
docker run -d --name mysql-vuln --network vulnnet -p 3306:3306 -e MYSQL_ROOT_PASSWORD=root mysql:5.7
docker run -d --name postgres-vuln --network vulnnet -p 5432:5432 -e POSTGRES_PASSWORD=postgres postgres:9.6
docker run -d --name mongo-vuln --network vulnnet -p 27017:27017 mongo:latest

echo "[*] Deploying SMTP server with open relay..."
docker run -d --name smtp-vuln --network vulnnet -p 25:25 namshi/smtp

echo "[*] Deploying security benchmarking tools..."
docker run -d --name docker-bench-security --network vulnnet diogomonica/docker-bench-security

echo "[+] Vulnerable services running:"
docker ps --format "table {{.Names}}\t{{.Ports}}"

echo "[+] Setup complete! Access web apps on:"
echo "    - DVWA: http://localhost:8081"
echo "    - Mutillidae: http://localhost:8082"
echo "    - Struts2: http://localhost:8083"
echo "    - bWAPP: http://localhost:8084"
echo "    - Security Ninjas: http://localhost:8085"
echo "    - WordPress Vuln: http://localhost:8086"
echo "    - Exploit-DB: http://localhost:8087"
echo "    - Log4Shell Test: http://localhost:8088"
echo ""
echo "[+] Vulnerable services:"
echo "    - Metasploitable2 (Multiple services, weak creds)"
echo "    - LDAP: ldap://localhost:389"
echo "    - Open SMTP: smtp://localhost:25 (No Auth!)"
echo "    - MySQL: mysql://localhost:3306 (root/root)"
echo "    - PostgreSQL: postgres://localhost:5432 (postgres/postgres)"
echo "    - MongoDB: mongo://localhost:27017 (No Auth)"
echo "    - EternalBlue SMB: \\localhost\share"
echo "    - PrintNightmare Exploit: nc localhost 9100"
echo ""

echo "[+] Start Metasploit with:"
echo "    msfconsole -q -x 'db_connect postgres:postgres@127.0.0.1/msf'"
echo "    msf > use exploit/multi/samba/usermap_script"
echo "    msf > set RHOSTS 127.0.0.1"
echo "    msf > exploit"

echo "[+] To reset the lab, run:"
echo "    docker stop \$(docker ps -q) && docker rm \$(docker ps -aq)"
