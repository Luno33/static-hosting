# VPS Setup

With the following guide you'll configure a VPS or the optional QEMU Virtual Machine that you can spin up following this guide [here](../readme-assets/qemu.md).

## Prerequisites

1. Ensure your env file (in `../envs`) contains: `VPS_USER`, `VPS_ADDRESS`, `VPS_PORT`, `SSH_KEY_PATH`
2. Load your SSH key into the agent:
    ```bash
    source ./envs/.env.qa  # or ./envs/.env.prod
    ssh-add -t 120 "$SSH_KEY_PATH"  # confirm each use, 2 min timeout
    ```
3. Start the Ansible container:
    - **MacOS:**
        ```bash
        docker run -it --rm \
          -w /app/vps-setup \
          -v ./envs/.env.qa:/app/envs/.env.qa \
          -v ./vps-setup/ansible:/app/vps-setup/ansible \
          -v "${SSH_KEY_PATH}.pub:${SSH_KEY_PATH}.pub:ro" \
          -v /run/host-services/ssh-auth.sock:/ssh-auth.sock \
          -e SSH_AUTH_SOCK=/ssh-auth.sock \
          alpine/ansible:2.18.6 sh
        ```
    - **Linux:**
        ```bash
        sudo -E docker run -it --rm --network host \
          -w /app/vps-setup \
          -v ./envs/.env.qa:/app/envs/.env.qa \
          -v ./vps-setup/ansible:/app/vps-setup/ansible \
          -v "${SSH_KEY_PATH}.pub:${SSH_KEY_PATH}.pub:ro" \
          -v "$SSH_AUTH_SOCK:/ssh-auth.sock" \
          -e SSH_AUTH_SOCK=/ssh-auth.sock \
          alpine/ansible:2.18.6 sh
        ```
4. Inside the container, run:
    ```bash
    apk add --no-cache sshpass
    export ANSIBLE_HOST_KEY_CHECKING=False
    source ../envs/.env.qa  # or ../envs/.env.prod
    cd ./ansible
    ansible-galaxy install -r requirements.yml
    ```
5. Add the `INITIAL_PORT` variable, which is `22` for the VPS and QEMU MacOS setup, `2222` for the QEMU Linux setup:
    ```bash
    export INITIAL_PORT=22 # or 2222 on QEMU Linux
    ```

## Test the connection

```bash
ansible-playbook ./test-connection.yml \
  -i "$VPS_ADDRESS," \
  -u "$VPS_USER" \
  -e "ansible_port=$INITIAL_PORT" \
  --ask-pass
```

> `SSH password:` is the password of the $VPS_USER defined during setup of the machine.

## Run the setup

### Prerequisite

Make sure that the user can sudo to obtain root privileges, [how to do it](../readme-assets/enable-sudo.md)

### First run (server still on initial port)

```bash
ansible-playbook ./setup.yml \
  -i "$VPS_ADDRESS," \
  -u "$VPS_USER" \
  -e "ansible_port=$INITIAL_PORT" \
  --ask-pass --ask-become-pass
```

> - `SSH password:` is the password of the $VPS_USER defined during setup of the machine.
> - `BECOME password[defaults to SSH password]:` same


### Subsequent runs (server now on VPS_PORT)

```bash
ansible-playbook ./setup.yml \
  -i "$VPS_ADDRESS," \
  -u "$VPS_USER" \
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
