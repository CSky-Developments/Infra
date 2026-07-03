# VPS Setup Guide

Follow these steps to prepare a fresh Ubuntu VPS for this infrastructure.

## 1. Initial Server Setup

Update packages and create a non-root user with sudo privileges.

```bash
apt update && apt upgrade -y
adduser deploy
usermod -aG sudo deploy
```

## 2. Hardening SSH & Basic Security

It is critical to secure SSH before exposing the server. We disable root login and password authentication, and install Fail2Ban to prevent brute-force attacks. 
*(Ensure your SSH key is copied to `/home/deploy/.ssh/authorized_keys` before restarting SSH)*

```bash
apt install fail2ban -y
systemctl enable --now fail2ban

sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

## 3. Configure Firewall (UFW)

Secure the server by only allowing SSH, HTTP, and HTTPS traffic.

```bash
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable
```

## 4. Install Docker and Docker Compose

Install Docker engine:
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker deploy
```

## 5. Setup Project Directories

Create the directory where the infrastructure and services will live:
```bash
mkdir -p /srv/infra
mkdir -p /srv/services
chown -R deploy:deploy /srv/infra /srv/services
```

You are now ready to switch to the `deploy` user, clone this repository to `/srv/infra`, and start the proxy from `/srv/infra/proxy`.
