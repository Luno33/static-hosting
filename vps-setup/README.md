# VPS Setup

## Prerequisites

Set the env var of the user you login with in the VPS
  
```
export LOGIN_USER=************
```

Create a file named `./ansible/hosts` with this structure
  
```bash
[server01]
XXX.XXX.XXX.XXX ansible_ssh_user=************
```
- `XXX.XXX.XXX.XXX` is your server's IP address
- `************` is the user to login with

Install dependencies

```bash
ansible-galaxy install -r requirements.yml
```

## Test the connection

```bash
cd ./ansible
ansible-playbook ./test-connection.yml -i hosts --ask-pass
```

## Run the setup

### Prerequisite

Make sure that the user can sudo to obtain root privileges, [how to do it](../readme-assets/enable-sudo.md)

### Run main ansible playbook

```bash
cd ./ansible
ansible-playbook ./setup.yml -i hosts --ask-pass --ask-become-pass
```

If you cannot run docker due to permissions, just logout and login. Adding the user to the docker group is not reflected immediately.

## Emulate the server

If you want to first emulate a server instead of running the commands on the production one(s), [here](../readme-assets/qemu.md) you can find a guide on how to setup [QEMU](https://www.qemu.org/).
