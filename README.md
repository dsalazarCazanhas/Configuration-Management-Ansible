# Configuration-Management-Ansible

Ansible playbook to configure a Linux server on AWS EC2, covering base hardening, nginx, static site deployment from GitHub, and SSH key management.

## Structure

```
├── inventory.ini         # Target hosts and connection variables
├── setup.yml             # Main playbook — runs all roles in sequence
├── group_vars/all.yml    # Shared variables (repo URL, paths, etc.)
├── collections/
│   └── requirements.yml  # Ansible collection dependencies
└── roles/
    ├── base/             # System update, utilities, UFW firewall, fail2ban
    ├── nginx/            # Install and configure nginx with Jinja2 template
    ├── app/              # Clone static site from GitHub, deploy to web root
    └── ssh/              # Add public key to server's authorized_keys
```

## Requirements

- Ansible 2.12+
- Python 3.8+ on the control node (WSL on Windows)
- A Linux server (Ubuntu 22.04+) accessible via SSH

## Setup

**1. Install Ansible collections:**
```bash
ansible-galaxy collection install -r collections/requirements.yml
```

**2. Configure your inventory:**

Edit `inventory.ini` and replace the placeholder host with your server's IP or DNS and the path to your `.pem` key.

**3. Configure your SSH public key:**

Edit `roles/ssh/vars/main.yml`. To derive the public key from your `.pem`:
```bash
ssh-keygen -y -f ~/.ssh/your-key.pem
```

## Usage

```bash
# Run all roles
ansible-playbook -i inventory.ini setup.yml

# Run only a specific role
ansible-playbook -i inventory.ini setup.yml --tags "base"
ansible-playbook -i inventory.ini setup.yml --tags "nginx"
ansible-playbook -i inventory.ini setup.yml --tags "app"
ansible-playbook -i inventory.ini setup.yml --tags "ssh"

# Dry run (no changes applied)
ansible-playbook -i inventory.ini setup.yml --check
```

## What each role does

| Role | Responsibility |
|---|---|
| `base` | `apt upgrade`, installs curl/git/htop/unzip, configures UFW (deny all, allow 22/80/443), installs fail2ban |
| `nginx` | Installs nginx, deploys site config from Jinja2 template, ensures service is running |
| `app` | Clones [Static-Site-Server](https://github.com/dsalazarCazanhas/Static-Site-Server) from GitHub, copies `site/` to `/var/www/html` with correct permissions |
| `ssh` | Adds a public key to `~/.ssh/authorized_keys` using `ansible.posix.authorized_key` |

---
> A journey to grow up from [Roadmap.sh](https://roadmap.sh/projects/configuration-management)
