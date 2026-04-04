# Configuration-Management-Ansible

Infrastructure as Code project combining Terraform, Ansible, and GitHub Actions to provision, configure, and deploy a Node.js service on AWS EC2.

## Stack

- **Terraform** — provisions EC2 instance and security groups
- **Ansible** — configures the server (hardening, nginx, Node.js, PM2)
- **GitHub Actions** — deploys the app on every push to `app/**`
- **PM2** — keeps the Node.js process running and restarts on reboot

## Structure

```
├── app/                  # Node.js hello-world service
│   ├── server.js
│   └── package.json
├── terraform/            # AWS infrastructure (EC2 + security group)
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── terraform.tfvars.example
├── inventory.ini         # Target hosts — update with Terraform output
├── setup.yml             # Main Ansible playbook
├── group_vars/all.yml    # Shared variables
├── collections/
│   └── requirements.yml  # Ansible collection dependencies
├── .github/
│   └── workflows/
│       └── deploy.yml    # CI/CD — SSH deploy on push to app/**
└── roles/
    ├── base/             # apt upgrade, UFW (22/80/443/3000), fail2ban
    ├── nginx/            # Nginx + Jinja2 config template
    ├── app/              # Clone static site from GitHub → /var/www/html
    ├── ssh/              # Add public key to authorized_keys
    └── nodejs/           # Node.js 20 + PM2 + app deploy
```

## Workflow

### 1. Provision with Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your key_name
terraform init
terraform apply
# → outputs instance_public_dns
```

### 2. Configure with Ansible

```bash
# Put the Terraform output DNS in inventory.ini
# Put your public key in roles/ssh/vars/main.yml
ansible-galaxy collection install -r collections/requirements.yml
ansible-playbook -i inventory.ini setup.yml
```

Run a single role:
```bash
ansible-playbook -i inventory.ini setup.yml --tags "base|nginx|app|nodejs|ssh"
```

### 3. Deploy via GitHub Actions

Add these secrets to the repo (**Settings → Secrets → Actions**):

| Secret | Value |
|---|---|
| `SSH_HOST` | EC2 public DNS |
| `SSH_USER` | `ubuntu` |
| `SSH_PRIVATE_KEY` | Contents of your `.pem` file |

Any push that touches `app/**` triggers an automatic deploy.

## Ansible roles

| Role | Responsibility |
|---|---|
| `base` | System update, utilities, UFW firewall, fail2ban |
| `nginx` | Nginx install + Jinja2 config template |
| `app` | Clone static site, deploy to `/var/www/html` |
| `ssh` | Add public key to `authorized_keys` |
| `nodejs` | Node.js 20 via NodeSource, PM2, app install and start |

> A journey to grow up from Roadmap.sh — [Configuration Management](https://roadmap.sh/projects/configuration-management) · [Node.js Service Deployment](https://roadmap.sh/projects/nodejs-service-deployment)
