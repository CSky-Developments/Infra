# VPS Setup

## Why does this exist?
To ensure every VPS provisioning process is identical, secure, and ready to host the CSky infrastructure stack.

## When should it be used?
When provisioning a brand new Ubuntu VPS instance.

## How does it work?
It configures the OS, establishes security perimeters, installs Docker, creates global networks, and establishes GitHub SSH connectivity so the server can autonomously pull deployments.

## Step-by-Step Instructions

### 1. Base OS & User Setup
Create the `deploy` user and assign sudo access.
```bash
apt update && apt upgrade -y
adduser deploy
usermod -aG sudo deploy
```

### 2. SSH Security & Fail2Ban
Disable root login and passwords. Ensure your SSH key is in `/home/deploy/.ssh/authorized_keys`.
```bash
apt install fail2ban -y
systemctl enable --now fail2ban

sed -i 's/^#*PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication no/' /etc/ssh/sshd_config
systemctl restart sshd
```

### 3. Firewall (UFW)
```bash
ufw allow OpenSSH
ufw allow 'Nginx Full'
ufw enable
```

### 4. Docker & Global Network
Install Docker and create the `proxy` network.
```bash
curl -fsSL https://get.docker.com -o get-docker.sh
sh get-docker.sh
usermod -aG docker deploy
docker network create proxy
```

### 5. Directory Creation
```bash
mkdir -p /srv/infra
mkdir -p /srv/services
chown -R deploy:deploy /srv/infra /srv/services
```

### 6. GitHub SSH Authentication
Generate an SSH key for the `deploy` user and add it to GitHub to allow `git clone/pull` without passwords.
```bash
sudo -u deploy ssh-keygen -t ed25519 -C "vps-deploy@csky"
cat /home/deploy/.ssh/id_ed25519.pub
# Add this key to GitHub -> Settings -> SSH Keys
# Test connection:
sudo -u deploy ssh -T git@github.com
```

Clone the infrastructure repository to `/srv/infra`.

## Common Mistakes
- Locking yourself out by disabling password authentication before adding your SSH key.
- Forgetting `docker network create proxy`, causing all proxy routing to fail.

## Troubleshooting
- **Cannot pull from GitHub**: Ensure `ssh -T git@github.com` succeeds. If not, check GitHub SSH keys.

## Related Documentation
- [Reverse Proxy Setup](REVERSE_PROXY.md)
