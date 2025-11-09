# Configuration Management (Part 2) — Ansible + Docker

## Objective
Automate server configuration using Ansible: install Docker, enable on boot, and apply daemon settings. Idempotent and repeatable.

## Prereqs
- Ansible installed on your control machine
- SSH access to VM (user: `ezzwk`, key-based auth)
- VM: Ubuntu 22.04 on Azure

## Inventory
`inventory.ini` defines the target host:
```ini
[servers]
azurevm ansible_host=<PUBLIC_IP> ansible_user=ezzwk ansible_ssh_private_key_file=~/.ssh/id_ed25519

# Part 2 — Configuration Management (Ansible)

## Objective
Automate server configuration: install Docker, enable on boot, allow non-root usage.

## How to run
```bash
ansible-playbook -i ansible/inventory.ini ansible/site.yml

# Part 3 — Docker Container Deployment

## Objective
Containerize a sample Flask web app and automate its deployment to the Azure VM.

## Files
- app/Dockerfile
- app/app.py
- app/requirements.txt
- ansible/deploy.yml

## How to deploy
ansible-playbook -i ansible/inventory.ini ansible/deploy.yml

## Verify
Open http://<PUBLIC_IP>/ (port 80 must be allowed in NSG) 
or use SSH port-forward and browse http://localhost:8080/

# Part 4 — CI/CD with GitHub Actions

## Objective
Automatically build and deploy the Dockerized web app to the Azure VM on every push to main.

## Pipeline
- File: .github/workflows/deploy.yml
- Triggers: push to main (app/**), manual dispatch
- Steps:
  1) Copy app/ to VM via SCP
  2) Build Docker image on VM
  3) Stop/remove old container
  4) Run new container (-p 80:8080, restart unless-stopped)

## Secrets
- VM_HOST, VM_USER, VM_SSH_KEY (private key)
- Optional: VM_SSH_PORT=22, HOST_PORT=80, CONTAINER_NAME=sampleapp

## Verify
Open http://<PUBLIC_IP>/ after a successful run.
