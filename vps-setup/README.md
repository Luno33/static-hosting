# VPS Setup

## Prerequisites

1. Ensure your env file (in `../envs`) contains: `VPS_USER`, `VPS_ADDRESS`, `VPS_PORT`, `SSH_KEY_PATH`
2. Install Ansible dependencies:

```bash
cd ./ansible
ansible-galaxy install -r requirements.yml
```

## Test the connection

If it runs agains the QEMU VM, the port is `2222`, which is the mounted port via QEMU.

```bash
source ../envs/.env.qa # or ../envs/.env.prod
cd ./ansible
ansible-playbook ./test-connection.yml \
  -i "$VPS_ADDRESS," \
  -u "$VPS_USER" \
  --private-key "$SSH_KEY_PATH" \
  -e "ansible_port=22" \
  --ask-pass
```

## Run the setup

### Prerequisite

Make sure that the user can sudo to obtain root privileges, [how to do it](../readme-assets/enable-sudo.md)

### First run (server still on base port)

The base port for a QEMU VM on Linux is `2222`

```bash
source ../envs/.env.qa # or ../envs/.env.prod
cd ./ansible
ansible-playbook ./setup.yml \
  -i "$VPS_ADDRESS," \
  -u "$VPS_USER" \
  --private-key "$SSH_KEY_PATH" \
  -e "ansible_port=22" \
  --ask-pass --ask-become-pass
```

### Subsequent runs (server now on VPS_PORT)

```bash
source ../envs/.env.qa # or ../envs/.env.prod
cd ./ansible
ansible-playbook ./setup.yml \
  -i "$VPS_ADDRESS," \
  -u "$VPS_USER" \
  --private-key "$SSH_KEY_PATH" \
  -e "ansible_port=$VPS_PORT" \
  --ask-become-pass
```

## Verify fail2ban

```bash
# Check status and banned IPs
sudo fail2ban-client status sshd

# Trigger 6 failed logins (uses nonexistent user)
for i in {1..6}; do ssh -p $VPS_PORT -o BatchMode=yes fakeuser@$VPS_ADDRESS; done

# Unban your IP
sudo fail2ban-client set sshd unbanip YOUR_IP
```

## Emulate the server

If you want to first emulate a server instead of running the commands on the production one(s), [here](../readme-assets/qemu.md) you can find a guide on how to setup [QEMU](https://www.qemu.org/).
