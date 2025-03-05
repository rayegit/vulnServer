#!/bin/bash

set -e  # Stop on any error

echo -e "\n🔥 Ultimate Automated Attack Lab Deployment 🔥\n"

# Detect OS
OS=$(uname -s)
echo "[+] Detected OS: $OS"

# Ensure Docker is installed
if ! command -v docker &>/dev/null; then
    echo "[!] Docker is not installed. Installing now..."
    if [[ "$OS" == "Linux" ]]; then
        sudo apt update && sudo apt install -y docker.io
    elif [[ "$OS" == "Darwin" ]]; then
        brew install --cask docker
    else
        echo "[!] Unsupported OS. Install Docker manually."
        exit 1
    fi
fi

# Pull and deploy vulnerable web apps
echo "[+] Deploying Vulnerable Web Apps..."
docker network create pentest-lab || true

docker run -d --name dvwa --network pentest-lab -p 8081:80 vulnerables/web-dvwa
docker run -d --name juiceshop --network pentest-lab -p 8082:3000 bkimminich/juice-shop
docker run -d --name mutillidae --network pentest-lab -p 8083:80 citizenstig/nowasp

# Deploy misconfigured services
echo "[+] Deploying Vulnerable Network Services..."
docker run -d --name smb-vuln --network pentest-lab -p 445:445 cyberxsecurity/smb-vuln
docker run -d --name ftp-vuln --network pentest-lab -p 21:21 stilliard/pure-ftpd:hardened
docker run -d --name ssh-vuln --network pentest-lab -p 2222:22 vulnerables/cve-2018-15473
docker run -d --name telnet-vuln --network pentest-lab -p 23:23 vimagick/telnetd

# Deploy Windows Active Directory (Requires Windows Server ISO)
echo "[+] Deploying Windows Server 2019 with Active Directory..."
if [[ "$OS" == "Linux" ]]; then
    docker run -d --name win-ad --network pentest-lab -p 3389:3389 -p 389:389 \
        --env ADMIN_PASSWORD="P@ssw0rd!" \
        --env DOMAIN="attacklab.local" \
        --env ROLE="dc" \
        --restart unless-stopped \
        aresx/adlab
fi

# Deploy Red Team & Attack Tools
echo "[+] Deploying Red Team Tools..."
docker run -d --name metasploit --network pentest-lab -p 4444:4444 metasploitframework/metasploit-framework
docker run -d --name empire --network pentest-lab -p 1337:1337 bcsecurity/empire
docker run -d --name covenant --network pentest-lab -p 7443:7443 cobbr/covenant

# Deploy Automated Attack Simulation
echo "[+] Deploying Automated Attack Simulations..."
docker run -d --name bloodhound --network pentest-lab -p 7687:7687 -p 7474:7474 specterops/bloodhound
docker run -d --name caldera --network pentest-lab -p 8888:8888 mitre/caldera

# Deploy AWS/Azure Misconfiguration Labs
echo "[+] Deploying Cloud Security Labs..."
docker run -d --name cloudgoat --network pentest-lab rhisecurity/cloudgoat
docker run -d --name flaws2 --network pentest-lab flaws2/flaws2

# Deploy Web-Based Control Panel (optional)
echo "[+] Deploying Web Control Panel..."
docker run -d --name controlpanel --network pentest-lab -p 5000:5000 pentestlab/controlpanel

echo -e "\n✅ Deployment Complete! Access your attack lab:\n"
echo "  DVWA:          http://localhost:8081"
echo "  Juice Shop:    http://localhost:8082"
echo "  Mutillidae:    http://localhost:8083"
echo "  Metasploit:    docker exec -it metasploit msfconsole"
echo "  Empire:        docker exec -it empire powershell"
echo "  BloodHound:    http://localhost:7474"
echo "  Windows AD:    RDP to localhost:3389 (user: Administrator, pass: P@ssw0rd!)"
echo "  Control Panel: http://localhost:5000"
echo -e "\n🚀 Happy Hacking!"
